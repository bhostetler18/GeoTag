//
//  ImageModel.swift
//  GeoTag
//
//  Created by Marco S Hyman on 12/13/22.
//

import MapKit
import OSLog
import PhotosUI
import SwiftUI

// Data about an image that may have its geo-location metadata changed.
// Images may be loaded from disk or selected from the users photo library.
// Image handling is different depending upon the source

@Observable
final class ImageModel: Identifiable {

    // MARK: Class Properties

    // Image is identified by its URL.  Doubles as ID as duplicate instances
    // are not allowed.
    let fileURL: URL
    var id: URL {
        fileURL
    }

    // Image name is set at init
    let name: String

    // Timestamp of the image when present.  The "Timestamp" column of image
    // tables is derived from this property.
    var dateTimeCreated: String?
    var timeStamp: String {
        dateTimeCreated ?? ""
    }

    // Image location.  The "Latitude" and "Longitude" columns of image tables
    // are derived from this value.
    var location: Coords?
    var formattedLatitude: String {
        location?.formatted(.latitude) ?? ""
    }
    var formattedLongitude: String {
        location?.formatted(.longitude) ?? ""
    }

    // Image elevation and formatting for use as a tool tip.
    var elevation: Double?
    var formattedElevation: String {
        var value = "Elevation: "
        if let elevation {
            value += String(format: "% 4.2f", elevation)
            value += " meters"
        } else {
            value += "Unknown"
        }
        return value
    }

    // the Photo picker item and Photos asset if the image came from a
    // Photo Library
    var pickerItem: PhotosPickerItem?
    var asset: PHAsset?

    // URL of related sidecar file (if one exists) and an NSFilePresenter
    // to access the sidecar/XMP file
    let sidecarURL: URL
    var sidecarExists: Bool
    let xmpPresenter: XmpPresenter

    // Optional ID of a paired file.  Used when both raw and jpeg versions
    // of a raw/jpeg pair are opened.
    var pairedID: URL?

    // is this an image file or something else?
    var isValid = false

    // when image data is modified the original data is kept to restore
    // should the user decide to change their mind
    var originalDateTimeCreated: String?
    var originalLocation: Coords?
    var originalElevation: Double?

    // true if image location, elevation, or timestamp have changed
    var changed: Bool {
        isValid && (dateTimeCreated != originalDateTimeCreated ||
                    location != originalLocation ||
                    elevation != originalElevation)
    }

    // The thumbnail image displayed when and image is selected for editing
    var thumbnail: Image?

    private static let logger = Logger(subsystem: "org.snafu.GeoTag",
                                       category: "ImageModel")

    // MARK: Initialization

    // initialization of image data given its URL.
    init(imageURL: URL, forPreview: Bool = false) throws {
        // Self.logger.trace("image \(imageURL) created")
        fileURL = imageURL
        sidecarURL = fileURL.deletingPathExtension().appendingPathExtension(xmpExtension)
        let hasSidecar = fileURL != sidecarURL &&
                         FileManager.default.fileExists(atPath: sidecarURL.path)
        sidecarExists = hasSidecar
        xmpPresenter = XmpPresenter(for: fileURL)
        name = imageURL.lastPathComponent + (hasSidecar ? "*" : "")

        // shortcut initialization when creating an image for preview
        // or if the file type is not writable by Exiftool
        guard !forPreview && Exiftool.helper.fileTypeIsWritable(for: fileURL) else {
            return
        }

        // Load image metadata if we can.  If not mark it as not a valid image
        // even though Exitool wouldn't have problems writing the file.
        do {
            isValid = try loadImageMetadata()
        } catch let error {
            throw error
        }

        // If a sidecar file exists read metadata from it as sidecar files
        // take precidence.
        if isValid && sidecarExists {
            loadXmpMetadata()
        }
        _ = gmtTimeStamp()
    }

    // initialization of image data from images stored in the Photos Library.
    init(libraryEntry: PhotoLibrary.LibraryEntry) {
        // synthesize a URL from the entries item.itemIdentifier
        fileURL = libraryEntry.url
        sidecarURL = fileURL.appendingPathExtension(xmpExtension)
        sidecarExists = false
        xmpPresenter = XmpPresenter(for: fileURL)
        thumbnail = libraryEntry.image
        pickerItem = libraryEntry.item
        if let asset = libraryEntry.asset {
            isValid = true
            let assetResources = PHAssetResource.assetResources(for: asset)
            name = assetResources.first?.originalFilename ?? "unknown"
            loadLibraryMetadata(asset: libraryEntry.asset)
        } else {
            isValid = false
            name = "unknown"
            asset = nil
        }
    }
}

// MARK: ImageModel public functions

extension ImageModel {

    // reset the timestamp and location to their initial values.  Initial
    // values are updated whenever an image is saved.
    func revert() {
        dateTimeCreated = originalDateTimeCreated
        location = originalLocation
        elevation = originalElevation
    }

    // an invalid location read from metadata (corrupted file) will crash
    // the program. Validate coords and return valid data or nil
    func validCoords(latitude: Double, longitude: Double) -> Coords? {
        var coords: Coords?

        if (0...90).contains(latitude.magnitude) &&
            (0...180).contains(longitude.magnitude) {
            coords = Coords(latitude: latitude, longitude: longitude)
        }
        return coords
    }

}

// MARK: Convenience initializers for preview generation.

extension ImageModel {

    // create a model for SwiftUI preview
    convenience init(imageURL: URL,
                     validImage: Bool,
                     dateTimeCreated: String,
                     latitude: Double?,
                     longitude: Double?) {
        do {
            try self.init(imageURL: imageURL, forPreview: true)
        } catch {
            fatalError("ImageModel preview init failed")
        }
        self.isValid = validImage
        self.dateTimeCreated = dateTimeCreated
        if let latitude, let longitude {
            location = Coords(latitude: latitude, longitude: longitude)
        }
    }

    // create an instance of an ImageModel when one is needed but there
    // is otherwise no instance to return.
    convenience init() {
        do {
            try self.init(imageURL: URL(filePath: ""), forPreview: true)
        } catch {
            fatalError("ImageModel no-image init failed")
        }
    }
}

// MARK: ImageModel instances are compared and hashed on id

extension ImageModel: Equatable, Hashable {
    public static func == (lhs: ImageModel, rhs: ImageModel) -> Bool {
        return lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// URLs in this program can be compared

extension URL: Comparable {
    public static func < (lhs: URL, rhs: URL) -> Bool {
        lhs.path < rhs.path
    }
}

// ImageModel is sendable. ImageModel is marked as unchecked to get rid
// of the pairedID warning.

extension ImageModel: @unchecked Sendable {}

// Date formatter used to put timestamps in the form used by exiftool when
// editing timestamps and calculating the date in GMT.

extension ImageModel {
    static let dateFormat = "yyyy:MM:dd HH:mm:ss"

    func timestamp(for timeZone: TimeZone?) -> Date? {
        let dateFormatter = DateFormatter()

        if let dateTime = dateTimeCreated {
            dateFormatter.dateFormat = ImageModel.dateFormat
            dateFormatter.timeZone = timeZone
            if let date = dateFormatter.date(from: dateTime) {
                return date
            }
        }
        return nil
    }

    // return a Date object set to the creation date adjusted by an optional
    // timeZone relative to GMT
    func gmtTimeStamp(_ timeZone: TimeZone? = nil) -> Date {
        let tz = timeZone ?? .current
        let date = timestamp(for: tz) ?? Date.now
        let offset = Double(tz.secondsFromGMT(for: date))
        let gmtDate = Date(timeInterval: offset, since: date)
        return gmtDate
    }
}

// MARK: CFString to (NS)*String casts for Image Property constants

extension ImageModel {
    static let exifDictionary = kCGImagePropertyExifDictionary as NSString
    static let exifDateTimeOriginal = kCGImagePropertyExifDateTimeOriginal as String
    static let GPSDictionary = kCGImagePropertyGPSDictionary as NSString
    static let GPSStatus = kCGImagePropertyGPSStatus as String
    static let GPSLatitude = kCGImagePropertyGPSLatitude as String
    static let GPSLatitudeRef = kCGImagePropertyGPSLatitudeRef as String
    static let GPSLongitude = kCGImagePropertyGPSLongitude as String
    static let GPSLongitudeRef = kCGImagePropertyGPSLongitudeRef as String
    static let GPSAltitude = kCGImagePropertyGPSAltitude as String
    static let GPSAltitudeRef = kCGImagePropertyGPSAltitudeRef as String
}

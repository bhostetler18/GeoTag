//
//  Exiftool.swift
//  GeoTag
//
//  Created by Marco S Hyman on 7/15/16.
//

import SwiftUI
import MapKit

/// manage GeoTag's use of exiftool

struct Exiftool {
    @AppStorage(AppSettings.fileModificationTimeKey) var updateFileModTime = false
    @AppStorage(AppSettings.gpsTimestampKey) var updateGPSTimestamp = false

    // singleton instance of this class
    static let helper = Exiftool()
    let dateFormatter = DateFormatter()

    enum ExiftoolError: Error {
        case runFailed(code: Int)
    }

    // URL of the embedded version of ExifTool
    var url: URL

    // Build the url needed to access to the embedded version of ExifTool

    init() {
        if let exiftoolUrl = Bundle.main.url(forResource: "ExifTool",
                                             withExtension: nil) {
            url = exiftoolUrl.appendingPathComponent("exiftool")
        } else {
            fatalError("The Application Bundle is corrupt.")
        }
    }

    /// Use the embedded copy of exiftool to update the geolocation metadata
    /// in the file containing the passed image
    /// - Parameter image: the image to update.  image contains the URL
    ///     of the original file plus the assigned location.

    func update(from image: ImageModel, timeZone: TimeZone?) async throws {

        // ExifTool argument names
        var latArg = "-GPSLatitude="
        var lonArg = "-GPSLongitude="
        var latRefArg = "-GPSLatitudeRef="
        var lonRefArg = "-GPSLongitudeRef="
        var eleArg = "-GPSaltitude="
        var eleRefArg = "-GPSaltitudeRef="

        // ExifTool GSPDateTime arg storage
        var gpsDArg = "-GPSDateStamp="      // for non XMP files
        var gpsTArg = "-GPSTimeStamp="      // for non XMP files
        var gpsDTArg = "-GPSDateTime="      // for XMP files

        // Build ExifTool latitude, longitude, and elevation argument values
        if let location = image.location {
            latArg += "\(location.latitude)"
            latRefArg += "\(location.latitude)"
            lonArg += "\(location.longitude)"
            lonRefArg += "\(location.longitude)"
            if let ele = image.elevation {
                if ele >= 0 {
                    eleArg += "\(ele)"
                    eleRefArg += "0"
                } else {
                    eleArg += "\(-ele)"
                    eleRefArg += "1"
                }
            }
        }

        // path to image (or XMP) file to update.
        var path = image.sandboxURL.path
        if let xmp = image.sandboxXmpURL {
            path = xmp.path
        }

        let exiftool = Process()
        exiftool.standardOutput = FileHandle.nullDevice
        exiftool.standardError = FileHandle.nullDevice
        exiftool.launchPath = url.path
        exiftool.arguments = ["-q",
                              "-m",
                              "-overwrite_original_in_place",
                              latArg, latRefArg,
                              lonArg, lonRefArg,
                              eleArg, eleRefArg]
        if updateFileModTime {
            exiftool.arguments! += ["-FileModifyDate<DateTimeOriginal"]
        }

        if updateGPSTimestamp {
            // calculate the gps timestamp and update args
            let gpsTimestamp = gpsTimestamp(for: image, in: timeZone)
            gpsDArg += "\(gpsTimestamp)"
            gpsTArg += "\(gpsTimestamp)"
            gpsDTArg += "\(gpsTimestamp)"

            // args vary depending upon saving to an image file or a GPX file
            if image.sandboxXmpURL == nil {
                exiftool.arguments! += [gpsDArg, gpsTArg]
            } else {
                exiftool.arguments?.append(gpsDTArg)
            }
        }

        // add args to update date/time if changed
        if image.dateTimeCreated != image.originalDateTimeCreated {
            let dtoArg = "-DateTimeOriginal=" + (image.dateTimeCreated ?? "")
            let cdArg = "-CreateDate=" + (image.dateTimeCreated ?? "")
            exiftool.arguments! += [dtoArg, cdArg]
        }
        exiftool.arguments! += ["-GPSStatus=", path]
        // dump(exiftool.arguments!)
        exiftool.launch()
        exiftool.waitUntilExit()
        if exiftool.terminationStatus != 0 {
            throw ExiftoolError.runFailed(code: Int(exiftool.terminationStatus))
        }
    }

    // convert the dateTimeCreated string to a string with time zone to
    // update GPS timestamp fields.  Return an empty string

    func gpsTimestamp(for image: ImageModel,
                      in timeZone: TimeZone?) -> String {
        if let dateTime = image.dateTimeCreated {
            dateFormatter.dateFormat = ImageModel.dateFormat
            dateFormatter.timeZone = timeZone
            if let date = dateFormatter.date(from: dateTime) {
                dateFormatter.dateFormat = "yyyy:MM:dd HH:mm:ss xxx"
                return dateFormatter.string(from: date)
            }
        }
        return ""
    }

    // File Type codes for the file types that exiftool can write
    //
    // notes: png files are read/writable by exiftool, but macOS can not
    // read the resulting metadata.  Remove it from the table.
    // Last updated to match ExifTool version 12.30
    let writableTypes: Set = [
        "360", "3G2", "3GP", "AAX", "AI", "ARQ", "ARW", "AVIF", "CR2", "CR3",
        "CRM", "CRW", "CS1", "DCP", "DNG", "DR4", "DVB", "EPS", "ERF", "EXIF",
        "EXV", "F4A/V", "FFF", "FLIF", "GIF", "GPR", "HDP", "HEIC", "HEIF",
        "ICC", "IIQ", "IND", "INSP", "JNG", "JP2", "JPEG", "LRV", "M4A/V",
        "MEF", "MIE", "MNG", "MOS", "MOV", "MP4", "MPO", "MQV", "MRW",
        "NEF", "NRW", "ORF", "ORI", "PBM", "PDF", "PEF", "PGM", // "PNG",
        "PPM", "PS", "PSB", "PSD", "QTIF", "RAF", "RAW", "RW2",
        "RWL", "SR2", "SRW", "THM", "TIFF", "VRD", "WDP", "X3F", "XMP" ]

    /// Check if exiftool supports writing to a type of file
    /// - Parameter for: a URL of a file to check
    /// - Returns: true if exiftool can write to the file type of the URL

    func fileTypeIsWritable(for file: URL) -> Bool {
        let exiftool = Process()
        let pipe = Pipe()
        exiftool.standardOutput = pipe
        exiftool.standardError = FileHandle.nullDevice
        exiftool.launchPath = url.path
        exiftool.arguments = [ "-m", "-q", "-S", "-fast3", "-FileType", file.path]
        exiftool.launch()
        exiftool.waitUntilExit()
        if exiftool.terminationStatus == 0 {
            let data = pipe.fileHandleForReading.availableData
            if data.count > 0,
               let str = String(data: data, encoding: String.Encoding.utf8) {
                let trimmed = str.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                let strParts = trimmed.components(separatedBy: CharacterSet.whitespaces)
                if let fileType = strParts.last {
                    return writableTypes.contains(fileType)
                }
            }
        }
        return false
    }

    /// return selected metadate from a file
    /// - Parameter xmp: URL of XMP file
    /// - Returns: (dto: String, lat: Double, latRef: String, lon: Double, lonRef: String)
    ///
    /// Apple's ImageIO functions can not extract metadata from XMP sidecar
    /// files.  ExifTool is used for that purpose.

    func metadataFrom(xmp: URL) -> (dto: String,
                                    valid: Bool,
                                    location: Coords,
                                    elevation: Double?) {
        let exiftool = Process()
        let pipe = Pipe()
        exiftool.standardOutput = pipe
        exiftool.standardError = FileHandle.nullDevice
        exiftool.launchPath = url.path
        exiftool.arguments = [ "-args", "-c", "%.15f", "-createdate",
                               "-gpsstatus", "-gpslatitude", "-gpslongitude",
                               "-gpsaltitude", xmp.path ]
        exiftool.launch()
        exiftool.waitUntilExit()

        var createDate = ""
        var location = Coords()
        var elevation: Double?
        var validGPS = false

        if exiftool.terminationStatus == 0 {
            let data = pipe.fileHandleForReading.availableData
            if data.count > 0,
               let str = String(data: data, encoding: String.Encoding.utf8) {
                var gpsStatus = true
                var gpsLat = false
                var gpsLon = false
                let strings = str.split(separator: "\n")
                for entry in strings {
                    let key = entry.prefix { $0 != "=" }
                    var value = entry.dropFirst(key.count)
                    if !value.isEmpty {
                        value = value.dropFirst(1)
                    }
                    switch key {
                    case "-CreateDate":
                        // get rid of any trailing parts of a second
                        createDate = String(value.split(separator: ".")[0])
                    case "-GPSStatus":
                        if value.hasSuffix("Void") {
                            gpsStatus = false
                        }
                    case "-GPSLatitude":
                        let parts = value.split(separator: " ")
                        if let latValue = Double(parts[0]),
                           parts.count == 2 {
                            location.latitude = latValue
                            if parts[1] == "S" {
                                location.latitude = -location.latitude
                            }
                            gpsLat = true
                        }
                    case "-GPSLongitude":
                        let parts = value.split(separator: " ")
                        if let lonValue = Double(parts[0]),
                           parts.count == 2 {
                            location.longitude = lonValue
                            if parts[1] == "W" {
                                location.longitude = -location.longitude
                            }
                            gpsLon = true
                        }
                    case "-GPSAltitude":
                        let parts = value.split(separator: " ")
                        if let eleValue = Double(parts[0]),
                           parts.count == 2 {
                            elevation = parts[1] == "1" ? eleValue : -eleValue
                        }

                    default:
                        break
                    }
                }
                // elevation (altitude) is optional
                validGPS = gpsStatus && gpsLat && gpsLon
            }
        }
        return (createDate, validGPS, location, elevation)
    }

}

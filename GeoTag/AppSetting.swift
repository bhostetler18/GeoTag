//
//  Settings.swift
//  GeoTag
//
//  Created by Marco S Hyman on 12/17/22.
//

import Foundation
import SwiftUI

class AppSettings: ObservableObject {
    @AppStorage(AppSettings.saveBookmarkKey) var saveBookmark = Data()

    enum CoordFormat: Int {
        case deg
        case degMin
        case degMinSec
    }

    @Published var backupURL: URL?

    // info needed to remove old backup files

    var oldFiles = [URL]()
    var folderSize = 0
    var deletedSize = 0
    @Published var removeOldFiles = false

    // decode the image backup folder URL from the security scoped
    // bookmark in AppStorage, assuming one exists.

    init() {
        backupURL = getURL()
    }
}


// AppStorage keys for various settings

extension AppSettings {
    static let doNotBackupKey = "DoNotBackupKey"
    static let saveBookmarkKey = "SaveBookmarkKey"
    static let coordFormatKey = "CoordFormatKey"
    static let mapTypeIndexKey = "MapTypeIndexKey"
    static let mapLatitudeKey = "MapLatitudeKey"
    static let mapLongitudeKey = "MapLongitudeKey"
    static let mapAltitudeKey = "MapAltitudeKey"
    static let dividerPositionKey = "DividerPositionKey"
    static let trackColorKey = "TrackColorKey"
    static let trackWidthKey = "TrackWidthKey"
    static let fileModificationTimeKey = "FileModificationTimeKey"
    static let gpsTimestampKey = "GPSTimestampKey"
}

// an extension to Color that allows a Color to be stored in AppStorage

extension Color: RawRepresentable {
    public init?(rawValue: String) {
        guard let data = Data(base64Encoded: rawValue) else {
            self = .blue
            return
        }

        do {
            let color = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? NSColor ?? .systemBlue
            self = Color(color)
        } catch {
            self = .blue
        }
    }

    public var rawValue: String {
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: NSColor(self),
                                                        requiringSecureCoding: false) as Data
            return data.base64EncodedString()
        } catch {
            return ""
        }
    }
}

//
//  ViewModel.swift
//  GeoTag
//
//  Created by Marco S Hyman on 12/13/22.
//

import SwiftUI
import MapKit

// maintain state for GeoTag when running.  An instance if this class is
// created as a StateObject by GeoTagApp and passed in the environment.

@MainActor
final class AppViewModel: ObservableObject {
    @Published var images = [ImageModel]()
    @Published var selection = Set<ImageModel.ID>()
    @Published var mostSelected: ImageModel.ID?

    @AppStorage(AppSettings.hideInvalidImagesKey) var hideInvalidImages = false
    @AppStorage(AppSettings.doNotBackupKey) var doNotBackup = false
    @AppStorage(AppSettings.saveBookmarkKey) var saveBookmark = Data()
    @AppStorage(AppSettings.addTagKey) var addTag = false
    @AppStorage(AppSettings.tagKey) var tag = "GeoTag"


    // A second save can not be triggered while a save is in progress.
    // App termination is denied, too.
    var saveInProgress = false

    // get/set an image from the table of images  given its ID.
    subscript(id: ImageModel.ID?) -> ImageModel {
         get {
             if let id {
                 if let image = images.first(where: { $0.id == id }) {
                     return image
                 }
             }
             // A view may hold on to an ID that is no longer in the table
             // If it tries to access the image associated with that id
             // return a fake image
             return ImageModel()
         }

         set(newValue) {
             if let index = images.firstIndex(where: { $0.id == newValue.id }) {
                 images[index] = newValue
             }
         }
     }

    // The Apps main window.
    var mainWindow: NSWindow?
    var undoManager = UndoManager()

    // State that changes when a menu item is picked.

    // Tracks displayed on map
    var gpxTracks = [Gpx]()

    // The timezone to use when matching image timestamps to track logs and
    // setting the GPS time stamp when saving images.  When nil the system
    // time zone is used.
    var timeZone: TimeZone?

    // GPX File Loading sheet information
    var gpxGoodFileNames = [String]()
    var gpxBadFileNames = [String]()


    // The URL of the folder where image backups are save when backups
    // are enabled.  The URL comes from a security scoped bookmark in
    // AppStorage.
    var backupURL: URL?

    // get the backupURL from AppStorage if needed.  This will also trigger
    // a scan of the backup folder for old backups that can be removed.
    
    init() {
        @AppStorage(AppSettings.doNotBackupKey) var doNotBackup = false

        if !doNotBackup {
            backupURL = getBackupURL()
        }
    }
}

// convenience init for use with swiftui previews.  Provide a list
// of test images suitable for swiftui previews.

extension AppViewModel {
    convenience init(images: [ImageModel]) {
        self.init()
        self.images = images
    }
}
//
//  SaveFolder.swift
//  GeoTag
//
//  Created by Marco S Hyman on 2/8/20.
//  Copyright © 2020,2023 Marco S Hyman. All rights reserved.

import SwiftUI

extension ViewModel {
    /// Convert a security scoped bookmark to its URL
    ///  - Returns the URL if the bookmark could be converted, else nil

    func getBackupURL() -> URL? {
        var staleBookmark = false
        let url = try? URL(resolvingBookmarkData: saveBookmark,
                           options: [.withoutUI, .withSecurityScope],
                           bookmarkDataIsStale: &staleBookmark)
        if let url {
            if staleBookmark {
                saveBookmark = getBookmark(from: url)
            }
            checkSaveFolder(url)
        }
        return url
    }

    /// Convert a file URL into a security scoped bookmark
    /// - Returns the data representing the security scoped bookmark
    func getBookmark(from url: URL) -> Data {
        var bookmark = Data()
        do {
            try bookmark = url.bookmarkData(options: .withSecurityScope)
        } catch let error as NSError {
            print("create bookmark error: \(error.localizedDescription)")
        }
        return bookmark
    }

    /// Check the  folder used to save backups for old image files.  Offer to delete images that were placed
    /// in the backup folder  more than 7 days prior to the current date.  7 days is an arbitrary number,
    /// although any file older than 7 days will be on a time machine backup provided
    /// 1) time machine is in use; and
    /// 2) the backup folder is being saved to time machine.
    ///
    /// - Parameter _: The URL of the folder containing backups

    func checkSaveFolder(_ url: URL?) {
        guard let url else { return }
        let propertyKeys: Set = [URLResourceKey
                                    .totalFileSizeKey,
                                    .addedToDirectoryDateKey]
        let fileManager = FileManager.default
        let _ = url.startAccessingSecurityScopedResource()
        defer { url.stopAccessingSecurityScopedResource() }
        guard let urlEnumerator =
                fileManager.enumerator(at: url,
                                       includingPropertiesForKeys: Array(propertyKeys),
                                       options: [.skipsHiddenFiles],
                                       errorHandler: nil) else { return }
        guard let sevenDaysAgo =
                Calendar.current.date(byAdding: .day, value: -7,
                                      to: Date()) else { return }

        // starting state

        oldFiles = []
        folderSize = 0
        deletedSize = 0

        // loop through the files accumulating storage requirements and a count
        // of older files

        while let fileUrl = urlEnumerator.nextObject() as? URL {
            guard
                let resources =
                    try? fileUrl.resourceValues(forKeys: propertyKeys),
                let fileSize = resources.totalFileSize,
                let fileDate = resources.addedToDirectoryDate else { break }
            folderSize += fileSize
            if fileDate < sevenDaysAgo {
                oldFiles.append(fileUrl)
                deletedSize += fileSize
            }
        }

        // Alert if there are any old files

        DispatchQueue.main.async {
            self.removeOldFiles = !self.oldFiles.isEmpty
        }
    }

    func deleteOldFiles() {
        Task {
            let fileManager = FileManager.default
            for url in oldFiles {
                try? fileManager.removeItem(at: url)
            }
            oldFiles = []
        }
    }
}

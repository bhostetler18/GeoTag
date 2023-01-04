//
//  ShowInFinderAction.swift
//  GeoTag
//
//  Created by Marco S Hyman on 1/1/23.
//

import AppKit

// Open a finder window at an images location. Image may be specified
// in context or by selection

extension ViewModel {
    
    // return true if Show In Finder menu items should be disabled.
    func showInFinderDisabled(context: ImageModel.ID? = nil) -> Bool {
        if context != nil || mostSelected != nil {
            return false
        }
        return true
    }

    // show the location on an image in a finder window.
    func showInFinderAction() {
        let fileURL: URL
        if let id = menuContext {
            fileURL = self[id].fileURL
        } else if let id = mostSelected {
            fileURL = self[id].fileURL
        } else {
            return
        }
        NSWorkspace.shared.activateFileViewerSelecting([fileURL])
    }
}

//
//  DiscardChangesAction.swift
//  GeoTag
//
//  Created by Marco S Hyman on 1/1/23.
//

import Foundation

extension ViewModel {

    // return true if the discard menu item should be disabled

    func discardChangesDisabled() -> Bool {
        return !(mainWindow?.isDocumentEdited ?? false)
    }

    // walk through the array of images calling the revert() function
    // to put the images back in their starting state.

    func discardChangesAction() {
        var index = images.startIndex
        while index < images.endIndex {
            images[index].revert()
            index = images.index(after: index)
        }
        undoManager.removeAllActions()
        mainWindow?.isDocumentEdited = false
    }
}


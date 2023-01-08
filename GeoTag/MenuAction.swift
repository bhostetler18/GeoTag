//
//  MenuAction.swift
//  GeoTag
//
//  Created by Marco S Hyman on 1/1/23.
//

import SwiftUI

extension ViewModel {

    // Actions triggered from a meny item

    enum MenuAction: Identifiable {
        var id: Self {
            return self
        }

        case none
        // file menu
        case save
        case discardChanges
        case discardTracks
        case clearList
        // edit menu
        case undo
        case redo
        case cut
        case copy
        case paste
        case delete
        case selectAll
        case showInFinder
        case locnFromTrack
        case adjustTimeZone
        case modifyDateTime
        case modifyLocation
    }

    // set the menuAction and context.

    func setMenuAction(for action: MenuAction, context: ImageModel.ID? = nil) {
        menuContext = context
        selectedMenuAction = action
    }

    // Do the requested action

    func menuAction(_ action: MenuAction, openWindow: OpenWindowAction) {
        self.selectedMenuAction = .none
        switch action {
        case .none:
            return
        case .save:
            saveAction()
        case .discardChanges:
            discardChangesAction()
        case .discardTracks:
            discardTracksAction()
        case .clearList:
            clearImageListAction()
        case .undo:
            undoAction()
        case .redo:
            redoAction()
        case .cut:
            cutAction(context: menuContext)
        case .copy:
            copyAction(context: menuContext)
        case .paste:
            pasteAction(context: menuContext)
        case .delete:
            deleteAction(context: menuContext)
        case .selectAll:
            selection = Set(images.map { $0.id })
        case .showInFinder:
            showInFinderAction(context: menuContext)
        case .locnFromTrack:
            locnFromTrackAction(context: menuContext)
        case .adjustTimeZone:
            openWindow(id: GeoTagApp.adjustTimeZone)
        case .modifyDateTime:
            openWindow(id: GeoTagApp.modifyDateTime)
        case .modifyLocation:
            openWindow(id: GeoTagApp.modifyLocation)
        }
    }
}

//
//  UndoRedoCommandGroup.swift
//  GeoTag
//
//  Created by Marco S Hyman on 1/7/23.
//

import SwiftUI

// Replace the undoRedo commands group

extension GeoTagApp {
    var undoRedoCommandGroup: some Commands {
        CommandGroup(replacing: .undoRedo) {
            Button(vm.undoManager.undoMenuItemTitle) { vm.setMenuAction(for: .undo) }
                .keyboardShortcut("z")
                .disabled(vm.undoDisabled)
            
            Button(vm.undoManager.redoMenuItemTitle) { vm.setMenuAction(for: .redo) }
                .keyboardShortcut("z", modifiers: [.shift, .command])
                .disabled(vm.redoDisabled)
        }
    }
}

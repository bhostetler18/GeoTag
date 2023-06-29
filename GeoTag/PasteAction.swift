//
//  PasteAction.swift
//  GeoTag
//
//  Created by Marco S Hyman on 12/31/22.
//

import AppKit

// "Paste" into all selected images or a specific image in context
// selected images

extension AppViewModel {

    // return true if paste actions should be disabled.  Paste action always
    // allowed when editing a textfield (textfield != nil)

    func pasteDisabled(context: ImageModel.ID? = nil,
                       textfield: Double?? = nil) -> Bool {
        guard textfield == nil else { return false }
        let pb = NSPasteboard.general
        if let pasteVal = pb.string(forType: NSPasteboard.PasteboardType.string),
           ImageModel.decodeStringRep(value: pasteVal) != nil,
           (context != nil || mostSelected != nil) {
            return false
        }
        return true
    }

    // paste into all selected images

    func pasteAction(context: ImageModel.ID? = nil,
                     textfield: Double?? = nil) {
        if textfield == nil {
            if let context {
                select(context: context)
            }
            let pb = NSPasteboard.general
            if let pasteVal = pb.string(forType: NSPasteboard.PasteboardType.string),
               let locn = ImageModel.decodeStringRep(value: pasteVal) {
                undoManager.beginUndoGrouping()
                for id in selection {
                    update(id: id, location: locn.0, elevation: locn.1)
                }
                undoManager.endUndoGrouping()
                undoManager.setActionName("paste location")
            }
        } else {
            NSApp.sendAction(#selector(NSText.paste(_:)), to: nil, from: nil)
        }
    }
}

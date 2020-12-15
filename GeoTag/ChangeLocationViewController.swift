//
//  ChangeLocationViewController.swift
//  GeoTag
//
//  Created by Marco S Hyman on 5/10/19.
//  Copyright © 2019. 2020 Marco S Hyman. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of
// this software and associated documentation files (the "Software"), to deal in the
// Software without restriction, including without limitation the rights to use,
// copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the
// Software, and to permit persons to whom the Software is furnished to do so,
// subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
// FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
// COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN
// AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
// WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

import Cocoa

class ChangeLocationViewController: NSViewController {
    var image: ImageData!
    var callback: ((_ location: Coord) -> ())?
    
    @IBOutlet weak var newLatitude: NSTextField!
    @IBOutlet weak var newLongitude: NSTextField!
    
    override func viewWillAppear() {
        super.viewWillAppear()
        if let wc = view.window?.windowController as? ChangeLocationWindowController {
            image = wc.image
            callback = wc.callback
            if let coord = image.location {
                switch Preferences.coordFormat() {
                case .deg:
                    newLatitude.stringValue = String(format: "% 2.6f", coord.latitude)
                    newLongitude.stringValue = String(format: "% 2.6f", coord.longitude)
                case .degMin:
                    newLatitude.stringValue = coord.dm.latitude
                    newLongitude.stringValue = coord.dm.longitude
                case .degMinSec:
                    newLatitude.stringValue = coord.dms.latitude
                    newLongitude.stringValue = coord.dms.longitude
                }
            }
            return
        }
        unexpected(error: nil, "Cannot find ChangeLocation Window Controller")
        fatalError("Cannot find ChangeLocation Window Controller")
    }
    

    /// Location change for a single image
    ///
    /// - Parameter NSButton: unused
    ///
    /// invoke the callback passed when the window was opened with the updated
    /// dateValue.
    
    @IBAction
    func locationChanged(_: NSButton) {
        if let lat = newLatitude.stringValue.validateLocation(range: 0...90,
                                                           reference: ["N", "S"]),
           let lon = newLongitude.stringValue.validateLocation(range: 0...180,
                                                            reference: ["E", "W"]) {
            if let coord = image.location,
                coord.latitude == lat, coord.longitude == lon {
                // nothing changed
            } else {
                callback?(Coord(latitude: lat, longitude: lon))
            }
            view.window?.close()
            return
        }

        // location syntax is incorrect
        let alert = NSAlert()
        alert.alertStyle = .warning
        alert.addButton(withTitle: NSLocalizedString("CLOSE", comment: "Close"))
        alert.messageText = NSLocalizedString("CFE_TITLE",
                                              comment: "Coordinate Format Error")
        alert.informativeText = NSLocalizedString("CFE_TEXT",
                                                  comment: "Coordinate Format Error")
        alert.beginSheetModal(for: view.window!)
    }
    
    @IBAction
    func cancel(_ sender: Any) {
        self.view.window?.close()
    }
    
}

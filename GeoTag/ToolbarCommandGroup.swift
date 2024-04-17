//
//  ToolbarCommandGroup.swift
//  GeoTag
//
//  Created by Marco S Hyman on 1/24/23.
//

import SwiftUI

// Replace the toolbar commands group.  The command has nothing to do with a
// toolbar, but it's in the View menu which is where I want it.

struct ToolbarCommands: Commands {

    @MainActor
    var body: some Commands {
        CommandGroup(replacing: .toolbar) {
            Section {
                Button {
                    @AppStorage(AppSettings.hideInvalidImagesKey)
                        var hideInvalidImages = false

                    hideInvalidImages.toggle()
                } label: {
                    ShowHidePinView()
                }
                .keyboardShortcut("d")

                PinOptionView()
            }

        }
    }
}

struct ShowHidePinView: View {
    @AppStorage(AppSettings.hideInvalidImagesKey) var hideInvalidImages = false

    var body: some View {
        Text("\(hideInvalidImages ? "Show" : "Hide") Disabled Files")
    }
}

struct PinOptionView: View {
    @Bindable var location = LocationModel.shared

    var body: some View {
        Picker("Pin view options…", selection: $location.showOtherPins) {
            Text("Show pins for all selected items").tag(true)
            Text("Show pin for most selected item").tag(false)
        }
        .pickerStyle(.menu)

    }
}

//
//  ContentView.swift
//  GeoTag
//
//  Created by Marco S Hyman on 12/9/22.
//

import SwiftUI

/// Window look and feel values
let windowBorderColor = Color.gray
let windowMinWidth = 800.0
let windowMinHeight = 800.0

struct ContentView: View {
    @EnvironmentObject var vm: ViewModel
    @ObservedObject var dividerControl = DividerControl()

    var body: some View {
        HSplitView {
            ZStack {
                ImageTableView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                if vm.showingProgressView {
                    ProgressView("Processing image files...")
                }
            }
            ImageMapView(control: dividerControl)
        }
        .frame(minWidth: windowMinWidth, minHeight: windowMinHeight)
        .border(windowBorderColor)
        .padding()
        .sheet(item: $vm.sheetType, onDismiss: sheetDismissed) { sheetType in
            ContentViewSheet(type: sheetType)
        }
        .confirmationDialog("Are you sure?", isPresented: $vm.presentConfirmation) {
            Button("I'm sure", role: .destructive) {
                if vm.confirmationAction != nil {
                    vm.confirmationAction!()
                }
            }
            Button("Cancel", role: .cancel) {
                vm.presentConfirmation = false
            }
            .keyboardShortcut(.defaultAction)
        } message: {
            let message = vm.confirmationMessage != nil ? vm.confirmationMessage! : ""
            Text(message)
        }
    }

    // when a sheet is dismissed check if there are more sheets to display
    func sheetDismissed() {
        if vm.sheetStack.isEmpty {
            vm.sheetMessage = nil
            vm.sheetError = nil
        } else {
            let sheetInfo = vm.sheetStack.removeFirst()
            vm.sheetMessage = sheetInfo.sheetMessage
            vm.sheetError = sheetInfo.sheetError
            vm.sheetType = sheetInfo.sheetType
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(ViewModel())
    }
}

//
//  ContentView.swift
//  GeoTag
//
//  Created by Marco S Hyman on 12/9/22.
//

import SwiftUI

/// Window look and feel values
let windowBorderColor = Color.gray
let windowMinWidth = 400.0
let windowMinHeight = 800.0

struct ContentView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        HSplitView {
            ImageTableView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .contextMenu {
                    Text("Item 1")
                    Text("Item 2")
                    Divider()
                    Text("Item 3")
                }
            VSplitView {
                ImageView()
                    .frame(maxWidth: .infinity,
                           minHeight: windowMinHeight/2,
                           maxHeight: .infinity)
                Text("Map View goes here")
                    .frame(maxWidth: .infinity,
                           minHeight: windowMinHeight/2,
                           maxHeight: .infinity)
            }
        }
        .frame(minWidth: windowMinWidth, minHeight: windowMinHeight)
        .border(windowBorderColor)
        .padding()
        .sheet(item: $appState.sheetType) { sheetType in
            ContentViewSheet(type: sheetType)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

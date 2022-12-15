//
//  ImageTableView.swift
//  GeoTag
//
//  Created by Marco S Hyman on 12/13/22.
//

import SwiftUI

struct ImageTableView: View {
    @Binding var images: [ImageModel]

    @State private var sortOrder = [KeyPathComparator(\ImageModel.name)]
    @State private var selection = Set<ImageModel.ID>()

    var body: some View {
        Table(images, sortOrder: $sortOrder) {
            TableColumn("Image Name", value: \.name) { image in
                Text(image.name)
                    .help("Full path: \(image.fileURL.path)")
            }
            TableColumn("Timestamp", value: \.timeStamp)
            TableColumn("Latitude", value: \.latitude) { image in
                Text(image.latitude)
            }
            TableColumn("Longitude", value: \.longitude) { image in
                Text(image.longitude)
            }
        }
        .onChange(of: sortOrder) { newOrder in
            images.sort(using: newOrder)
        }
        .onChange(of: selection) { selection in
            print("Selection changed: \(selection)")
        }
        .onAppear {
            selection = Set()
        }
    }
}

/// Computed properties to convert elements of an imageModel into strings for use with
/// this view
extension ImageModel {
    var name: String {
        fileURL.lastPathComponent
    }
    var timeStamp: String {
        dateTimeCreated ?? ""
    }
    var latitude: String {
        location?.dms.latitude ?? ""
    }
    var longitude: String {
        location?.dms.longitude ?? ""
    }

}

//struct ImageTableView_Previews: PreviewProvider {
//    static var previews: some View {
//        ImageTableView(images: .constant([ImageModel.sample!]))
//    }
//}

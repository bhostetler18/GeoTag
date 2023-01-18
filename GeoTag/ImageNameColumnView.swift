//
//  ImageNameColumnView.swift
//  GeoTag
//
//  Created by Marco S Hyman on 12/15/22.
//

import SwiftUI

struct ImageNameColumnView: View {
    @EnvironmentObject var vm: ViewModel
    let id: ImageModel.ID

    var body: some View {
        Text(vm[id].name + ((vm[id].sandboxXmpURL == nil) ? "" : "*"))
            .fontWeight(textWeight())
            .foregroundColor(textColor())
            .help("Full path: \(vm[id].fileURL.path)")
    }

    func textColor() -> Color {
        if vm[id].isValid {
            if id == vm.mostSelected {
                return .mostSelected
            }
            return .primary
        }
        return .secondary
    }

    func textWeight() -> Font.Weight {
        id == vm.mostSelected ? .semibold : .regular
    }
}

struct ImageNameColumnView_Previews: PreviewProvider {
    static var image =
        ImageModel(imageURL: URL(fileURLWithPath: "/test/path/to/image1"),
                   validImage: true,
                   dateTimeCreated: "2022:12:12 11:22:33",
                   latitude: 33.123,
                   longitude: 123.456)

    static var previews: some View {
        ImageNameColumnView(id: image.id)
            .environmentObject(ViewModel(images: [image]))
    }
}
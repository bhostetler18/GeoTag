//
//  ImageNameColumnView.swift
//  GeoTag
//
//  Created by Marco S Hyman on 12/15/22.
//

import SwiftUI

struct ImageNameColumnView: View {
    let image: ImageModel
    let selected: Bool

    var body: some View {
        Text(image.name + (image.sidecarExists ? "*" : ""))
            .fontWeight(textWeight())
            .foregroundColor(textColor())
            .help("Full path: \(image.fileURL.path)")
    }

    @MainActor
    func textColor() -> Color {
        if image.isValid {
            if selected {
                return .mostSelected
            }
            return .primary
        }
        return .secondary
    }

    @MainActor
    func textWeight() -> Font.Weight {
        selected ? .semibold : .regular
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
        ImageNameColumnView(image: image, selected: false)
    }
}

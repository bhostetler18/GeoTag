//
//  ImageTimestampColumnView.swift
//  GeoTag
//
//  Created by Marco S Hyman on 12/17/22.
//

import SwiftUI

struct ImageTimestampColumnView: View {
    @ObservedObject var avm: AppViewModel
    let id: ImageModel.ID
    let timestampMinWidth: CGFloat

    @State private var showPopover = false

    var body: some View {
        let image = avm[id]
        Text(image.timeStamp)
            .foregroundColor(image.timestampTextColor)
            .frame(minWidth: timestampMinWidth)
            .onDoubleClick {
                showPopover = image.isValid
            }
            .popover(isPresented: self.$showPopover) {
                ChangeDateTimeView(id: image.id)
            }
    }
}

struct ImageTimestampColumnView_Previews: PreviewProvider {
    static var image =
        ImageModel(imageURL: URL(fileURLWithPath: "/test/path/to/image1"),
                   validImage: true,
                   dateTimeCreated: "2022:12:12 11:22:33",
                   latitude: 33.123,
                   longitude: 123.456)

    static var previews: some View {
        let avm = AppViewModel(images: [image])
        ImageTimestampColumnView(avm: avm,
                                 id: image.id,
                                 timestampMinWidth: 130.0)
    }
}

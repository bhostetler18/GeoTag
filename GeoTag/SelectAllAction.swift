//
//  SelectAllAction.swift
//  GeoTag
//
//  Created by Marco S Hyman on 1/16/23.
//

import AppKit

extension ViewModel {

    func selectAllDisabled() -> Bool {
        return images.isEmpty
    }

    func selectAllAction() {
        selection = Set(images.map { $0.id })
    }
}

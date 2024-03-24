//
//  LocationModel.swift
//  SMap
//
//  Created by Marco S Hyman on 3/21/24.
//

import MapKit
import SwiftUI

@Observable
final class LocationModel {
    // shared instance
    static let shared: LocationModel = .init()

    // map center
    var mainPin: Coordinate?
    var otherPins: [Coordinate] = []
    var showOtherPins: Bool = false
    var visablePins: [Coordinate] {
        return showOtherPins ? otherPins : []
    }

    var cameraPosition: MapCameraPosition = .automatic
    var cameraDistance: Double = 0

    // approximation of current map rectangle.
    @ObservationIgnored
    var mapRect: MKMapRect?

    // control displayed map tracks
    var tracks: [Track] = []
    var trackSpan: MKCoordinateSpan?
//    var mapCameraBounds: MapCameraBounds? {
//        if let trackSpan {
//            let region = MKCoordinateRegion(center: center.coord2D,
//                                            span: trackSpan)
//            return MapCameraBounds(centerCoordinateBounds: region)
//        }
//        return nil
//    }

    private init() {
        // use the shared instance
    }
}

// Main Pin location update functions.   The location of the main pin is
// set from the table view's most selected item and may be modified by
// clicking on the map.

extension LocationModel {
    func updatePin(from image: ImageModel?) {
        if let coords = image?.location {
            mainPin = Coordinate(latitude: coords.latitude,
                                 longitude: coords.longitude)
            if let mapRect, mapRect.contains(.init(mainPin!.coord2D)) {
                return
            }
            cameraPosition =
                .camera(.init(centerCoordinate: mainPin!.coord2D,
                              distance: cameraDistance))
        } else {
            mainPin = nil
        }
    }
}
// An identifiable container for tracks

extension LocationModel {
    struct Track: Identifiable {
        let id = UUID()
        let track: [Coords]
    }

    func add(track: [Coords]) {
        let newTrack = Track(track: track)
        tracks.append(newTrack)
    }
}

// MARK: Coordinate
// a codable struct to hold the same data as a CLLocationCoordiante2D

struct Coordinate: Codable, Hashable, Identifiable {
    var latitude: Double
    var longitude: Double
    var id = UUID()
    var coord2D: CLLocationCoordinate2D {
        .init(self)
    }
}

// conversions between Coordinate and CLLocationCoordinate2d

extension CLLocationCoordinate2D {
    init(_ coordinate: Coordinate) {
        self = .init(latitude: coordinate.latitude,
                     longitude: coordinate.longitude)
    }
}

extension Coordinate {
    init(_ coordinate: CLLocationCoordinate2D) {
        self = .init(latitude: coordinate.latitude,
                     longitude: coordinate.longitude)
    }
}

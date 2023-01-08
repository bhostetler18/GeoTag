//
//  Updates.swift
//  GeoTag
//
//  Created by Marco S Hyman on 1/1/23.
//

import SwiftUI
import MapKit

// functions that handle location changes for both the map and images

extension ViewModel {

    // Update an image with a location. Image is identified by its ID.
    // Elevation is optional and is only provided when matching track logs

    func update(id: ImageModel.ID, location: Coords?,
                elevation: Double? = nil, documentedEdited: Bool = true) {
        let currentLocation = self[id].location
        let currentElevation = self[id].elevation
        let currentDocumentEdited = window?.isDocumentEdited ?? true
        undoManager.registerUndo(withTarget: self) { target in
            target.update(id: id, location: currentLocation,
                          elevation: currentElevation,
                          documentedEdited: currentDocumentEdited)
        }

        self[id].location = location
        self[id].elevation = elevation
        window?.isDocumentEdited = documentedEdited
    }

    // Add track overlays to the map
    func updateTracks(gpx: Gpx) {
        guard gpx.tracks.count > 0 else { return}
        // storage for min/max latitude found in the track
        var minlat = CLLocationDegrees(90)
        var minlon = CLLocationDegrees(180)
        var maxlat = CLLocationDegrees(-90)
        var maxlon = CLLocationDegrees(-180)
        var newOverlay = false
        gpx.tracks.forEach {
            $0.segments.forEach {
                var trackCoords = $0.points.map {
                    CLLocationCoordinate2D(latitude: $0.lat,
                                           longitude: $0.lon)
                }
                if !trackCoords.isEmpty {
                    for loc in trackCoords {
                        if loc.latitude < minlat {
                            minlat = loc.latitude
                        }
                        if loc.latitude > maxlat {
                            maxlat = loc.latitude
                        }
                        if loc.longitude < minlon {
                            minlon = loc.longitude
                        }
                        if loc.longitude > maxlon {
                            maxlon = loc.longitude
                        }
                    }
                    let mapLine = MKPolyline(coordinates: &trackCoords,
                                             count: $0.points.count)
                    mapLines.append(mapLine)
                    newOverlay = true
                }
            }
        }
        if newOverlay {
            mapSpan = MKCoordinateSpan(latitudeDelta: maxlat - minlat,
                                       longitudeDelta:  maxlon - minlon)
            mapCenter = Coords(latitude: (minlat + maxlat)/2,
                               longitude: (minlon + maxlon)/2)
            refreshTracks = true
        }
    }

}

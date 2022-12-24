//
//  MapView.swift
//
//  Created by Marco S Hyman on 6/24/19.
//  Copyright © 2019,2021 Marco S Hyman. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a
// copy of this software and associated documentation files (the "Software"),
// to deal in the Software without restriction, including without limitation
// the rights to use, copy, modify, merge, publish, distribute, sublicense,
// and/or sell copies of the Software, and to permit persons to whom the
// Software is furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
// THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
// DEALINGS IN THE SOFTWARE.
//

import SwiftUI
import MapKit


// MKMapView exposed to SwiftUI
//
// swiftui MapView does not yet do everthing needed by GeoTag.
// Stick with this version for now.
//
struct MapView: NSViewRepresentable {
    static var view: MKMapView?
    let mapType: MKMapType
    let center: CLLocationCoordinate2D
    let altitude: Double

    @EnvironmentObject var appState: AppState

    func makeCoordinator() -> MapView.Coordinator {
        Coordinator(appState: appState)
    }

    func makeNSView(context: Context) -> ClickMapView {
        let view = ClickMapView(frame: .zero)
        MapView.view = view
        view.viewModel = appState
        view.delegate = context.coordinator
        view.camera = MKMapCamera(lookingAtCenter: center,
                                 fromEyeCoordinate: center,
                                 eyeAltitude: altitude)
        view.showsCompass = true
        return view
    }

    func updateNSView(_ view: ClickMapView, context: Context) {
        view.mapType = mapType
        if appState.pinEnabled, let pin = appState.pin {
            view.addAnnotation(pin)
        }
        if !appState.pinEnabled && appState.pin != nil {
            view.removeAnnotation(appState.pin!)
            appState.pin = nil
        }
    }
}

extension MapView {

    /// Coordinator class conforming to MKMapViewDelegate
    ///
    class Coordinator: NSObject, MKMapViewDelegate {
        let appState: AppState

        init(appState: AppState) {
            self.appState = appState
        }

        /// return a pinAnnotationView for a red pin
        ///
        func mapView(
            _ mapView: MKMapView,
            viewFor annotation: MKAnnotation
        ) -> MKAnnotationView? {
            let identifier = "pinAnnotation"
            var annotationView =
                mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView
            if annotationView != nil {
                annotationView!.annotation = annotation
            } else {
                annotationView = MKMarkerAnnotationView(annotation: annotation,
                                                        reuseIdentifier: identifier)
                if let av = annotationView {
                    av.isEnabled = true
                    av.markerTintColor = .red
                    av.canShowCallout = false
                    av.isDraggable = true
                } else {
                    fatalError("Can't create MKMarkerAnnotationView")
                }
            }
            return annotationView
        }

        /// update the location of a dragged pin
        ///
        @MainActor
        func mapView(
            _ mapView: MKMapView,
            annotationView view: MKAnnotationView,
            didChange newState: MKAnnotationView.DragState,
            fromOldState oldState: MKAnnotationView.DragState
        ) {
            if (newState == .ending) {
                appState.update(location: view.annotation!.coordinate)
            }
        }
    }
}

#if DEBUG
struct MapView_Previews : PreviewProvider {
    static var previews: some View {
        MapView(mapType: .standard,
               center: CLLocationCoordinate2D(latitude: 37.7244,
                                            longitude: -122.4381),
               altitude: 50000.0)
            .environmentObject(AppState())
    }
}
#endif

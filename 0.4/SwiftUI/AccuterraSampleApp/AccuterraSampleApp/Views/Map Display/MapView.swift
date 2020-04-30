//
//  MapView.swift
//  AccuterraSampleApp
//
//  Created by Brian Elliott on 4/20/20.
//  Copyright © 2020 NeoTreks, Inc. All rights reserved.
//

import SwiftUI
import AccuTerraSDK
import Mapbox

extension MGLPointAnnotation {
    convenience init(title: String, coordinate: CLLocationCoordinate2D) {
        self.init()
        self.title = title
        self.coordinate = coordinate
    }
}

struct MapView: UIViewRepresentable {
    
    @Binding var annotations: [MGLPointAnnotation]
    @Binding var selectedTrailId:Int64
    @EnvironmentObject var settings: AppSettings
    
    // var mapCenter = CLLocationCoordinate2D(latitude: 37.7666, longitude: -122.427290)
    var mapCenter: CLLocationCoordinate2D?
    var mapBounds: MGLCoordinateBounds?
    var zoomAnimation: Bool = false
    var features:FeatureToggles = FeatureToggles(displayTrails: false, allowTrailTaps: false, allowPOITaps: false)

    var styles: [URL] = [MGLStyle.outdoorsStyleURL, MGLStyle.satelliteStreetsStyleURL, MGLStyle.streetsStyleURL, AccuTerraStyle.vectorStyleURL]
    var styleId = 0
    // var mapTappingActive = false
 
    let mapView: AccuTerraMapView = AccuTerraMapView(frame: .zero, styleURL: MGLStyle.streetsStyleURL)
    
    // MARK: - Configuring UIViewRepresentable protocol
    
    func makeUIView(context: UIViewRepresentableContext<MapView>) -> AccuTerraMapView {
        print("makeUIView .... called")
        // Initialize map
        self.mapView.initialize(styleURL: styles[styleId])
        self.mapView.setUserTrackingMode(.follow, animated: true, completionHandler: {
        })
        self.mapView.isRotateEnabled = false //makes map interaction easier
        self.mapView.isPitchEnabled = false //makes map interaction easier
        
        mapView.accuTerraDelegate = context.coordinator
        mapView.delegate = context.coordinator
        mapView.trailLayersManager.delegate = context.coordinator
        return mapView
    }
    
    func updateUIView(_ uiView: AccuTerraMapView, context: UIViewRepresentableContext<MapView>) {
        if let bounds = mapBounds {
            uiView.zoomToExtent(bounds: bounds, animated: true)
        }
        else if let location = mapCenter {
            if zoomAnimation {
                let camera = MGLMapCamera(lookingAtCenter: location, altitude: 4500, pitch: 0, heading: 0)

                // Animate the camera movement over 5 seconds.
                uiView.setCamera(camera, withDuration: 5, animationTimingFunction: CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut))
            }
            else {
                uiView.zoomLevel = 10
                uiView.setCenter(location, animated: true)
            }
        }
        
        // updateAnnotations()
    }
    
    func styleURL(_ styleURL: URL) -> MapView {
        mapView.styleURL = styleURL
        return self
    }
    
    func makeCoordinator() -> MapCoordinator {
        MapCoordinator(self)
    }
    
    func centerCoordinate(_ centerCoordinate: CLLocationCoordinate2D) -> MapView {
        mapView.centerCoordinate = centerCoordinate
        return self
    }
    
    func zoomLevel(_ zoomLevel: Double) -> MapView {
        mapView.zoomLevel = zoomLevel
        return self
    }
    
//    private func updateAnnotations() {
//        if let currentAnnotations = mapView.annotations {
//            mapView.removeAnnotations(currentAnnotations)
//        }
//        mapView.addAnnotations(annotations)
//    }
    
}








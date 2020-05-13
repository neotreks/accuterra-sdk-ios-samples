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

struct MapView: UIViewRepresentable {
    
    @EnvironmentObject var env: AppEnvironment
    var initialState:MapInteractions = MapInteractions()
    var features:FeatureToggles = FeatureToggles(displayTrails: false, allowTrailTaps: false, allowPOITaps: false)
    @Binding var mapAlerts:MapAlertMessages
    
    var styles: [URL] = [MGLStyle.outdoorsStyleURL, MGLStyle.satelliteStreetsStyleURL, MGLStyle.streetsStyleURL, AccuTerraStyle.vectorStyleURL]
    var styleId = 0
    let mapView: AccuTerraMapView = AccuTerraMapView(frame: .zero, styleURL: MGLStyle.streetsStyleURL)
    var mapVm = MapViewModel()
    
    // MARK: - Configuring UIViewRepresentable protocol
    
    func makeUIView(context: UIViewRepresentableContext<MapView>) -> AccuTerraMapView {
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
        print("updateUIView .... bounds: \(String(describing: env.mapIntEnv.mapBounds))")
        print("updateUIView .... center: \(String(describing: env.mapIntEnv.mapCenter))")
        if let bounds = env.mapIntEnv.mapBounds {
            let extent = MGLCoordinateBounds(sw: bounds.sw.coordinates, ne: bounds.ne.coordinates)
            let insets = env.mapIntEnv.edgeInsets ??  UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
            uiView.zoomToExtent(bounds:extent, edgePadding:insets, animated: true)
        }
        else if let location = env.mapIntEnv.mapCenter {
            if env.mapIntEnv.zoomAnimation {
                let camera = MGLMapCamera(lookingAtCenter: location, altitude: 4500, pitch: 0, heading: 0)

                // Animate the camera movement over 5 seconds.
                uiView.setCamera(camera, withDuration: 5, animationTimingFunction: CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut))
            }
            else {
                uiView.zoomLevel = 10
                uiView.setCenter(location, animated: true)
            }
        }
        
        if env.mapIntEnv.selectedTrailId != 0 {
            uiView.trailLayersManager.setVisibleTrails(trailIds: Set<Int64>([env.mapIntEnv.selectedTrailId ]))
            uiView.trailLayersManager.highLightTrail(trailId: env.mapIntEnv.selectedTrailId )
        }
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
}








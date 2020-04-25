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
    
    // var mapCenter = CLLocationCoordinate2D(latitude: 37.7666, longitude: -122.427290)
    var mapCenter: CLLocationCoordinate2D?
    var mapBounds: MGLCoordinateBounds?
    var zoomAnimation: Bool = false
    var styles: [URL] = [MGLStyle.outdoorsStyleURL, MGLStyle.satelliteStreetsStyleURL, MGLStyle.streetsStyleURL, AccuTerraStyle.vectorStyleURL]
    var styleId = 0
 
    let mapView: AccuTerraMapView = AccuTerraMapView(frame: .zero, styleURL: MGLStyle.streetsStyleURL)
    
    // MARK: - Configuring UIViewRepresentable protocol
    
    func makeUIView(context: UIViewRepresentableContext<MapView>) -> AccuTerraMapView {
        mapView.accuTerraDelegate = context.coordinator
        mapView.delegate = context.coordinator
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
    }
    
    func styleURL(_ styleURL: URL) -> MapView {
        mapView.styleURL = styleURL
        return self
    }
    
    func makeCoordinator() -> MapView.Coordinator {
        Coordinator(self)
    }
    
    func centerCoordinate(_ centerCoordinate: CLLocationCoordinate2D) -> MapView {
        mapView.centerCoordinate = centerCoordinate
        return self
    }
    
    func initMap() -> MapView  {
        // Initialize map
        self.mapView.initialize(styleURL: styles[styleId])

        self.mapView.setUserTrackingMode(.follow, animated: true, completionHandler: {
        })
        self.mapView.isRotateEnabled = false //makes map interaction easier
        self.mapView.isPitchEnabled = false //makes map interaction easier
        
        return self
    }
}

extension MapView {
    
    class Coordinator: NSObject, AccuTerraMapViewDelegate, TrailLayersManagerDelegate, MGLMapViewDelegate {
                
        var controlView: MapView
        var mapWasLoaded : Bool = false
        var isTrailsLayerManagersLoaded = false
        var trailService: ITrailService?
        var trails: Array<TrailBasicInfo>?
        
        @ObservedObject var vm = TrailsViewModel()

        init(_ mapView: MapView) {
            self.controlView = mapView
        }
        
        func onStyleChanged() {}
        
        func onSignificantMapBoundsChange() {}
        
        func didTapOnMap(coordinate: CLLocationCoordinate2D) {}
        
        func onMapLoaded() {
            self.mapWasLoaded = true
            self.zoomToDefaultExtent()
            self.addTrailLayers()
        }
        
        func onLayersAdded(trailLayers: Array<TrailLayerType>) {
            isTrailsLayerManagersLoaded = true
        }
        
        private func zoomToDefaultExtent() {
            let bounds = MapInteraction.getColoradoBounds()
            controlView.mapView.zoomToExtent(bounds: bounds, animated: true)
        }
        
        private func addTrailLayers() {
            guard SdkManager.shared.isTrailDbInitialized else {
                return
            }
            let trailLayersManager = controlView.mapView.trailLayersManager

            trailLayersManager.delegate = self
            trailLayersManager.addStandardLayers()
            
        }
        
    }
}








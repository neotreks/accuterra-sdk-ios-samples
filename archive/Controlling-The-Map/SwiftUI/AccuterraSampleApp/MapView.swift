//
//  MapView.swift
//  Displaying-Trail-Details
//
//  Created by Brian Elliott on 3/8/20.
//  Copyright © 2020 Brian Elliott. All rights reserved.
//

import SwiftUI
import AccuTerraSDK
import Mapbox

struct MapView: UIViewRepresentable {
    
    var mapCenter: CLLocationCoordinate2D?
    var mapBounds: MGLCoordinateBounds?
    var zoomAnimation: Bool = false
 
    let mapView: AccuTerraMapView = AccuTerraMapView(frame: .zero)
    
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
    
    func makeCoordinator() -> MapView.Coordinator {
        Coordinator(self)
    }
    
    func centerCoordinate(_ centerCoordinate: CLLocationCoordinate2D) -> MapView {
        mapView.centerCoordinate = centerCoordinate
        return self
    }
    
    func initMap() -> MapView  {
        // Initialize map
        self.mapView.initialize()

        self.mapView.setUserTrackingMode(.follow, animated: true, completionHandler: {
        })
        self.mapView.isRotateEnabled = false //makes map interaction easier
        self.mapView.isPitchEnabled = false //makes map interaction easier
        
        return self
    }
}

extension MapView {
    
    class Coordinator: NSObject, AccuTerraMapViewDelegate, BaseMapLayersManagerDelegate,  MGLMapViewDelegate {
        
        var controlView: MapView
        var isBaseMapLayerManagersLoaded = false
        var mapWasLoaded : Bool = false

        init(_ mapView: MapView) {
            self.controlView = mapView
        }
        
        func didTapOnMap(coordinate: CLLocationCoordinate2D) {}
        
        func onMapLoaded() {
            self.mapWasLoaded = true
            self.zoomToDefaultExtent()
            self.addBaseMapLayer()
        }
        
        private func addBaseMapLayer() {
            let baseMapLayersManager = controlView.mapView.baseMapLayersManager
            baseMapLayersManager.delegate = self
            baseMapLayersManager.addLayer(baseLayer: BaseLayerType.RASTER_BASE_MAP)
        }
        
        private func zoomToDefaultExtent() {
            let bounds = MapInteraction.getColoradoBounds()
            controlView.mapView.zoomToExtent(bounds: bounds, animated: true)
        }
        
        func onLayerAdded(baseMapLayer: BaseLayerType) {
            isBaseMapLayerManagersLoaded = true
        }
    }
}







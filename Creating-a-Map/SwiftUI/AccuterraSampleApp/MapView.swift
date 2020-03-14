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
 
    let mapView: AccuTerraMapView = AccuTerraMapView(frame: .zero)
    
    // MARK: - Configuring UIViewRepresentable protocol
    
    func makeUIView(context: UIViewRepresentableContext<MapView>) -> AccuTerraMapView {
        mapView.accuTerraDelegate = context.coordinator
        mapView.delegate = context.coordinator
        return mapView
    }
    
    func updateUIView(_ uiView: AccuTerraMapView, context: UIViewRepresentableContext<MapView>) {
        // updateAnnotations()
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
    class Coordinator: NSObject, AccuTerraMapViewDelegate, BaseMapLayersManagerDelegate, TrailLayersManagerDelegate, MGLMapViewDelegate {
        
        var controlView: MapView
        var isBaseMapLayerManagersLoaded = false
        var mapWasLoaded : Bool = false
        var isTrailsLayerManagersLoaded = false
        var trailService: ITrailService?
        var trails: Array<TrailBasicInfo>?

        init(_ mapView: MapView) {
            self.controlView = mapView
        }
        
        func didTapOnMap(coordinate: CLLocationCoordinate2D) {}
        
        func onMapLoaded() {
            self.mapWasLoaded = true
            self.zoomToDefaultExtent()
            self.addBaseMapLayer()
        }
        
        func onLayersAdded(trailLayers: Array<TrailLayerType>) {
            isTrailsLayerManagersLoaded = true
        }
        
        private func addBaseMapLayer() {
            let baseMapLayersManager = controlView.mapView.baseMapLayersManager
            baseMapLayersManager.delegate = self
            baseMapLayersManager.addLayer(baseLayer: BaseLayerType.RASTER_BASE_MAP)
        }
        
        private func zoomToDefaultExtent() {
            // Colorado’s bounds
            let northeast = CLLocationCoordinate2D(latitude: 40.989329, longitude: -102.062592)
            let southwest = CLLocationCoordinate2D(latitude: 36.986207, longitude: -109.049896)
            let colorado = MGLCoordinateBounds(sw: southwest, ne: northeast)
            
            controlView.mapView.zoomToExtent(bounds: colorado, animated: true)
        }
        
        func onLayerAdded(baseMapLayer: BaseLayerType) {
            isBaseMapLayerManagersLoaded = true
        }
    }
}







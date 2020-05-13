//
//  MapView.swift
//  Creating-a-Map
//
//  Created by Brian Elliott on 5/3/20.
//  Copyright © 2020 NeoTreks, Inc. All rights reserved.
//

import SwiftUI
import AccuTerraSDK
import Mapbox

struct MapView: UIViewRepresentable {

    var selectedTrailId:Int64
    var defaultBounds:MapBounds?
    var mapAlerts:MapAlertMessages
    @EnvironmentObject var env: ViewRouter
    @Binding var resetMap:Bool
    
    var styles: [URL] = [MGLStyle.outdoorsStyleURL, MGLStyle.satelliteStreetsStyleURL, MGLStyle.streetsStyleURL, AccuTerraStyle.vectorStyleURL]
    var styleId = 0
    let mapView: AccuTerraMapView = AccuTerraMapView(frame: .zero, styleURL: MGLStyle.streetsStyleURL)
    
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
        if self.resetMap {
            if let bounds = self.defaultBounds {
                let extent = MGLCoordinateBounds(sw: bounds.sw.coordinates, ne: bounds.ne.coordinates)
                let insets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
                uiView.zoomToExtent(bounds:extent, edgePadding:insets, animated: true)
                DispatchQueue.main.async {
                    self.resetMap = false
                }
                return
            }
        }

        if self.selectedTrailId > 0 {
            uiView.trailLayersManager.highLightTrail(trailId: self.selectedTrailId)
            zoomToTrail(mapView: uiView, trailId: self.selectedTrailId)
        }
    }
    
    private func getCenterFromBounds(bounds:MapBounds) -> CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: (bounds.sw.latitude + bounds.ne.latitude) / 2,
                                      longitude: (bounds.sw.longitude + bounds.ne.longitude) / 2)
    }
        
    private func zoomToTrail(mapView: AccuTerraMapView, trailId: Int64) {
        self.mapView.trailLayersManager.setVisibleTrails(trailIds: Set<Int64>([trailId]))
        self.mapView.trailLayersManager.highLightTrail(trailId: trailId)
        do {
            if SdkManager.shared.isTrailDbInitialized {
                let trailsService = ServiceFactory.getTrailService()
                if let trail = try trailsService.getTrailById(trailId),
                    let locationInfo = trail.locationInfo {
                    self.zoomToTrail(mapView:mapView, locationInfo: locationInfo)
                }
            }

        }
        catch {
            print("\(error)")
        }
    }
    
    private func zoomToTrail(mapView: AccuTerraMapView, locationInfo: TrailLocationInfo) {
        let extent = MGLCoordinateBounds(sw: locationInfo.mapBounds.sw.coordinates, ne: locationInfo.mapBounds.ne.coordinates)
        mapView.zoomToExtent(bounds: extent, edgePadding: UIEdgeInsets(top: 50, left: 50, bottom: 50, right: 50), animated: true)
    }

    
    func makeCoordinator() -> MapView.Coordinator {
        Coordinator(self)
    }
    
    func centerCoordinate(_ centerCoordinate: CLLocationCoordinate2D) -> MapView {
        mapView.centerCoordinate = centerCoordinate
        return self
    }
    
}

extension MapView {
    class Coordinator: NSObject, AccuTerraMapViewDelegate, TrailLayersManagerDelegate, MGLMapViewDelegate {
                
        static let regionChangedNotification = NSNotification.Name("regionChangedNotification")
        
        var controlView: MapView
        var isBaseMapLayerManagersLoaded = false
        var mapWasLoaded : Bool = false
        var isTrailsLayerManagersLoaded = false
        var trailService: ITrailService?
        var previousBoundingBox: MapBounds?
        
        init(_ mapView: MapView) {
            self.controlView = mapView
            super.init()
        }
        
        private func resetMap(mapBounds:MapBounds) {
                let extent = MGLCoordinateBounds(sw: mapBounds.sw.coordinates, ne: mapBounds.ne.coordinates)
                let insets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
                controlView.mapView.zoomToExtent(bounds:extent, edgePadding:insets, animated: true)
        }
        
        func didTapOnMap(coordinate: CLLocationCoordinate2D) {
            guard self.isTrailsLayerManagersLoaded else {
                return
            }
            
            controlView.selectedTrailId = searchTrails(mapView: controlView.mapView, coordinate: coordinate)
        }
        
        func searchTrails(mapView:AccuTerraMapView, coordinate:CLLocationCoordinate2D) -> Int64 {
            let query = TrailsQuery(
                trailLayersManager: mapView.trailLayersManager,
                layers: Set(TrailLayerType.allValues),
                coordinate: coordinate,
                distanceTolerance: 2.0)

            let trailId = query.execute().trailIds.first
            if let id = trailId {
                return id
            }
            return 0
        }
        
        func onMapLoaded() {
            self.mapWasLoaded = true
            self.zoomToDefaultExtent()
            self.addTrailLayers()
        }
        
        func addTrailLayers() {
            guard SdkManager.shared.isTrailDbInitialized else {
                return
            }
            let trailLayersManager = controlView.mapView.trailLayersManager
            trailLayersManager.addStandardLayers()
            
        }
        
        func onLayersAdded(trailLayers: Array<TrailLayerType>) {
            isTrailsLayerManagersLoaded = true
        }
        
        private func zoomToDefaultExtent() {
            // Colorado’s bounds
            let northeast = CLLocationCoordinate2D(latitude: 40.989329, longitude: -102.062592)
            let southwest = CLLocationCoordinate2D(latitude: 36.986207, longitude: -109.049896)
            let colorado = MGLCoordinateBounds(sw: southwest, ne: northeast)
            
            controlView.mapView.zoomToExtent(bounds: colorado, animated: true)
        }
        
        func onStyleChanged() {}
        
        func onSignificantMapBoundsChange() {}
        
        func getMapBounds() throws -> MapBounds {
            let visibleRegion = controlView.mapView.visibleCoordinateBounds
            
            return try MapBounds(
                minLat: max(visibleRegion.sw.latitude, -90),
                minLon: max(visibleRegion.sw.longitude, -180),
                maxLat: min(visibleRegion.ne.latitude, 90),
                maxLon: min(visibleRegion.ne.longitude, 180))
        }
        
        func mapViewDidBecomeIdle(_ mapView: MGLMapView) {
            if let newBoundingBox = try? getMapBounds() {
                if let boundingBox = self.previousBoundingBox {
                    if boundingBox.equals(bounds: newBoundingBox) {
                        return
                    }
                }
                self.previousBoundingBox = newBoundingBox
                NotificationCenter.default.post(name: MapView.Coordinator.regionChangedNotification, object: newBoundingBox)
            }
        }
 
    }
}

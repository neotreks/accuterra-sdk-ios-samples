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
        
    var styles: [URL] = [MGLStyle.outdoorsStyleURL, MGLStyle.satelliteStreetsStyleURL, MGLStyle.streetsStyleURL, AccuTerraStyle.vectorStyleURL]
    var styleId = 0
    let mapView: AccuTerraMapView = AccuTerraMapView(frame: .zero, styleURL: MGLStyle.streetsStyleURL)
    @Binding var selectedTrailId:Int64
    @Binding var mapAlerts:MapAlertMessages
    
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
        if self.selectedTrailId != 0 {
            uiView.trailLayersManager.highLightTrail(trailId: self.selectedTrailId )
        }
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
                
        var controlView: MapView
        var isBaseMapLayerManagersLoaded = false
        var mapWasLoaded : Bool = false
        var isTrailsLayerManagersLoaded = false
        var trailService: ITrailService?

        init(_ mapView: MapView) {
            self.controlView = mapView
        }
        
        func didTapOnMap(coordinate: CLLocationCoordinate2D) {
            guard self.isTrailsLayerManagersLoaded else {
                return
            }
            
            if !searchPois(coordinate: coordinate) {
                controlView.selectedTrailId = searchTrails(mapView: controlView.mapView, coordinate: coordinate)
            }
        }
        
        func searchTrails(mapView:AccuTerraMapView, coordinate:CLLocationCoordinate2D) -> Int64 {
            let query = TrailsQuery(
                trailLayersManager: mapView.trailLayersManager,
                layers: Set(TrailLayerType.allValues),
                coordinate: coordinate,
                distanceTolerance: 2.0)

            let trailId = query.execute().trailIds.first
            if let id = trailId {
                showTrailPOIs(mapView: mapView, trailId: trailId)
                return id
            }
            return 0
        }
        
        private func showTrailPOIs(mapView: AccuTerraMapView, trailId: Int64?) {
            if let trailId = trailId {
                
                do {
                    if self.trailService == nil {
                        self.trailService = ServiceFactory.getTrailService()
                    }
                    
                    if let trailManager = self.trailService,
                        let trail = try trailManager.getTrailById(trailId) {
                            mapView.trailLayersManager.showTrailPOIs(trail: trail)
                    }
                }
                catch {
                    print("\(error)")
                }
            } else {
                mapView.trailLayersManager.hideAllTrailPOIs()
            }
        }
        
        func searchPois(coordinate: CLLocationCoordinate2D) -> Bool {
            let query = TrailPoisQuery(
                trailLayersManager: controlView.mapView.trailLayersManager,
                layers: Set(TrailPoiLayerType.allValues),
                coordinate: coordinate,
                distanceTolerance: 2.0)
                
            if let trailPoi = query.execute().trailPois.first, let poiId = trailPoi.poiIds.first {
                handleTrailPoiMapClick(trailId: trailPoi.trailId , poiId: poiId)
                return true
            } else {
                return false
            }
        }
        
        func handleTrailPoiMapClick(trailId: Int64, poiId: Int64) {
            do {
                if let trailManager = self.trailService,
                    let trail = try trailManager.getTrailById(trailId),
                    let poi = trail.navigationInfo?.mapPoints.first(where: { (point) -> Bool in
                        return point.id == poiId
                    }) {
                    controlView.mapAlerts.displayAlert = true
                    controlView.mapAlerts.title = poi.name ?? "POI"
                    controlView.mapAlerts.message = poi.description ?? ""
                }
            }
            catch {
                print("\(error)")
            }
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
        
    }
}

//
//  MapCoordinator.swift
//  AccuterraSampleApp
//
//  Created by Brian Elliott on 4/28/20.
//  Copyright © 2020 NeoTreks, Inc. All rights reserved.
//
import SwiftUI
import AccuTerraSDK
import Mapbox

class MapCoordinator: NSObject, AccuTerraMapViewDelegate, TrailLayersManagerDelegate {
            
    static let regionChangedNotification = NSNotification.Name("regionChangedNotification")
    
    var controlView: MapView
    var mapWasLoaded : Bool = false
    var isTrailsLayerManagersLoaded = false
    var trailsService: ITrailService?
    var trails: Array<TrailBasicInfo>?
//    var trailsFilter = TrailsFilter()
    var previousBoundingBox: MapBounds?
    
    init(_ mapView: MapView) {
        self.controlView = mapView
    }
    
    func mapView(_ mapView: MGLMapView, didFinishLoading style: MGLStyle) {
        
        let coordinates = [
            CLLocationCoordinate2D(latitude: 37.791329, longitude: -122.396906),
            CLLocationCoordinate2D(latitude: 37.791591, longitude: -122.396566),
            CLLocationCoordinate2D(latitude: 37.791147, longitude: -122.396009),
            CLLocationCoordinate2D(latitude: 37.790883, longitude: -122.396349),
            CLLocationCoordinate2D(latitude: 37.791329, longitude: -122.396906),
        ]
        
        let buildingFeature = MGLPolygonFeature(coordinates: coordinates, count: 5)
        let shapeSource = MGLShapeSource(identifier: "buildingSource", features: [buildingFeature], options: nil)
        mapView.style?.addSource(shapeSource)
        
        let fillLayer = MGLFillStyleLayer(identifier: "buildingFillLayer", source: shapeSource)
        fillLayer.fillColor = NSExpression(forConstantValue: UIColor.blue)
        fillLayer.fillOpacity = NSExpression(forConstantValue: 0.5)
        
        mapView.style?.addLayer(fillLayer)
    }
    
    func onStyleChanged() {}
    
    func onSignificantMapBoundsChange() {}
    
    func didTapOnMap(coordinate: CLLocationCoordinate2D) {
        guard self.isTrailsLayerManagersLoaded && controlView.features.allowTrailTaps else {
            return
        }
        
        if !searchPois(coordinate: coordinate) {
            controlView.mapInteractions.selectedTrailId = searchTrails(mapView: controlView.mapView, coordinate: coordinate)
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
            if let trailManager = self.trailsService,
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
            debugPrint("\(error)")
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
            // print("trail ID: \(id)")
            // trail will be hilighted by MapInteractions.selectedTrailId binding
            if controlView.features.allowPOITaps {
                self.showTrailPOIs(mapView: mapView, trailId: trailId)
            }
            return id
        }
        return 0
    }
    
    private func showTrailPOIs(mapView: AccuTerraMapView, trailId: Int64?) {
        if let trailId = trailId {
            
            do {
                if self.trailsService == nil {
                    trailsService = ServiceFactory.getTrailService()
                }
                
                if let trailManager = self.trailsService,
                    let trail = try trailManager.getTrailById(trailId) {
                        mapView.trailLayersManager.showTrailPOIs(trail: trail)
                }
            }
            catch {
                debugPrint("\(error)")
            }
        } else {
            mapView.trailLayersManager.hideAllTrailPOIs()
        }
    }
    
    func onMapLoaded() {
        self.mapWasLoaded = true
        self.zoomToDefaultExtent()
        if controlView.features.displayTrails {
            self.addTrailLayers()
        }
    }
    
    func onLayersAdded(trailLayers: Array<TrailLayerType>) {
        isTrailsLayerManagersLoaded = true
    }
    
    private func zoomToDefaultExtent() {
        let mapInteractions = controlView.mapVm.setColoradoBounds()
        if let bounds = mapInteractions.mapBounds {
            let extent = MGLCoordinateBounds(sw: bounds.sw.coordinates, ne: bounds.ne.coordinates)
            controlView.mapView.zoomToExtent(bounds:extent, animated: true)
        }
    }
    
    private func addTrailLayers() {
        guard SdkManager.shared.isTrailDbInitialized else {
            return
        }
        let trailLayersManager = controlView.mapView.trailLayersManager
        trailLayersManager.addStandardLayers()
        
    }

    
}

extension MapCoordinator : MGLMapViewDelegate {
    
    func mapView(_ mapView: MGLMapView, didChange mode: MGLUserTrackingMode, animated: Bool) {}
    
    func mapView(_ mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        // Always allow callouts to popup when annotations are tapped.
        return true
    }
    
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
            NotificationCenter.default.post(name: MapCoordinator.regionChangedNotification, object: newBoundingBox)
        }
    }
    
    func mapViewDidFailLoadingMap(_ mapView: MGLMapView, withError error: Error) {
        controlView.mapAlerts.displayAlert = true
        controlView.mapAlerts.title = "Map Loading Error"
        controlView.mapAlerts.message = "\(error)"
    }
    
    func mapViewRegionIsChanging(_ mapView: MGLMapView) {
        // print ("mapViewRegionIsChanging")
    }
    
}

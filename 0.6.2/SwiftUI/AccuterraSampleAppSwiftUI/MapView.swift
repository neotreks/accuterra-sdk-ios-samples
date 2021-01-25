//
//  MapView.swift
//  AccuterraSampleAppSwiftUI
//
//  Created by Rudolf Kopřiva on 15.01.2021.
//

import Foundation
import SwiftUI
import Mapbox
import AccuTerraSDK

struct MapView: UIViewRepresentable {
    
    let map = AccuTerraMapView(frame: .zero)
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }

    func makeUIView(context: UIViewRepresentableContext<MapView>) -> AccuTerraMapView {
        map.delegate = context.coordinator
        map.accuTerraDelegate = context.coordinator
        map.initialize(
            styleURL: AccuTerraStyle.vectorStyleURL,
            styleProvider: MyStyleProvider(mapStyle: AccuTerraStyle.vectorStyleURL))
        return map
    }

    func updateUIView(_ uiView: AccuTerraMapView, context: UIViewRepresentableContext<MapView>) {
    }
    
    func addTrails() throws {
        if (SdkManager.shared.isTrailDbInitialized) {
            try map.trailLayersManager.addStandardLayers()
        } else {
            // db is not initialized. Log, throw exception, and/or notify users here
        }
    }
    
    func zoomToDefaultExtent() {
        // Colorado’s bounds
        let northeast = CLLocationCoordinate2D(latitude: 40.989329, longitude: -102.062592)
        let southwest = CLLocationCoordinate2D(latitude: 36.986207, longitude: -109.049896)
        let colorado = MGLCoordinateBounds(sw: southwest, ne: northeast)
            
        map.zoomToExtent(bounds: colorado, animated: true)
    }
}

extension MapView {
    class Coordinator : NSObject, AccuTerraMapViewDelegate, MGLMapViewDelegate {
        
        private let view: MapView
        private let mapView: AccuTerraMapView
        init(_ view: MapView) {
            self.view = view
            self.mapView = view.map
        }
        
        func didTapOnMap(coordinate: CLLocationCoordinate2D) {
            do {
                try handleMapClick(coordinate)
            } catch {
                // Handle error
            }
        }
        
        private func handleMapClick(_ coordinate: CLLocationCoordinate2D) throws {
            var clickHandled = try handlePOIClicked(coordinate)

            if !clickHandled {
                clickHandled = try handleTrailClicked(coordinate)
            }
        }
        
        private func handlePOIClicked(_ coordinate: CLLocationCoordinate2D) throws -> Bool {
            let searchQuery = try TrailPoisQuery(trailLayersManager: mapView.trailLayersManager,
                                              layers: Set(TrailPoiLayerType.allValues),
                                              coordinate: coordinate, // the latitude/longitude clicked on map by user
                                              distanceTolerance: 5.0) // 5 pixel tolerance on click
            let poiSearchResult = try searchQuery.execute()
            
            if let poiResult = poiSearchResult.trailPois.first {
                let poiId = poiResult.poiIds.first
                
                if let trail =
                    try ServiceFactory
                    .getTrailService()
                    .getTrailById(poiResult.trailId) {
                    
                    if let poi =
                        trail.navigationInfo?.mapPoints.first(where: { (mapPoint) -> Bool in
                            return mapPoint.id == poiId
                        }) {
                        showPoiDialog(trail: trail, poi: poi)
                        return true
                    }
                }
            }
            return false
        }
        
        private func showPoiDialog(trail: Trail, poi: MapPoint) {
            let alertTitle = "\(trail.info.name): \(poi.name ?? "POI \(poi.id)")"

            let alertVC = UIAlertController(
                title: alertTitle,
                message: poi.description,
                preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "OK", style: .default) { (action: UIAlertAction) in
            }
            alertVC.addAction(okAction)
            
            let viewController = UIApplication.shared.windows.first?.rootViewController
            viewController?.present(alertVC, animated: true, completion: nil)
        }

        private func handleTrailClicked(_ coordinate: CLLocationCoordinate2D) throws -> Bool {
            let searchQuery = try TrailsQuery(trailLayersManager: mapView.trailLayersManager,
                                              layers: Set(TrailLayerType.allValues),
                                              coordinate: coordinate, // the latitude/longitude clicked on map by user
                                              distanceTolerance: 5.0) // 5 pixel tolerance on click
            let searchResult = try searchQuery.execute()
            switch searchResult.trailIds.count {
            case 0:
                try mapView.trailLayersManager.highLightTrail(trailId: nil)
                return false
            case 1:
                let trailId = searchResult.trailIds.first!
                try mapView.trailLayersManager.highLightTrail(trailId: trailId)
                try displayTrailPOIs(trailId)
                return true
            default:
                /* TODO: do something else when multiple trails are clicked */
                return false
            }
        }
        
        private func showDialogForTrail(_ trailId: Int64) throws {
            let trailService = ServiceFactory.getTrailService()
            
            if let trail = try trailService.getTrailById(trailId) {
                let alertVC = UIAlertController(
                    title: trail.info.name,
                    message: trail.info.highlights,
                    preferredStyle: .alert)
                
                let okAction = UIAlertAction(title: "OK", style: .default) { (action: UIAlertAction) in
                }
                alertVC.addAction(okAction)
                
                let viewController = UIApplication.shared.windows.first?.rootViewController
                viewController?.present(alertVC, animated: true, completion: nil)
            }
        }
        
        func displayTrailPOIs(_ trailId: Int64) throws {
            guard let trail = try ServiceFactory.getTrailService().getTrailById(trailId) else {
                // Handle trail not found
                return
            }

            mapView.trailLayersManager.showTrailPOIs(trail: trail)
        }
        
        func onMapLoaded() {
            view.zoomToDefaultExtent()
            try! view.addTrails()
        }
        
        func onStyleChanged() {
        }
        
        func onSignificantMapBoundsChange() {
        }
        
        func onTrackingModeChanged(mode: TrackingOption) {
        }
        
        private func loadTrailBasicInfo(trailId: Int64) throws -> TrailBasicInfo? {
            return try ServiceFactory.getTrailService().getTrailBasicInfoById(trailId)
        }
        
        private func loadFullTrail(trailId: Int64) throws -> Trail? {
            return try ServiceFactory.getTrailService().getTrailById(trailId)
        }
        
        private func zoomToTrail(trailId: Int64) throws {
            if let trail = try loadFullTrail(trailId: trailId), let trailBounds = trail.locationInfo?.mapBounds {
                mapView.trailLayersManager.setVisibleTrails(trailIds: [trail.info.id])
                
                mapView.zoomToBounds(targetBounds: trailBounds)
            }
        }
        
        private func zoomToTrailAndHighlight(trailId: Int64) throws {
            if let trail = try loadFullTrail(trailId: trailId), let trailBounds = trail.locationInfo?.mapBounds {
                mapView.trailLayersManager.setVisibleTrails(trailIds: [trail.info.id])
                mapView.trailLayersManager.showTrailPOIs(trail: trail)
                
                mapView.zoomToBounds(targetBounds: trailBounds)
            }
        }
    }
}

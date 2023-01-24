//
//  MapViewController.swift
//  AccuterraSampleAppUIKit
//
//  Created by Rudolf Kopřiva on 14.01.2021.
//

import UIKit
import AccuTerraSDK
import Mapbox

class MapViewController: UIViewController {
    
    @IBOutlet weak var mapView: AccuTerraMapView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.mapView.initialize(
            styleURL: AccuTerraStyle.vectorStyleURL,
            styleProvider: MyStyleProvider(mapStyle: AccuTerraStyle.vectorStyleURL))
    }
    
    private func zoomToDefaultExtent() {
        // Colorado’s bounds
        let northeast = CLLocationCoordinate2D(latitude: 40.989329, longitude: -102.062592)
        let southwest = CLLocationCoordinate2D(latitude: 36.986207, longitude: -109.049896)
        let colorado = MGLCoordinateBounds(sw: southwest, ne: northeast)
            
        mapView.zoomToExtent(bounds: colorado, animated: true)
    }

    private func addTrails() throws {
        if (SdkManager.shared.isTrailDbInitialized) {
            try mapView.trailLayersManager.addStandardLayers()
        } else {
            // db is not initialized. Log, throw exception, and/or notify users here
        }
    }
    
    private func searchTrails(searchString: String) throws -> [TrailBasicInfo] {
        let service = ServiceFactory.getTrailService()
        let searchCriteria = try TrailBasicSearchCriteria(searchString: searchString)

        return try service.findTrails(byBasicCriteria: searchCriteria)
    }
    
    private func searchTrailsAtCurrentMapPosition() throws -> [TrailBasicInfo] {
        let mapCameraPosition = mapView.camera.centerCoordinate

        let service = ServiceFactory.getTrailService()
        let criteria = TrailMapSearchCriteria(
            mapCenter: MapLocation(
                latitude: mapCameraPosition.latitude,
                longitude: mapCameraPosition.longitude))

        return try service.findTrails(byMapCriteria: criteria)
    }
    
    private func loadTrailBasicInfo(trailId: Int64) throws -> TrailBasicInfo? {
        return try ServiceFactory.getTrailService().getTrailBasicInfoById(trailId)
    }
    
    private func loadFullTrail(trailId: Int64) throws -> Trail? {
        return try ServiceFactory.getTrailService().getTrailById(trailId)
    }
    
    private func zoomToTrail(trailId: Int64) throws {
        if let trail = try loadFullTrail(trailId: trailId) {
            let trailBounds = trail.locationInfo.mapBounds
            mapView.trailLayersManager.setVisibleTrails(trailIds: [trail.info.id])
            
            mapView.zoomToBounds(targetBounds: trailBounds)
        }
    }
    
    private func zoomToTrailAndHighlight(trailId: Int64) throws {
        if let trail = try loadFullTrail(trailId: trailId) {
            let trailBounds = trail.locationInfo.mapBounds
            mapView.trailLayersManager.setVisibleTrails(trailIds: [trail.info.id])
            mapView.trailLayersManager.showTrailPOIs(trail: trail)
            
            let bounds: MGLCoordinateBounds = MGLCoordinateBoundsMake(trailBounds.sw.coordinates, trailBounds.ne.coordinates)
            
            mapView.zoomToExtent(
                bounds: bounds,
                animated: true)
        }
    }
}

extension MapViewController : AccuTerraMapViewDelegate {
    func didTapOnMap(coordinate: CLLocationCoordinate2D) {
        do {
            try handleMapClick(coordinate)
        } catch {
            // Handle error
        }
        
        let mediaService = ServiceFactory.getMediaCache()
        let statistics = try! mediaService.getMediaCacheStatistics()
        debugPrint("Number of cached files: \(statistics.cachedFilesCount)")
        debugPrint("Cache size in bytes: \(statistics.cachedFilesSize)")
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

        self.present(alertVC, animated: true, completion: nil)
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

            self.present(alertVC, animated: true, completion: nil)
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
        self.zoomToDefaultExtent()
        try? addTrails()
    }
    
    func onStyleChanged() {
    }
    
    func onSignificantMapBoundsChange() {
    }
    
    func onTrackingModeChanged(mode: TrackingOption) {
    }

    func onMapLoadFailed(error: Error) {

    }

    func onStyleChangeFailed(error: Error) {
        
    }
}

extension MapViewController : MGLMapViewDelegate {
    func mapViewDidFailLoadingMap(_ mapView: MGLMapView, withError error: Error) {
        debugPrint("\(error)")
    }
    
}


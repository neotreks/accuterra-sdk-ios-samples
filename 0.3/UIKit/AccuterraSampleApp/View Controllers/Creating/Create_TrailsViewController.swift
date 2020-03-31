//
//  Create_TrailsViewController.swift
//  AccuterraSampleApp
//
//  Created by Brian Elliott on 3/30/20.
//  Copyright © 2020 BaseMap. All rights reserved.
//

import UIKit
import AccuTerraSDK
import Mapbox

class Create_TrailsViewController: UIViewController {

    @IBOutlet weak var mapView: AccuTerraMapView!
    private let appTitle = "Adding Trails"
    var isTrailsLayerManagersLoaded = false
    var mapWasLoaded : Bool = false
    var styles: [URL] = [MGLStyle.outdoorsStyleURL, MGLStyle.satelliteStreetsStyleURL, MGLStyle.streetsStyleURL, AccuTerraStyle.vectorStyleURL]
    var styleId = 0
    var trailsService: ITrailService?
    var trails: Array<TrailBasicInfo>?
    var currentBounds:MapBounds? = try? MapBounds( minLat: 37.99906, minLon: -109.04265, maxLat: 41.00097, maxLon: -102.04607)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initMap()
    }
    
    func initMap() {

        // Initialize map
        self.mapView.initialize(styleURL: styles[styleId])

        self.mapView.setUserTrackingMode(.follow, animated: true, completionHandler: {
        })
        self.mapView.isRotateEnabled = false //makes map interaction easier
        self.mapView.isPitchEnabled = false //makes map interaction easier
    }
    
    private func zoomToMapExtents() {
        // Colorado’s bounds
        let northeast = CLLocationCoordinate2D(latitude: 40.989329, longitude: -102.062592)
        let southwest = CLLocationCoordinate2D(latitude: 36.986207, longitude: -109.049896)
        let colorado = MGLCoordinateBounds(sw: southwest, ne: northeast)

        mapView.zoomToExtent(bounds: colorado, animated: true)
    }
    
    func searchTrails(searchText:String?) {
        
        guard SdkManager.shared.isTrailDbInitialized else {
            return
        }
        
        do {
            if self.trailsService == nil {
                trailsService = ServiceFactory.getTrailService()
            }
            
            if let trailManager = self.trailsService {
                let criteria = try TrailBasicSearchCriteria(searchString: searchText, limit: 20)
                let trails = try trailManager.findTrails(byBasicCriteria: criteria)
                if trails.count > 0 {
                    self.trails = trails
                }
            }
        }
        catch {
            debugPrint("\(error)")
        }
    }
    
    func getMapBounds() throws -> MapBounds {
        let visibleRegion = self.mapView.visibleCoordinateBounds
        
        return try MapBounds(
            minLat: max(visibleRegion.sw.latitude, -90),
            minLon: max(visibleRegion.sw.longitude, -180),
            maxLat: min(visibleRegion.ne.latitude, 90),
            maxLon: min(visibleRegion.ne.longitude, 180))
    }
    
    func searchTrails() -> Set<Int64> {
        
        guard SdkManager.shared.isTrailDbInitialized else {
            return Set<Int64>()
        }
        
        do {
        
            if self.trailsService == nil {
                trailsService = ServiceFactory.getTrailService()
            }
            
            if let bounds = try? getMapBounds() {
                let searchCriteria = TrailMapBoundsSearchCriteria(
                    mapBounds: bounds,
                    nameSearchString: nil,
                    techRating: nil,
                    userRating: nil,
                    length: nil,
                    orderBy: OrderBy(),
                    limit: Int(INT32_MAX))
                trails = try trailsService!.findTrails(byMapBoundsCriteria: searchCriteria)
            }
        } catch {
            debugPrint("\(error)")
        }
        
        if let filteredTrailIds = trails?.map({ (trail) -> Int64 in
            return trail.id
        }) {
            return Set<Int64>(filteredTrailIds)
        } else {
            return Set<Int64>()
        }
    }
}

extension Create_TrailsViewController : TrailLayersManagerDelegate {
    func onLayersAdded(trailLayers: Array<TrailLayerType>) {
        isTrailsLayerManagersLoaded = true
        if let trails = self.trails, trails.count > 0 {
            var trailIds:Array<Int64> = []
            for trail in trails {
                trailIds.append(trail.id)
            }
            mapView.trailLayersManager.setVisibleTrails(trailIds: Set<Int64>(trailIds))
        }
    }
}

extension Create_TrailsViewController : AccuTerraMapViewDelegate {
    func onStyleChanged() {}
    
    func didTapOnMap(coordinate: CLLocationCoordinate2D) {}
        
    func onMapLoaded() {
        self.mapWasLoaded = true
        self.zoomToMapExtents()
        self.addTrailLayers()
    }
    
    private func addTrailLayers() {
        guard SdkManager.shared.isTrailDbInitialized else {
            return
        }
        let trailLayersManager = mapView.trailLayersManager

        trailLayersManager.delegate = self
        trailLayersManager.addStandardLayers()
    }
}

extension Create_TrailsViewController : MGLMapViewDelegate {
    
    func mapViewDidBecomeIdle(_ mapView: MGLMapView) {
        if let newBounds = try? getMapBounds() {
            if let previousBounds = self.currentBounds {
                if previousBounds.equals(bounds: newBounds) {
                    return
                }
                self.currentBounds = newBounds
                let visibleTrails = self.searchTrails()
                self.mapView.trailLayersManager.setVisibleTrails(trailIds: visibleTrails)
            }
        }
    }
    
    func mapViewDidFailLoadingMap(_ mapView: MGLMapView, withError error: Error) {
        debugPrint("Map Loading Error: \(error)")
    }
}

//
//  Create_POIsViewController.swift
//  AccuterraSampleApp
//
//  Created by Brian Elliott on 3/30/20.
//  Copyright © 2020 NeoTreks, Inc. All rights reserved.
//

import UIKit
import AccuTerraSDK
import Mapbox

class Create_POIsViewController: UIViewController {
    
    @IBOutlet weak var mapView:AccuTerraMapView!

    var isTrailsLayerManagersLoaded = false
    var mapWasLoaded : Bool = false
    var styles: [URL] = [MGLStyle.outdoorsStyleURL, MGLStyle.satelliteStreetsStyleURL, MGLStyle.streetsStyleURL, AccuTerraStyle.vectorStyleURL]
    var styleId = 0
    var trailService: ITrailService?
    var trails: Array<TrailBasicInfo>?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Adding POIs"
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
    
    func zoomToDefaultExtent() {
        // Colorado’s bounds
        let northeast = CLLocationCoordinate2D(latitude: 40.989329, longitude: -102.062592)
        let southwest = CLLocationCoordinate2D(latitude: 36.986207, longitude: -109.049896)
        let colorado = MGLCoordinateBounds(sw: southwest, ne: northeast)
        
        mapView.zoomToExtent(bounds: colorado, animated: true)
    }
    
    func doTrailsSearch() {
        do {
            if self.trailService == nil {
                self.trailService = ServiceFactory.getTrailService()
            }
            
            let searchCriteria = try? TrailBasicSearchCriteria(
                searchString: nil,
                limit: Int(INT32_MAX))
            if let service = trailService, let criteria = searchCriteria {
                self.trails = try service.findTrails(byBasicCriteria: criteria)
            }
        }
        catch {
            debugPrint("\(error)")
        }
    }
}

extension Create_POIsViewController : TrailLayersManagerDelegate {
    func onLayersAdded(trailLayers: Array<TrailLayerType>) {
        isTrailsLayerManagersLoaded = true
    }
}

extension Create_POIsViewController : AccuTerraMapViewDelegate {
    
    func onSignificantMapBoundsChange() {}
    
    func onStyleChanged() {}
    
    func didTapOnMap(coordinate: CLLocationCoordinate2D) {
        guard self.isTrailsLayerManagersLoaded else {
            return
        }
        
        let _ = searchTrails(coordinate: coordinate)
    }
    
    func handleTrailMapClick(trailId: Int64?) {
        mapView.trailLayersManager.highLightTrail(trailId: trailId)
        self.showTrailPOIs(trailId: trailId)
    }
    
    private func showTrailPOIs(trailId: Int64?) {
        if let trailId = trailId {
            do {
                if let trailManager = self.trailService,
                    let trail = try trailManager.getTrailById(trailId) {
                        self.mapView.trailLayersManager.showTrailPOIs(trail: trail)
                }
            }
            catch {
                debugPrint("\(error)")
            }
        } else {
            self.mapView.trailLayersManager.hideAllTrailPOIs()
        }
    }
        
    func onMapLoaded() {
        self.mapWasLoaded = true
        self.zoomToDefaultExtent()
        self.addTrailLayers()
    }
    
    private func addTrailLayers() {
        guard SdkManager.shared.isTrailDbInitialized else {
            return
        }
        let trailLayersManager = mapView.trailLayersManager

        trailLayersManager.delegate = self
        trailLayersManager.addStandardLayers()
        
        self.doTrailsSearch()
    }
    
    func searchTrails(coordinate: CLLocationCoordinate2D) -> Bool {
        let query = TrailsQuery(
            trailLayersManager: mapView.trailLayersManager,
            layers: Set(TrailLayerType.allValues),
            coordinate: coordinate,
            distanceTolerance: 2.0)
        
        let trailId = query.execute().trailIds.first
        handleTrailMapClick(trailId: trailId)
        
        return trailId != nil
    }
}

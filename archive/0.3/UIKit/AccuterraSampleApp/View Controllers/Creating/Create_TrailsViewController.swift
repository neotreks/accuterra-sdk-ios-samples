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
    @IBOutlet weak var statusLabel: UILabel!
    
    var isTrailsLayerManagersLoaded = false
    var mapWasLoaded : Bool = false
    var styles: [URL] = [MGLStyle.outdoorsStyleURL, MGLStyle.satelliteStreetsStyleURL, MGLStyle.streetsStyleURL, AccuTerraStyle.vectorStyleURL]
    var styleId = 0
    var trailService: ITrailService?
    var trails: Array<TrailBasicInfo>?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Adding Trails"
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

extension Create_TrailsViewController : TrailLayersManagerDelegate {
    func onLayersAdded(trailLayers: Array<TrailLayerType>) {
        isTrailsLayerManagersLoaded = true
    }
}

extension Create_TrailsViewController : AccuTerraMapViewDelegate {
    
    func onSignificantMapBoundsChange() {}
    
    func onStyleChanged() {}
    
    func didTapOnMap(coordinate: CLLocationCoordinate2D) {}
        
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
        if let count = self.trails?.count {
            statusLabel.text = "Trail Count: \(count)"
        }
    }
}

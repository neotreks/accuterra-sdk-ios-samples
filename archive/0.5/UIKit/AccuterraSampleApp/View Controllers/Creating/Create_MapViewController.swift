//
//  Create_MapViewController.swift
//  AccuterraSampleApp
//
//  Created by Brian Elliott on 3/30/20.
//  Copyright © 2020 NeoTreks, Inc. All rights reserved.
//

import UIKit
import AccuTerraSDK
import Mapbox

class Create_MapViewController: UIViewController {

    @IBOutlet weak var mapView: AccuTerraMapView!
    
    var isTrailsLayerManagersLoaded = false
    var mapWasLoaded : Bool = false
    var styles: [URL] = [MGLStyle.outdoorsStyleURL, MGLStyle.satelliteStreetsStyleURL, MGLStyle.streetsStyleURL, AccuTerraStyle.vectorStyleURL]
    var styleId = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Create a Map"
        // Initialize map
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
}

extension Create_MapViewController : TrailLayersManagerDelegate {
    func onLayersAdded(trailLayers: Array<TrailLayerType>) {
        isTrailsLayerManagersLoaded = true
    }
}

extension Create_MapViewController : AccuTerraMapViewDelegate {
    
    func onSignificantMapBoundsChange() {}
    
    func onStyleChanged() {}
    
    func didTapOnMap(coordinate: CLLocationCoordinate2D) {}
        
    func onMapLoaded() {
        self.mapWasLoaded = true
        self.zoomToDefaultExtent()
    }
}

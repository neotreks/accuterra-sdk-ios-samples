//
//  ViewController.swift
//  Create-A-Map
//
//  Created by Brian Elliott on 2/28/20.
//  Copyright © 2020 BaseMap. All rights reserved.
//

import UIKit
import Mapbox
import AccuTerraSDK

class ViewController: UIViewController {

    @IBOutlet weak var mapView: AccuTerraMapView!
    var isBaseMapLayerManagersLoaded = false
    var mapWasLoaded : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialize map
        self.mapView?.initialize()
    }
    
    private func zoomToDefaultExtent() {
        // Colorado’s bounds
        let northeast = CLLocationCoordinate2D(latitude: 40.989329, longitude: -102.062592)
        let southwest = CLLocationCoordinate2D(latitude: 36.986207, longitude: -109.049896)
        let colorado = MGLCoordinateBounds(sw: southwest, ne: northeast)
        
        mapView.zoomToExtent(bounds: colorado, animated: true)
    }
}

extension ViewController : BaseMapLayersManagerDelegate {
    func onLayerAdded(baseMapLayer: BaseLayerType) {
        isBaseMapLayerManagersLoaded = true
    }
}

extension ViewController : AccuTerraMapViewDelegate {
    func didTapOnMap(coordinate: CLLocationCoordinate2D) {}
    
    func onMapLoaded() {
        self.mapWasLoaded = true
        self.zoomToDefaultExtent()
        self.addBaseMapLayer()
    }
    
    private func addBaseMapLayer() {
        let baseMapLayersManager = self.mapView?.baseMapLayersManager
        baseMapLayersManager?.delegate = self
        baseMapLayersManager?.addLayer(baseLayer: BaseLayerType.RASTER_BASE_MAP)
    }
}



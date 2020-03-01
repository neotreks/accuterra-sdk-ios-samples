//
//  ViewController.swift
//  Controlling-The-Map
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
        self.mapView.isRotateEnabled = false //makes map interaction easier
        self.mapView.isPitchEnabled = false //makes map interaction easier
    }
    
    @IBAction func goToStateTapped(_ sender: Any) {
        zoomToCO()
    }
    
    @IBAction func goToCityOneTapped(_ sender: Any) {
        goToDenver()
    }
    
    @IBAction func goToCityTwoTapped(_ sender: Any) {
        goToCastleRock()
    }
    
    private func zoomToCO() {
        // Colorado’s bounds
        let northeast = CLLocationCoordinate2D(latitude: 40.989329, longitude: -102.062592)
        let southwest = CLLocationCoordinate2D(latitude: 36.986207, longitude: -109.049896)
        let colorado = MGLCoordinateBounds(sw: southwest, ne: northeast)

        mapView.zoomToExtent(bounds: colorado, animated: true)
    }
    
    private func goToCastleRock() {
        let center = CLLocationCoordinate2D(latitude: 39.3722, longitude: -104.8561)
        let camera = MGLMapCamera(lookingAtCenter: center, altitude: 4500, pitch: 0, heading: 0)
         
        // Animate the camera movement over 5 seconds.
        mapView.setCamera(camera, withDuration: 5, animationTimingFunction: CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut))
    }
    
    private func goToDenver() {
        let center = CLLocationCoordinate2D(latitude: 39.7392, longitude: -104.9903)
        mapView.zoomLevel = 10
        mapView.setCenter(center, animated: true)
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
        self.zoomToCO()
        // self.goToCityOne()
        self.addBaseMapLayer()
    }
    
    private func addBaseMapLayer() {
        let baseMapLayersManager = self.mapView?.baseMapLayersManager
        baseMapLayersManager?.delegate = self
        baseMapLayersManager?.addLayer(baseLayer: BaseLayerType.RASTER_BASE_MAP)
    }
}


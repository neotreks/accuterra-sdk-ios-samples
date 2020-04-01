//
//  Controling_MapViewController.swift
//  AccuterraSampleApp
//
//  Created by Brian Elliott on 3/30/20.
//  Copyright © 2020 BaseMap. All rights reserved.
//

import UIKit
import AccuTerraSDK
import Mapbox

class Controling_MapViewController: UIViewController {

    @IBOutlet weak var mapView: AccuTerraMapView!
    
    var isTrailsLayerManagersLoaded = false
    var mapWasLoaded : Bool = false
    var styles: [URL] = [MGLStyle.outdoorsStyleURL, MGLStyle.satelliteStreetsStyleURL, MGLStyle.streetsStyleURL, AccuTerraStyle.vectorStyleURL]
    var styleId = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Controlling the Map"
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
    
    private func zoomToDefaultExtent() {
        // Colorado’s bounds
        let northeast = CLLocationCoordinate2D(latitude: 40.989329, longitude: -102.062592)
        let southwest = CLLocationCoordinate2D(latitude: 36.986207, longitude: -109.049896)
        let colorado = MGLCoordinateBounds(sw: southwest, ne: northeast)
            
        mapView.zoomToExtent(bounds: colorado, animated: true)
    }
    
    @IBAction func coloradoButtonTapped(_ sender: Any) {
        zoomToCO()
    }
    
    @IBAction func denverButtonTapped(_ sender: Any) {
        goToDenver()
    }
    
    @IBAction func castleRockButtonTapped(_ sender: Any) {
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

extension Controling_MapViewController : TrailLayersManagerDelegate {
    func onLayersAdded(trailLayers: Array<TrailLayerType>) {
        isTrailsLayerManagersLoaded = true
    }
}

extension Controling_MapViewController : AccuTerraMapViewDelegate {
    
    func onSignificantMapBoundsChange() {}
    
    func onStyleChanged() {}
    
    func didTapOnMap(coordinate: CLLocationCoordinate2D) {}
        
    func onMapLoaded() {
        self.mapWasLoaded = true
        self.self.zoomToCO()
    }
}

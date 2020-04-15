//
//  Create_DetailsViewController.swift
//  AccuterraSampleApp
//
//  Created by Brian Elliott on 3/30/20.
//  Copyright © 2020 BaseMap. All rights reserved.
//

import UIKit
import AccuTerraSDK
import Mapbox

class Create_DetailsViewController: UIViewController {
    
    @IBOutlet weak var mapView: AccuTerraMapView!
    @IBOutlet weak var trailIdLabel: UILabel!
    
    var isTrailsLayerManagersLoaded = false
    var mapWasLoaded : Bool = false
    var styles: [URL] = [MGLStyle.outdoorsStyleURL, MGLStyle.satelliteStreetsStyleURL, MGLStyle.streetsStyleURL, AccuTerraStyle.vectorStyleURL]
    var styleId = 0
    var trailService: ITrailService?
    var trails: Array<TrailBasicInfo>?
    var trailId: Int64?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Trail Details"
        initMap()
    }
    
    @IBAction func detailsTapped(_ sender: Any) {
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let trailDetailsViewController = segue.destination as? TrailDetailsViewController {
            trailDetailsViewController.trailId = self.trailId
        }
    }
}

extension Create_DetailsViewController : TrailLayersManagerDelegate {
    func onLayersAdded(trailLayers: Array<TrailLayerType>) {
        isTrailsLayerManagersLoaded = true
    }
}

extension Create_DetailsViewController : AccuTerraMapViewDelegate {
    
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
    }
    
    func searchTrails(coordinate: CLLocationCoordinate2D) -> Bool {
        let query = TrailsQuery(
            trailLayersManager: mapView.trailLayersManager,
            layers: Set(TrailLayerType.allValues),
            coordinate: coordinate,
            distanceTolerance: 2.0)
        
        let trailId = query.execute().trailIds.first
        if let id = trailId {
            trailIdLabel.text = "Trail ID: \(String(id))"
            self.trailId = id
        }
        else {
            trailIdLabel.text = "Trail ID: "
        }
        
        handleTrailMapClick(trailId: trailId)
        
        return trailId != nil
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
}

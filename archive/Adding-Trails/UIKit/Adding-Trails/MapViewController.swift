//
//  MapController.swift
//  Adding-Trails
//
//  Created by Brian Elliott on 2/28/20.
//  Copyright © 2020 BaseMap. All rights reserved.
//

import UIKit
import Mapbox
import AccuTerraSDK

class MapViewController: UIViewController {

    @IBOutlet weak var mapView: AccuTerraMapView!
    @IBOutlet weak var statusLabel: UILabel!
    
    var isBaseMapLayerManagersLoaded = false
    var mapWasLoaded : Bool = false
    var isTrailsLayerManagersLoaded = false
    var trailService: ITrailService?
    var trails: Array<TrailBasicInfo>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.hidesBackButton = true
        navigationItem.title = "AccuTerra SDK"
        
        print("version: \(SdkInfo.version) - \(SdkInfo.versionName)")
        
        initMap()
        setStatus()
    }
    
    private func zoomToMapExtents() {
        // Colorado’s bounds
        let northeast = CLLocationCoordinate2D(latitude: 40.989329, longitude: -102.062592)
        let southwest = CLLocationCoordinate2D(latitude: 36.986207, longitude: -109.049896)
        let colorado = MGLCoordinateBounds(sw: southwest, ne: northeast)

        mapView.zoomToExtent(bounds: colorado, animated: true)
    }
    
    private func setStatus() {
        guard SdkManager.shared.isTrailDbInitialized else {
            self.statusLabel.text = "Trail DB not initialized"
            return
        }
        self.statusLabel.text = "Trails DB Installed"
    }

    func initMap() {
        if SdkManager.shared.isTrailDbInitialized {
            self.trailService = ServiceFactory.getTrailService()
        }

        // Initialize map
        self.mapView.initialize()

        self.mapView.setUserTrackingMode(.follow, animated: true, completionHandler: {
        })
        self.mapView.isRotateEnabled = false //makes map interaction easier
        self.mapView.isPitchEnabled = false //makes map interaction easier
    }
    
    func doTrailsSearch() {
        do {
            if self.trailService == nil {
                trailService = ServiceFactory.getTrailService()
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

extension MapViewController : TrailLayersManagerDelegate {
    func onLayersAdded(trailLayers: Array<TrailLayerType>) {
        isTrailsLayerManagersLoaded = true
    }
}

extension MapViewController : BaseMapLayersManagerDelegate {
    func onLayerAdded(baseMapLayer: BaseLayerType) {
        isBaseMapLayerManagersLoaded = true
    }
}

extension MapViewController : AccuTerraMapViewDelegate {
    func didTapOnMap(coordinate: CLLocationCoordinate2D) {}
    
    func onMapLoaded() {
        self.mapWasLoaded = true
        self.zoomToMapExtents()
        self.addBaseMapLayer()
        self.addTrailLayers()
    }
    
    private func addBaseMapLayer() {
        let baseMapLayersManager = self.mapView?.baseMapLayersManager
        baseMapLayersManager?.delegate = self
        baseMapLayersManager?.addLayer(baseLayer: BaseLayerType.RASTER_BASE_MAP)
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
            self.statusLabel.text = "Trail Count: \(count)"
        }
    }
}


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
    @IBOutlet weak var trailIdLabel: UILabel!
    
    var isBaseMapLayerManagersLoaded = false
    var mapWasLoaded : Bool = false
    var isTrailsLayerManagersLoaded = false
    var trailService: ITrailService?
    var trails: Array<TrailBasicInfo>?
    var trailId: Int64?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.hidesBackButton = true
        navigationItem.title = "AccuTerra SDK"
        
        print("version: \(SdkInfo.version) - \(SdkInfo.versionName)")
        
        initMap()
        setStatus()
    }
    
    @IBAction func detailsButtonTapped(_ sender: Any) {
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
            print("Trail DB not initialized")
            return
        }
        print("Trails DB Installed")
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
            print("\(error)")
        }
    }
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if let trailDetailsViewController = segue.destination as? TrailDetailsViewController {
//            trailDetailsViewController.trailId = self.trailId
//        }
//    }
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
    
    func didTapOnMap(coordinate: CLLocationCoordinate2D) {
        guard self.isTrailsLayerManagersLoaded else {
            return
        }
        
        if !searchPois(coordinate: coordinate) {
            let _ = searchTrails(coordinate: coordinate)
        }
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
    
    func handleTrailMapClick(trailId: Int64?) {
        mapView.trailLayersManager.highLightTrail(trailId: trailId)
        self.showTrailPOIs(trailId: trailId)
    }
    
    func handleTrailPoiMapClick(trailId: Int64, poiId: Int64) {
        do {
            if let trailManager = self.trailService,
                let trail = try trailManager.getTrailById(trailId),
                let poi = trail.navigationInfo?.mapPoints.first(where: { (point) -> Bool in
                    return point.id == poiId
                }) {
                let alert = UIAlertController(title: poi.name, message: poi.description ?? "", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: false, completion: nil)
            }
        }
        catch {
            print("\(error)")
        }
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
    
    func searchPois(coordinate: CLLocationCoordinate2D) -> Bool {
        let query = TrailPoisQuery(
            trailLayersManager: mapView.trailLayersManager,
            layers: Set(TrailPoiLayerType.allValues),
            coordinate: coordinate,
            distanceTolerance: 2.0)
        
        if let trailPoi = query.execute().trailPois.first, let poiId = trailPoi.poiIds.first {
            handleTrailPoiMapClick(trailId: trailPoi.trailId , poiId: poiId)
            return true
        } else {
            return false
        }
    }
    
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
    }
}




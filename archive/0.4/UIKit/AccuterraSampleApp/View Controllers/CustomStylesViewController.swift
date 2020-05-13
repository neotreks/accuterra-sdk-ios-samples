//
//  CustomStylesViewController.swift
//  AccuterraSampleApp
//
//  Created by Brian Elliott on 4/14/20.
//  Copyright © 2020 NeoTreks, Inc. All rights reserved.
//

import UIKit
import AccuTerraSDK
import Mapbox

class CustomStylesViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var mapView: AccuTerraMapView!
    @IBOutlet weak var baseMapPickerView: UIPickerView!
    
    var isTrailsLayerManagersLoaded = false
    var mapWasLoaded : Bool = false
    var styleId = 0
    var trailService: ITrailService?
    var trails: Array<TrailBasicInfo>?
    var baseMapTypes = ["Mapbox Outdoors", "Mapbox Satellite", "Mapbox Streets", "AccuTerra"]
    var styles: [URL] = [MGLStyle.outdoorsStyleURL, MGLStyle.satelliteStreetsStyleURL, MGLStyle.streetsStyleURL, AccuTerraStyle.vectorStyleURL]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Custom Trail & POI Styles"
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
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        baseMapTypes.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
            return baseMapTypes[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if row >= 0 && row < styles.count {
            setMapStyle(style: styles[row], provider:getStyleProvider(style: styles[row]))
        }
    }
    
    func setMapStyle(style: URL, provider: IAccuTerraStyleProvider?) {
        self.mapView.setStyle(styleURL: style, styleProvider:provider)
    }
    
    func getStyleProvider(style: URL) -> IAccuTerraStyleProvider? {
        if isSatellite(style: style) {
            return AccuTerraSatelliteStyleProvider(mapStyle:style)
        }
        else {
            return AccuTerraStyleProvider(mapStyle:style)
        }
    }
    
    func isSatellite(style:URL) -> Bool {
        if let _ = style.absoluteString.range(of: "satellite-streets", options: .caseInsensitive) {
            return true
        }
        else {
            return false
        }
    }
}

extension CustomStylesViewController : TrailLayersManagerDelegate {
    func onLayersAdded(trailLayers: Array<TrailLayerType>) {
        isTrailsLayerManagersLoaded = true
    }
}

extension CustomStylesViewController : AccuTerraMapViewDelegate {
    
    func onSignificantMapBoundsChange() {}
    
    func onStyleChanged() {
        
    }
    
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

//
//  List-to-MapViewController.swift
//  AccuterraSampleApp
//
//  Created by Brian Elliott on 3/20/20.
//  Copyright © 2020 BaseMap. All rights reserved.
//

import UIKit
import AccuTerraSDK
import Mapbox

class List_to_MapViewController: BaseViewController {

    @IBOutlet weak var mapView: AccuTerraMapView!
    @IBOutlet weak var tableView: UITableView!
    
    var isTrailsLayerManagersLoaded = false
    var mapWasLoaded : Bool = false
    var trailsFilter = TrailsFilter()
    var trailsService: ITrailService?
    var trails: Array<TrailBasicInfo>?
    private let cellReuseIdentifier: String = "Cell"

    var styles: [URL] = [MGLStyle.outdoorsStyleURL, MGLStyle.satelliteStreetsStyleURL, MGLStyle.streetsStyleURL, AccuTerraStyle.vectorStyleURL]
    var styleId = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initMap()
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        self.searchTrails(searchText: nil)
    }
    
    func initMap() {
        if SdkManager.shared.isTrailDbInitialized {
            self.trailsService = ServiceFactory.getTrailService()
        }

        // Initialize map
        self.mapView.initialize(styleURL: styles[styleId])

        self.mapView.setUserTrackingMode(.follow, animated: true, completionHandler: {
        })
        self.mapView.isRotateEnabled = false //makes map interaction easier
        self.mapView.isPitchEnabled = false //makes map interaction easier
    }
    
    private func zoomToMapExtents() {
        // Colorado’s bounds
        let northeast = CLLocationCoordinate2D(latitude: 40.989329, longitude: -102.062592)
        let southwest = CLLocationCoordinate2D(latitude: 36.986207, longitude: -109.049896)
        let colorado = MGLCoordinateBounds(sw: southwest, ne: northeast)

        mapView.zoomToExtent(bounds: colorado, animated: true)
    }
    
    func didTapTrailMap(basicInfo: TrailBasicInfo) {
        self.mapView.trailLayersManager.setVisibleTrails(trailIds: Set<Int64>([basicInfo.id]))
        self.mapView.trailLayersManager.highLightTrail(trailId: basicInfo.id)
        do {
            if let trailManager = self.trailsService,
                let trail = try trailManager.getTrailById(basicInfo.id),
                let locationInfo = trail.locationInfo {
                self.zoomToTrail(locationInfo: locationInfo)
            }
        }
        catch {
            debugPrint("\(error)")
        }
    }
    
    private func zoomToTrail(locationInfo: TrailLocationInfo) {
        let extent = MGLCoordinateBounds(sw: locationInfo.mapBounds.sw.coordinates, ne: locationInfo.mapBounds.ne.coordinates)
        self.mapView.zoomToExtent(bounds: extent, edgePadding: UIEdgeInsets(top: 50, left: 50, bottom: 50, right: 50), animated: true)
    }
    
    func searchTrails(searchText:String?) {
        
        guard SdkManager.shared.isTrailDbInitialized else {
            return
        }
        
        do {
            if self.trailsService == nil {
                trailsService = ServiceFactory.getTrailService()
            }
            
            if let trailManager = self.trailsService {
                let criteria = try TrailBasicSearchCriteria(searchString: searchText, limit: 20)
                let trails = try trailManager.findTrails(byBasicCriteria: criteria)
                if trails.count > 0 {
                    self.trails = trails
                    self.navigationItem.title = searchText
                    self.tableView.reloadData()
                }
            }
        }
        catch {
            debugPrint("\(error)")
        }
    }
}

extension List_to_MapViewController : TrailLayersManagerDelegate {
    func onLayersAdded(trailLayers: Array<TrailLayerType>) {
        isTrailsLayerManagersLoaded = true
    }
}

extension List_to_MapViewController : AccuTerraMapViewDelegate {
    
    func didTapOnMap(coordinate: CLLocationCoordinate2D) {}
    
    func onStyleChanged() {}
        
    func onMapLoaded() {
        self.mapWasLoaded = true
        self.zoomToMapExtents()
        self.addTrailLayers()
    }
        
    private func addTrailLayers() {
        guard SdkManager.shared.isTrailDbInitialized else {
            return
        }
        let trailLayersManager = mapView.trailLayersManager

        trailLayersManager.delegate = self
        trailLayersManager.addStandardLayers()
    }
}

extension List_to_MapViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
                let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath) as UITableViewCell
        let text = self.trails?[indexPath.row].name
        cell.textLabel!.text = text        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.trails?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let basicInfo = self.trails?[indexPath.row] {
            self.didTapTrailMap(basicInfo: basicInfo)
        }
    }
}

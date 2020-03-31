//
//  Map-to_ListViewController.swift
//  AccuterraSampleApp
//
//  Created by Brian Elliott on 3/20/20.
//  Copyright © 2020 BaseMap. All rights reserved.
//

import UIKit
import AccuTerraSDK
import Mapbox

class Map_to_ListViewController: BaseViewController {

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
    
    func getMapBounds() throws -> MapBounds {
        let visibleRegion = self.mapView.visibleCoordinateBounds
        
        return try MapBounds(
            minLat: max(visibleRegion.sw.latitude, -90),
            minLon: max(visibleRegion.sw.longitude, -180),
            maxLat: min(visibleRegion.ne.latitude, 90),
            maxLon: min(visibleRegion.ne.longitude, 180))
    }
    
    func loadTrails() -> Set<Int64> {

        guard SdkManager.shared.isTrailDbInitialized else {
            return Set<Int64>()
        }

        do {
            if self.trailsService == nil {
                trailsService = ServiceFactory.getTrailService()
            }

            if let mapBounds = trailsFilter.boundingBoxFilter {
                let searchCriteria = TrailMapBoundsSearchCriteria(
                    mapBounds: mapBounds,
                    nameSearchString: nil,
                    techRating: nil,
                    userRating: nil,
                    length: nil,
                    orderBy: OrderBy(),
                    limit: Int(INT32_MAX))
                self.trails = try trailsService!.findTrails(byMapBoundsCriteria: searchCriteria)
                self.tableView.reloadData()
            }
        }
        catch {
            debugPrint("\(error)")
        }

        if let filteredTrailIds = self.trails?.map({ (trail) -> Int64 in
            return trail.id
        }) {
            return Set<Int64>(filteredTrailIds)
        } else {
            return Set<Int64>()
        }
    }
    
    func didSelectTrail(trailId: Int64) {
        mapView.trailLayersManager.highLightTrail(trailId: trailId)
        if let trailManager = self.trailsService {
            do {
                let basicInfo = try trailManager.getTrailBasicInfoById(trailId)
                if let info = basicInfo {
                    self.showAlert(title: "Trail Info: \(info.id)", message: info.name)
                }
            }
            catch {
                debugPrint("\(error)")
            }
        }
    }

    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: false, completion: nil)
    }
}

extension Map_to_ListViewController : TrailLayersManagerDelegate {
    func onLayersAdded(trailLayers: Array<TrailLayerType>) {
        isTrailsLayerManagersLoaded = true
    }
}

extension Map_to_ListViewController : AccuTerraMapViewDelegate {
    
    func onSignificantMapBoundsChange() {}
    
    func onStyleChanged() {}
    
    func handleTrailMapClick(trailId: Int64?) {
        if let id = trailId {
            self.didSelectTrail(trailId: id)
        }
    }
        
    func didTapOnMap(coordinate: CLLocationCoordinate2D) {
        guard self.isTrailsLayerManagersLoaded else {
            return
        }
        
        let _ = searchForPickedTrails(coordinate: coordinate)
    }
    
    func searchForPickedTrails(coordinate: CLLocationCoordinate2D) -> Bool {
        let query = TrailsQuery(
            trailLayersManager: mapView.trailLayersManager,
            layers: Set(TrailLayerType.allValues),
            coordinate: coordinate,
            distanceTolerance: 2.0)
        
        let trailId = query.execute().trailIds.first
        handleTrailMapClick(trailId: trailId)
        
        return trailId != nil
    }
        
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

extension Map_to_ListViewController : MGLMapViewDelegate {
    
    func mapView(_ mapView: MGLMapView, didChange mode: MGLUserTrackingMode, animated: Bool) {}
    
    func mapView(_ mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        // Always allow callouts to popup when annotations are tapped.
        return true
    }
    
    func mapViewDidBecomeIdle(_ mapView: MGLMapView) {
        if let newBoundingBoxFilter = try? getMapBounds() {
            if let previousBoundingBoxFilter = self.trailsFilter.boundingBoxFilter {
                if previousBoundingBoxFilter.equals(bounds: newBoundingBoxFilter) {
                    return
                }
            }
            self.trailsFilter.boundingBoxFilter = newBoundingBoxFilter
            let visibleTrails = self.loadTrails()
            self.mapView.trailLayersManager.setVisibleTrails(trailIds: visibleTrails)
        }
    }
    
    func mapViewDidFailLoadingMap(_ mapView: MGLMapView, withError error: Error) {
        self.showAlert(title: "Map Loading Error", message: "\(error)")
    }
    
}

extension Map_to_ListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
                let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath) as UITableViewCell
        let text = self.trails?[indexPath.row].name
        cell.textLabel!.text = text
        cell.selectionStyle = .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.trails?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
}

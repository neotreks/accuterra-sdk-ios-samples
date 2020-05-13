//
//  Term-to-MapViewController.swift
//  AccuterraSampleApp
//
//  Created by Brian Elliott on 3/20/20.
//  Copyright © 2020 BaseMap. All rights reserved.
//

import UIKit
import AccuTerraSDK
import Mapbox

class Term_to_MapViewController: BaseViewController {
    
    @IBOutlet weak var mapView: AccuTerraMapView!
    @IBOutlet weak var seachResultsLabel: UILabel!
    @IBOutlet weak var listButton: UIButton!
    
    private let appTitle = "AccuTerra Search"
    private let defaultNoTrails = "Trails Found: N/A"
    var searchController: UISearchController?
    var isTrailsLayerManagersLoaded = false
    var mapWasLoaded : Bool = false
    var trailsFilter = TrailsFilter()
    var trailsService: ITrailService?
    var styles: [URL] = [MGLStyle.outdoorsStyleURL, MGLStyle.satelliteStreetsStyleURL, MGLStyle.streetsStyleURL, AccuTerraStyle.vectorStyleURL]
    var styleId = 0
    var trails: Array<TrailBasicInfo>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initMap()
    }
    
    @IBAction func listviewButtonTapped(_ sender: Any) {
        print("list view picked")
    }
    
    @IBAction func clearListTapped(_ sender: Any) {
        resetSearch()
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
        
        seachResultsLabel.text = defaultNoTrails
    }

    private func zoomToMapExtents() {
        // Colorado’s bounds
        let northeast = CLLocationCoordinate2D(latitude: 40.989329, longitude: -102.062592)
        let southwest = CLLocationCoordinate2D(latitude: 36.986207, longitude: -109.049896)
        let colorado = MGLCoordinateBounds(sw: southwest, ne: northeast)

        mapView.zoomToExtent(bounds: colorado, animated: true)
    }
    
    func resetSearch() {
        setUpSearchBar()
        self.navigationItem.titleView = nil
        self.searchController = nil
        // Display all trails
        self.searchTrails(searchText: nil)
        self.trails = nil
        seachResultsLabel.text = defaultNoTrails
        self.navigationItem.title = appTitle
        zoomToMapExtents()
        self.mapView.trailLayersManager.setVisibleTrails(trailIds: Set<Int64>([]))
        listButton.isEnabled = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUpSearchBar()
    }
    
    func willPresentSearchController(_ searchController: UISearchController) {
        self.navigationController?.navigationBar.isTranslucent = true
    }

    func willDismissSearchController(_ searchController: UISearchController) {
        self.navigationController?.navigationBar.isTranslucent = false
    }
    
    var isSearchBarEmpty: Bool {
        return self.searchController?.searchBar.text?.isEmpty ?? true
    }
    
    func setUpSearchBar() {
        let searchButton = UIButton(type: .system)
        searchButton.tintColor = UIColor.Active
        searchButton.setImage(UIImage.searchImage, for: .normal)
        searchButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        searchButton.addTarget(self, action:#selector(self.searchTapped), for: .touchUpInside)
        
        self.navigationItem.setRightBarButtonItems([
            UIBarButtonItem(customView: searchButton)
        ], animated: false)
        
        self.navigationItem.setLeftBarButtonItems([
            UIBarButtonItem(title: "< Back", style: .plain, target: self, action: #selector(backTapped))
        ], animated: false)
        
        self.navigationItem.title = appTitle
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: nil, action: nil)
    }
    
    @objc func searchTapped() {
        self.searchController = UISearchController(searchResultsController:  nil)
        self.searchController?.hidesNavigationBarDuringPresentation = false
        self.searchController?.obscuresBackgroundDuringPresentation = false
        self.searchController?.searchBar.placeholder = "Trail Name"
        self.searchController?.searchBar.text = self.trailsFilter.trailNameFilter
        definesPresentationContext = true
        self.searchController?.searchBar.delegate = self
        self.navigationItem.titleView = searchController?.searchBar
        
        self.searchController?.searchBar.showsCancelButton = true
        self.searchController?.searchBar.becomeFirstResponder()
        self.navigationItem.setRightBarButtonItems(nil, animated: false)
    }
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: false, completion: nil)
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
                trails = try trailManager.findTrails(byBasicCriteria: criteria)
                if let foundTrails = trails {
                    if foundTrails.count > 0 {
                        seachResultsLabel.text = "Trails Found: \(foundTrails.count)"
                        self.navigationItem.title = searchText
                        var trailIds:Array<Int64> = []
                        for trail in foundTrails {
                            trailIds.append(trail.id)
                        }
                        let extent = try trailManager.getMapBoundsContainingTrails(trailIds: trailIds)
                        let northeast = CLLocationCoordinate2D(latitude: extent.maxLat, longitude: extent.maxLon)
                        let southwest = CLLocationCoordinate2D(latitude: extent.minLat, longitude: extent.minLon)
                        let bounds:MGLCoordinateBounds = MGLCoordinateBounds(sw: southwest, ne: northeast)
                        self.mapView.zoomToExtent(bounds: bounds, edgePadding: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10), animated: true)
                        self.mapView.trailLayersManager.setVisibleTrails(trailIds: Set<Int64>(trailIds))
                        listButton.isEnabled = true
                    }
                    else {
                        self.showAlert(title: "Search Results", message: "No Trails Found")
                        seachResultsLabel.text = "Trails Found: 0"
                        listButton.isEnabled = false
                    }
                }
            }
        }
        catch {
            debugPrint("\(error)")
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
        
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let viewController = segue.destination as? TrailListViewController {
            viewController.trails = self.trails
        }
    }
}

extension Term_to_MapViewController: UISearchBarDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        setUpSearchBar()
        self.searchController?.dismiss(animated: false, completion: nil)
        self.resetSearch()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        setUpSearchBar()
        self.searchController?.dismiss(animated: true, completion: nil)
        self.navigationItem.titleView = nil
        self.searchController = nil

        if let searchText = searchBar.text {
            self.searchTrails(searchText: searchText)
        }
    }
}

extension Term_to_MapViewController : TrailLayersManagerDelegate {
    func onLayersAdded(trailLayers: Array<TrailLayerType>) {
        isTrailsLayerManagersLoaded = true
    }
}

extension Term_to_MapViewController : AccuTerraMapViewDelegate {
    
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

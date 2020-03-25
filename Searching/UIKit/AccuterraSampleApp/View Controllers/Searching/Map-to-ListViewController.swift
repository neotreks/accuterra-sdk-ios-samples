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
    
    private let appTitle = "AccuTerra Search"
    var searchController: UISearchController?
    var isBaseMapLayerManagersLoaded = false
    var isTrailsLayerManagersLoaded = false
    var mapWasLoaded : Bool = false
    var trailsFilter = TrailsFilter()
    var trailsService: ITrailService?

    var styles: [URL] = [MGLStyle.outdoorsStyleURL, MGLStyle.satelliteStreetsStyleURL, MGLStyle.streetsStyleURL, AccuTerraStyle.vectorStyleURL]
    var styleId = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initMap()
        // searchTrails(searchText: nil)
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
        self.searchTrails(searchText: nil)
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
                    self.navigationItem.title = searchText
                    var trailIds:Array<Int64> = []
                    for trail in trails {
                        trailIds.append(trail.id)
                    }
//                        let extent = try trailManager.getMapBoundsContainingTrails(trailIds: trailIds)
//                        self.mapView.zoomToExtent(bounds: extent, edgePadding: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10), animated: true)
                }
            }
        }
        catch {
            debugPrint("\(error)")
        }
    }
    
//        func loadTrails() -> Set<Int64> {
//            tableView.register(UINib(nibName: cellXibName, bundle: nil), forCellReuseIdentifier: cellIdentifier)
//            guard let delegate = self.delegate else {
//                debugPrint("TrailListView delegate not set")
//                return Set<Int64>()
//            }
//            guard SdkManager.shared.isTrailDbInitialized else {
//                return Set<Int64>()
//            }
//            let filter = delegate.trailsFilter
//            // Note: when searching by name, we disable other filters
//            let hasTrailNameFilter = filter.trailNameFilter != nil
//            do {
//                if self.trailsService == nil {
//                    trailsService = ServiceFactory.getTrailService()
//                }
//
//                var techRatingSearchCriteria: TechRatingSearchCriteria?
//                if let maxDifficultyLevel = filter.maxDifficulty?.level, !hasTrailNameFilter {
//                    techRatingSearchCriteria = TechRatingSearchCriteria(
//                        level: maxDifficultyLevel,
//                        comparison: Comparison.lessEquals)
//                }
//
//                var userRatingSearchCriteria: UserRatingSearchCriteria?
//                if let minUserRating = filter.minUserRating, !hasTrailNameFilter {
//                    userRatingSearchCriteria = UserRatingSearchCriteria(
//                        userRating: Double(minUserRating),
//                        comparison: .greaterEquals)
//                }
//
//                var lengthSearchCriteria: LengthSearchCriteria?
//                if let maxTripDistance = filter.maxTripDistance, !hasTrailNameFilter{
//                    lengthSearchCriteria = LengthSearchCriteria(length: Double(maxTripDistance))
//                }
//
//                if let mapBounds = filter.boundingBoxFilter, !hasTrailNameFilter {
//                    let searchCriteria = TrailMapBoundsSearchCriteria(
//                        mapBounds: mapBounds,
//                        nameSearchString: nil,
//                        techRating: techRatingSearchCriteria,
//                        userRating: userRatingSearchCriteria,
//                        length: lengthSearchCriteria,
//                        orderBy: OrderBy(),
//                        limit: Int(INT32_MAX))
//                    self.trails = try trailsService!.findTrails(byMapBoundsCriteria: searchCriteria)
//                    self.tableView.reloadData()
//                } else {
//                    let searchCriteria = TrailMapSearchCriteria(
//                        mapCenter: delegate.getVisibleMapCenter(),
//                        nameSearchString: filter.trailNameFilter,
//                        techRating: techRatingSearchCriteria,
//                        userRating: userRatingSearchCriteria,
//                        length: lengthSearchCriteria,
//                        orderBy: OrderBy(),
//                        limit: Int(INT32_MAX))
//                    self.trails = try trailsService!.findTrails(byMapCriteria: searchCriteria)
//                    self.tableView.reloadData()
//                }
//                self.selectTrail(trailId: self.selectedTrailId)
//            }
//            catch {
//                debugPrint("\(error)")
//            }
//
//            if let filteredTrailIds = self.trails?.map({ (trail) -> Int64 in
//                return trail.id
//            }) {
//                return Set<Int64>(filteredTrailIds)
//            } else {
//                return Set<Int64>()
//            }
//        }
        
        @objc func backTapped() {
            self.navigationController?.popViewController(animated: true)
        }
    
        func showAlert(title: String, message: String) {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: false, completion: nil)
        }
    
    }

    extension Map_to_ListViewController: UISearchBarDelegate {
        func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
            setUpSearchBar()
            self.searchController?.dismiss(animated: false, completion: nil)
            self.navigationItem.titleView = nil
            self.searchController = nil
            // Display all trails
            self.searchTrails(searchText: nil)
            self.navigationItem.title = appTitle
            // self.tableView.reloadData()
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

    extension Map_to_ListViewController : TrailLayersManagerDelegate {
        func onLayersAdded(trailLayers: Array<TrailLayerType>) {
            isTrailsLayerManagersLoaded = true
        }
    }
extension Map_to_ListViewController : AccuTerraMapViewDelegate {
    func onStyleChanged() {}
    
    func didTapOnMap(coordinate: CLLocationCoordinate2D) {}
        
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
        
//        self.doTrailsSearch()
//        if let count = self.trails?.count {
//            self.statusLabel.text = "Trail Count: \(count)"
//        }
    }
}

extension Map_to_ListViewController : MGLMapViewDelegate {
    
    func mapView(_ mapView: MGLMapView, didUpdate userLocation: MGLUserLocation?) {
//        if self.initLoading == true && self.mapWasLoaded == true {
//            self.initLoading = false
//        }
    }

    func mapView(_ mapView: MGLMapView, didChange mode: MGLUserTrackingMode, animated: Bool) {}
    
    func mapView(_ mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        // Always allow callouts to popup when annotations are tapped.
        return true
    }
    
    func mapViewDidBecomeIdle(_ mapView: MGLMapView) {
        print("mapViewDidBecomeIdle")
//        if let newBoundingBoxFilter = try? getMapBounds() {
//            if let previousBoundingBoxFilter = self.trailsFilter.boundingBoxFilter {
//                if previousBoundingBoxFilter.equals(bounds: newBoundingBoxFilter) {
//                    return
//                }
//            }
//            self.trailsFilter.boundingBoxFilter = newBoundingBoxFilter
//            let visibleTrails = self.trailsListView.loadTrails()
//            self.mapView.trailLayersManager.setVisibleTrails(trailIds: visibleTrails)
//        }
    }
    
    func mapViewDidFailLoadingMap(_ mapView: MGLMapView, withError error: Error) {
        self.showAlert(title: "Map Loading Error", message: "\(error)")
    }
    
    func mapView(_ mapView: MGLMapView, regionDidChangeAnimated animated: Bool) {
        print("regionDidChangeAnimated")
    }
}

//
//  DiscoverViewController.swift
//  DemoApp
//
//  Created by Rudolf Kopřiva on 20/12/2019.
//  Copyright © 2019 NeoTreks. All rights reserved.
//

import UIKit
import Mapbox
import AccuTerraSDK

enum TrailListSliderMode: Int {
    case closed = 0
    case partial
    case full
}

class DiscoverViewController: BaseViewController {
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var mapView: AccuTerraMapView!
    @IBOutlet weak var contentViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var mapViewHeightPartialConstraint: NSLayoutConstraint!
    // Note: for the full screen list we stop resizing map, but rather resize
    // the TrailsListView.
    @IBOutlet weak var listViewHeightFullConstraint: NSLayoutConstraint!
    @IBOutlet weak var mapViewHeightClosedConstraint: NSLayoutConstraint!
    @IBOutlet weak var myLocationButton: UIButton!
    
    var searchController: UISearchController?
    var trailsListView: TrailListView = UIView.fromNib()
    
    var initLoading : Bool = true
    var mapWasLoaded : Bool = false
    var trailListSliderMode:TrailListSliderMode = .partial
    var isBaseMapLayerManagersLoaded = false
    var isTrailsLayerManagersLoaded = false
    var trailsFilter = TrailsFilter()
    var trailFilterButton: UIButton?
    
    var trailService: ITrailService?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        goToTrailsDiscovery()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUpSearchBar()
    }
    
    func goToTrailsDiscovery() {
        if SdkManager.shared.isTrailDbInitialized {
            self.trailService = ServiceFactory.getTrailService()
        }
        
        // Initialize map
        self.mapView.initialize()
        
        self.mapView.setUserTrackingMode(.follow, animated: true, completionHandler: {
        })
        self.mapView.isRotateEnabled = false //makes map interaction easier
        self.mapView.isPitchEnabled = false //makes map interaction easier
        
        trailsListView.delegate = self
        self.contentView.insertSubViewWithInset(view: trailsListView, insets: UIEdgeInsets.init())
        
        myLocationButton.layer.cornerRadius = 20.0
        myLocationButton.dropShadow()
        
        trailsListView.loadTrails()
    }
    
    func willPresentSearchController(_ searchController: UISearchController) {
        self.navigationController?.navigationBar.isTranslucent = true
    }

    func willDismissSearchController(_ searchController: UISearchController) {
        self.navigationController?.navigationBar.isTranslucent = false
    }
    
    @objc func searchTapped() {
        self.searchController = UISearchController(searchResultsController:  nil)
        self.searchController?.hidesNavigationBarDuringPresentation = false
        self.searchController?.obscuresBackgroundDuringPresentation = false
        self.searchController?.searchBar.placeholder = "Trail Name"
        self.searchController?.searchBar.text = self.trailsFilter.trailNameFilter
        definesPresentationContext = true
        self.searchController?.searchBar.delegate = self
        self.homeNavItem?.titleView = searchController?.searchBar
        
        self.searchController?.searchBar.showsCancelButton = true
        self.searchController?.searchBar.becomeFirstResponder()
        self.taskBar?.isUserInteractionEnabled = false
        self.homeNavItem?.setRightBarButtonItems(nil, animated: false)
        showTrailListPartialMode()
    }
    
    @objc func filterTapped() {
        if let vc = UIStoryboard(name: "Main", bundle: nil) .
            instantiateViewController(withIdentifier: "FilterController") as? FilterViewController {
            vc.modalPresentationStyle = .overCurrentContext
            vc.delegate = self
            self.present(vc, animated: true, completion: nil)
            vc.initialize(trailsFilter: self.trailsFilter)
        }
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
        
        let filterButton = UIButton(type: .system)
        filterButton.tintColor = UIColor.Active
        filterButton.setImage(UIImage.filterImage?.withRenderingMode(.alwaysTemplate), for: .normal)
        filterButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        filterButton.addTarget(self, action:#selector(self.filterTapped), for: .touchUpInside)
        self.homeNavItem?.setRightBarButtonItems([
            UIBarButtonItem(customView: filterButton),
            UIBarButtonItem(customView: searchButton)
        ], animated: false)
        self.trailFilterButton = filterButton
        self.homeNavItem?.titleView = nil
    }
    
    private func showTrailInfo(basicInfo: TrailBasicInfo) {
        let infoViewController = TrailInfoViewController()
        infoViewController.title = "Trail Info"
        infoViewController.delegate = self
        infoViewController.basicTrailInfo = basicInfo
        self.navigationController?.pushViewController(infoViewController, animated: true)
    }
    
    private func onLoadTrailDetail(basicInfo: TrailBasicInfo) {
        self.showTrailInfo(basicInfo: basicInfo)
    }
    
    private func zoomToDefaultExtent() {
        // Colorado’s bounds
        let northeast = CLLocationCoordinate2D(latitude: 40.989329, longitude: -102.062592)
        let southwest = CLLocationCoordinate2D(latitude: 36.986207, longitude: -109.049896)
        let colorado = MGLCoordinateBounds(sw: southwest, ne: northeast)
        
        mapView.zoomToExtent(bounds: colorado, animated: true)
    }
    
    private func zoomToTrail(locationInfo: TrailLocationInfo) {
        let extent = MGLCoordinateBounds(sw: locationInfo.mapBounds.sw.coordinates, ne: locationInfo.mapBounds.ne.coordinates)
        self.mapView.zoomToExtent(bounds: extent, edgePadding: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10), animated: true)
    }
    
    @IBAction func myLocationPicked(_ sender: Any) {
        self.setMyLocationDisplay(selected: true)
        self.mapView.userTrackingMode = .follow
    }
    
    private func setMyLocationDisplay(selected: Bool) {
        myLocationButton.isSelected = selected
        myLocationButton.tintColor = selected ? UIColor.Active : UIColor.Inactive
    }
    
    // Update My Location button to be inactive and hide current blue dot of user location
    private func inactivateMyLocation() {
        mapView.showsUserLocation = false
        self.setMyLocationDisplay(selected: false)
    }
    
    private func setTrailNameFilter(trailNameFilter: String?) {
        self.trailsFilter.trailNameFilter = trailNameFilter

        if let filterName = trailNameFilter, filterName.count > 0 {
            self.homeNavItem?.title = filterName
            self.trailFilterButton?.isUserInteractionEnabled = false
            self.trailFilterButton?.tintColor = UIColor.lightGray
        } else {
            self.homeNavItem?.title = String.appTitle
            self.trailFilterButton?.isUserInteractionEnabled = true
            self.trailFilterButton?.tintColor = UIColor.Active
        }

        trailsListView.loadTrails()
    }
}

extension DiscoverViewController : AccuTerraMapViewDelegate {
    func didTapOnMap(coordinate: CLLocationCoordinate2D) {
        guard self.isTrailsLayerManagersLoaded else {
            return
        }
        
        let query = TrailsQuery(
            trailLayersManager: mapView.trailLayersManager,
            layers: Set(TrailLayerType.allValues),
            coordinate: coordinate,
            distanceTolerance: 2.0)
        
        let trailId = query.execute().trailIds.first
        
        mapView.trailLayersManager.highLightTrail(trailId: trailId)
        self.trailsListView.selectTrail(trailId: trailId)
    }
    
    func onMapLoaded() {
        // Used to zoom to user when app starts
        if self.initLoading == true && CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            self.initLoading = false
        }
        
        self.mapWasLoaded = true
        self.zoomToDefaultExtent()
        self.addBaseMapLayer()
        self.addTrailLayers()
    }
    
    private func addBaseMapLayer() {
        let baseMapLayersManager = self.mapView.baseMapLayersManager

        baseMapLayersManager.delegate = self
        baseMapLayersManager.addLayer(baseLayer: BaseLayerType.RASTER_BASE_MAP)
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

extension DiscoverViewController : TrailLayersManagerDelegate {
    func onLayersAdded(trailLayers: Array<TrailLayerType>) {
        isTrailsLayerManagersLoaded = true
    }
}

extension DiscoverViewController : BaseMapLayersManagerDelegate {
    func onLayerAdded(baseMapLayer: BaseLayerType) {
        isBaseMapLayerManagersLoaded = true
    }
}

extension DiscoverViewController : MGLMapViewDelegate {
    
    func mapView(_ mapView: MGLMapView, didUpdate userLocation: MGLUserLocation?) {
        if self.initLoading == true && self.mapWasLoaded == true {
            self.initLoading = false
        }
    }

    func mapView(_ mapView: MGLMapView, didChange mode: MGLUserTrackingMode, animated: Bool) {
        if mode == .none {
            self.inactivateMyLocation()
        }
    }
    
    func mapView(_ mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        // Always allow callouts to popup when annotations are tapped.
        return true
    }
    
    func mapViewDidBecomeIdle(_ mapView: MGLMapView) {
        if trailListSliderMode != .full {
            if let newBoundingBoxFilter = try? getMapBounds() {
                if let previousBoundingBoxFilter = self.trailsFilter.boundingBoxFilter {
                    if previousBoundingBoxFilter.equals(bounds: newBoundingBoxFilter) {
                        return
                    }
                }
                self.trailsFilter.boundingBoxFilter = newBoundingBoxFilter
                self.trailsListView.loadTrails()
            }
        }
    }
}

extension DiscoverViewController : TrailListViewDelegate {
    
    func didTapTrailInfo(basicInfo: TrailBasicInfo) {
        self.mapView.trailLayersManager.highLightTrail(trailId: basicInfo.id)
        self.trailsListView.selectTrail(trailId: basicInfo.id)
        onLoadTrailDetail(basicInfo: basicInfo)
    }
    
    func didTapTrailMap(basicInfo: TrailBasicInfo) {
        self.mapView.trailLayersManager.highLightTrail(trailId: basicInfo.id)
        do {
            if let trailManager = self.trailService,
                let trail = try trailManager.getTrailById(basicInfo.id),
                let locationInfo = trail.locationInfo {
                self.zoomToTrail(locationInfo: locationInfo)
            }
        }
        catch {
            debugPrint("\(error)")
        }
    }
    
    func didSelectTrail(basicInfo: TrailBasicInfo) {
        self.mapView.trailLayersManager.highLightTrail(trailId: basicInfo.id)
    }
    
    func toggleTrailListPosition() {
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
            if self.trailListSliderMode == .closed {
                self.showTrailListPartialMode()
            }
            else if self.trailListSliderMode == .partial {
                self.showTrailListFullMode()
            }
            else if self.trailListSliderMode == .full {
                self.showTrailListClosedMode()
            }
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    func showTrailListFullMode() {
        self.trailListSliderMode = .full
        self.listViewHeightFullConstraint.isActive = true
        self.trailsListView.listButton.setImage(UIImage.chevronDownImage, for: .normal)
    }
    
    func showTrailListPartialMode() {
        self.trailListSliderMode = .partial
        self.mapViewHeightPartialConstraint.isActive = true
        self.mapViewHeightClosedConstraint.isActive = false
        self.listViewHeightFullConstraint.isActive = false
        self.trailsListView.listButton.setImage(UIImage.chevronUpImage, for: .normal)
    }
    
    func showTrailListClosedMode() {
        self.trailListSliderMode = .closed
        self.mapViewHeightPartialConstraint.isActive = false
        self.mapViewHeightClosedConstraint.isActive = true
        self.listViewHeightFullConstraint.isActive = false
        self.trailsListView.listButton.setImage(UIImage.chevronUpImage, for: .normal)
    }
    
    func getVisibleMapCenter() -> MapLocation {
        let center = self.mapView.camera.centerCoordinate
        return MapLocation(latitude: center.latitude, longitude: center.longitude)
    }
    
    func getMapBounds() throws -> MapBounds {
        let visibleRegion = self.mapView.visibleCoordinateBounds
        
        return try MapBounds(
            minLat: max(visibleRegion.sw.latitude, -90),
            minLon: max(visibleRegion.sw.longitude, -180),
            maxLat: min(visibleRegion.ne.latitude, 90),
            maxLon: min(visibleRegion.ne.longitude, 180))
    }
}

extension DiscoverViewController : TrailInfoViewDelegate {
    func didTapTrailInfoBackButton() {
    }
}

extension DiscoverViewController: UISearchBarDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        setUpSearchBar()
        showTrailListPartialMode()
        self.searchController?.dismiss(animated: true, completion: nil)
        self.searchController = nil
        setTrailNameFilter(trailNameFilter: nil)
        self.taskBar?.isUserInteractionEnabled = true
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        setUpSearchBar()
        showTrailListPartialMode()
        self.searchController?.dismiss(animated: true, completion: nil)
        self.searchController = nil
        setTrailNameFilter(trailNameFilter: searchBar.text)
        self.taskBar?.isUserInteractionEnabled = true
    }
}

extension DiscoverViewController : FilterViewControllerDelegate {
    func applyFilter(trailsFilter: TrailsFilter) {
        self.trailsFilter = trailsFilter
        self.trailsListView.loadTrails()
    }
}

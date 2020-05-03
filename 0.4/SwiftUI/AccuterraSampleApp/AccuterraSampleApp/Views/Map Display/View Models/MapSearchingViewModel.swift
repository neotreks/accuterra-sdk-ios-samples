//
//  MapSearchingViewModel.swift
//  AccuterraSampleApp
//
//  Created by Brian Elliott on 4/27/20.
//  Copyright © 2020 NeoTreks, Inc. All rights reserved.
//

import SwiftUI
import MapKit
import AccuTerraSDK
import Combine

import MapKit

class MapSearchingViewModel: NSObject, ObservableObject {
    
    @Published var isSearching = false
    @Published var searchQuery = ""
    @Published var trails = [TrailItem]()
    @Published var selectedMapItem: MKMapItem?
    @Published var keyboardHeight: CGFloat = 0
    @Published var mapItems = [MKMapItem]()
    var trailService: ITrailService?
    var cancellable: AnyCancellable?
    fileprivate var region: MapBounds?
    
    override init() {
        super.init()
        
        self.region = try! MapBounds( minLat: 37.99906, minLon: -109.04265, maxLat: 41.00097, maxLon: -102.04607)
        
        NotificationCenter.default.addObserver(forName: MapView.Coordinator.regionChangedNotification, object: nil, queue: .main) { [weak self] (notification) in
            self?.region = notification.object as? MapBounds
        }

        cancellable = $searchQuery.debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .sink { [weak self] (searchTerm) in
                self?.performSearch(query: searchTerm)
        }
        
        listenForKeyboardNotifications()
    }
    
    fileprivate func performSearch(query: String) {
        do {
            isSearching = true
            
            if self.trailService == nil {
                trailService = ServiceFactory.getTrailService()
            }
            
//            let request = MKLocalSearch.Request()
//            request.naturalLanguageQuery = query
//
//            let localSearch = MKLocalSearch(request: request)
//            localSearch.start { (resp, err) in
//                self.mapItems = resp?.mapItems ?? []
//                self.trails = [TrailItem]()
//                for item in self.mapItems {
//                    self.trails.append(TrailItem(title: item.name ?? "elliott", description: "brian", distance: nil, rating:nil, difficultyLow:nil, difficultyHigh: nil))
//                }
//                self.isSearching = false
//
//            }

            if let bounds = region {
                print("perform search ... top query: \(query) | isSearching: \(self.isSearching)")
                let searchCriteria = TrailMapBoundsSearchCriteria(
                    mapBounds: bounds,
                    nameSearchString: query,
                    techRating: nil,
                    userRating: nil,
                    length: nil,
                    orderBy: OrderBy(),
                    limit: Int(INT32_MAX))
                let basicInfoList = try trailService!.findTrails(byMapBoundsCriteria: searchCriteria)
                print("perform search . \(basicInfoList.count)")
                self.trails = [TrailItem]()
                for item in basicInfoList {
                    print("perform search name: \(item.name)")
                    self.trails.append(TrailItem(title: item.name, description: item.highlights, distance: item.length, rating:item.userRating, difficultyLow:item.techRatingLow, difficultyHigh: item.techRatingHigh))
                }
                self.isSearching = false
            }


//            let searchCriteria = try? TrailBasicSearchCriteria(
//                searchString: query,
//                limit: Int(INT32_MAX))
//            if let service = trailService, let criteria = searchCriteria {
//                let basicInfoList = try service.findTrails(byBasicCriteria: criteria)
//                 self.trails = [TrailItem]()
//                for item in basicInfoList {
//                    self.trails.append(TrailItem(title: item.name, description: item.highlights, distance: item.length, rating:item.userRating, difficultyLow:item.techRatingLow, difficultyHigh: item.techRatingHigh))
//                }
//                self.isSearching = true
//            }
        }
        catch {
            print("\(error)")
        }
    }
        
    fileprivate func listenForKeyboardNotifications() {
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { [weak self] (notification) in
            guard let value = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
            let keyboardFrame = value.cgRectValue
            let window = UIApplication.shared.windows.filter{$0.isKeyWindow}.first
            
            withAnimation(.easeOut(duration: 0.25)) {
                self?.keyboardHeight = keyboardFrame.height - window!.safeAreaInsets.bottom
            }
            print(keyboardFrame.height)
        }
        
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { [weak self] (notification) in
            withAnimation(.easeOut(duration: 0.25)) {
                self?.keyboardHeight = 0
            }
            
        }
    }
}

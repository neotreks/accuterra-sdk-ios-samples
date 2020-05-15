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

class MapSearchingViewModel: NSObject, ObservableObject {
    
    @Published var isSearching = false
    @Published var searchQuery = ""
    @Published var reset = false
    @Published var trails = [TrailItem]()
    @Published var keyboardHeight: CGFloat = 0
    @Published var searchBounds:MapBounds?
    var trailService: ITrailService?
    var cancellable: AnyCancellable?

    override init() {
        super.init()

        cancellable = $searchQuery.debounce(for: .milliseconds(1000), scheduler: RunLoop.main)
            .sink { [weak self] (searchTerm) in
                self?.performSearch(query: searchTerm)
        }
        
        listenForKeyboardNotifications()
        
        NotificationCenter.default.addObserver(forName: MapView.Coordinator.regionChangedNotification, object: nil, queue: .main) { [weak self] (notification) in
            self?.searchBounds = notification.object as? MapBounds
        }
        
    }

    func getColoradoBounds() -> MapBounds {
        return try! MapBounds( minLat: 37.99906, minLon: -109.04265, maxLat: 41.00097, maxLon: -102.04607)
    }
    
    func getUSBounds() -> MapBounds {
        return try! MapBounds(minLat: 25.79467, minLon: -125.32188, maxLat: 48.90785, maxLon:  -66.23966)
    }
    
    func resetTrails() {
        self.searchQuery = ""
        self.isSearching = false
        self.trails = []
    }
    
    private func performSearch(query: String) {
        do {
            isSearching = true
            
            // Only search if there is a search term
            guard query.count > 0 else {
                isSearching = false
                self.trails = []
                return
            }
            
            if self.trailService == nil {
                trailService = ServiceFactory.getTrailService()
            }

            let searchCriteria = TrailMapBoundsSearchCriteria(
                mapBounds: self.searchBounds ?? getUSBounds(),
                nameSearchString: query,
                techRating: nil,
                userRating: nil,
                length: nil,
                orderBy: OrderBy(),
                limit: Int(INT32_MAX))
            let basicInfoList = try trailService?.findTrails(byMapBoundsCriteria: searchCriteria)
            if let infoList = basicInfoList {
                self.trails = []
                for item in infoList {
                    self.trails.append(TrailItem(trailId: item.id, title: item.name, description: item.highlights, distance: item.length, rating:item.userRating, difficultyLow:item.techRatingLow, difficultyHigh: item.techRatingHigh))
                }
                self.isSearching = false
            }
        }
        catch {
            print("\(error)")
        }
    }
        
    private func listenForKeyboardNotifications() {
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { [weak self] (notification) in
            guard let value = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
            let keyboardFrame = value.cgRectValue
            let window = UIApplication.shared.windows.filter{$0.isKeyWindow}.first
            
            withAnimation(.easeOut(duration: 0.25)) {
                self?.keyboardHeight = keyboardFrame.height - window!.safeAreaInsets.bottom
            }
            debugPrint(keyboardFrame.height)
        }
        
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { [weak self] (notification) in
            withAnimation(.easeOut(duration: 0.25)) {
                self?.keyboardHeight = 0
            }
            
        }
    }
}



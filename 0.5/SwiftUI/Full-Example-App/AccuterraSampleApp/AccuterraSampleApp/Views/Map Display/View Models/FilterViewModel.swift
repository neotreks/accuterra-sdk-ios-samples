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

class FilterViewModel: NSObject, ObservableObject {
    
    @Published var isSearching = false
    @Published var trails = [TrailItem]()
    @Published var moreTrailsFound = 0
    @Published var keyboardHeight: CGFloat = 0
    @Published var searchBounds:MapBounds?
    var trailService: ITrailService?
    let resultsLimit = 100

    override init() {
        super.init()
        
        listenForKeyboardNotifications()
    }

    func getTellurideLocation() -> MapLocation {
        return MapLocation(latitude: 37.9375, longitude: -107.8123)
    }
    
    func getAspenLocation() -> MapLocation {
        return MapLocation(latitude: 39.1911, longitude: -106.8175)
    }
    
    func resetTrails() {
        self.isSearching = false
        self.trails = []
    }
    
    func searchTrails(trailName:String = "", difficultyLevel:Int?, minUserRating:Int?, maxTripDistance:Int?, mapCenter:MapLocation) {
        
        guard SdkManager.shared.isTrailDbInitialized else {
            return
        }
        
        do {
        
            if self.trailService == nil {
                trailService = ServiceFactory.getTrailService()
            }
            
            self.moreTrailsFound = 0
            
            var techRatingSearchCriteria: TechRatingSearchCriteria?

            if let maxDifficultyLevel = difficultyLevel, maxDifficultyLevel < 5 {
                print("difficulty 2  = \(maxDifficultyLevel)")
                techRatingSearchCriteria = TechRatingSearchCriteria(
                    level: maxDifficultyLevel,
                    comparison: Comparison.lessEquals)
            }
            
            var userRatingSearchCriteria: UserRatingSearchCriteria?
            if let minUserRating = minUserRating, minUserRating > 0 {
                print("userrating = \(minUserRating)")
                userRatingSearchCriteria = UserRatingSearchCriteria(
                    userRating: Double(minUserRating),
                    comparison: .greaterEquals)
            }
            
            var lengthSearchCriteria: LengthSearchCriteria?
            if let maxTripDistance = maxTripDistance {
                print("distance = \(maxTripDistance)")
                lengthSearchCriteria = LengthSearchCriteria(length: Double(maxTripDistance))
            }
            
            let searchCriteria = TrailMapSearchCriteria(
                mapCenter: mapCenter,
                nameSearchString: trailName,
                techRating: techRatingSearchCriteria,
                userRating: userRatingSearchCriteria,
                length: lengthSearchCriteria,
                orderBy: OrderBy(),
                limit: Int(INT32_MAX))
            
            print("mapcenter: \(mapCenter)")
            print("trailName: \(trailName)")

            let basicInfoList = try trailService?.findTrails(byMapCriteria: searchCriteria)
            if let infoList = basicInfoList {
                self.moreTrailsFound = infoList.count
                self.trails = []
                var count = 0
                for item in infoList {
                    count += 1
                    if count > resultsLimit {
                        break
                    }
                    print("trail search .... item: \(item.name), user rating: \(item.userRating), difficulty:\(item.techRatingHigh), distance: \(item.length)")
                    self.trails.append(TrailItem(trailId: item.id, title: item.name, description: item.highlights, distance: item.length, rating:item.userRating, difficultyLow:item.techRatingLow, difficultyHigh: item.techRatingHigh))
                }
                self.isSearching = false
            }
        } catch {
            debugPrint("\(error)")
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

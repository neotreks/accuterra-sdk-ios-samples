//
//  MapViewModel.swift
//  AccuterraSampleApp
//
//  Created by Brian Elliott on 4/23/20.
//  Copyright © 2020 NeoTreks, Inc. All rights reserved.
//

import SwiftUI
import Combine
import AccuTerraSDK
import Mapbox
import CoreLocation

class TrailsViewModel: ObservableObject {
    
    var trailService: ITrailService?
    @Published var trails: Array<TrailBasicInfo>?
    @Published var trailCount: Int = 0
    fileprivate var region: MapBounds?
    
    init() {
        NotificationCenter.default.addObserver(forName: MapView.Coordinator.regionChangedNotification, object: nil, queue: .main) { [weak self] (notification) in
            self?.region = notification.object as? MapBounds
            self?.getTrailsByBounds()
        }
    }
    
    func getTrailById(trailId:Int64) -> Trail? {
        do {
            if self.trailService == nil {
                trailService = ServiceFactory.getTrailService()
            }
            
            if let trailManager = self.trailService {
                return try trailManager.getTrailById(trailId)
            }
        }
        catch {
            print("\(error)")
        }
        return nil
    }
    
    func getTrailsByBounds() {
        
        guard SdkManager.shared.isTrailDbInitialized else {
            return
        }

        do {
            if self.trailService == nil {
                trailService = ServiceFactory.getTrailService()
            }

            if let bounds = region {
                let searchCriteria = TrailMapBoundsSearchCriteria(
                    mapBounds: bounds,
                    nameSearchString: nil,
                    techRating: nil,
                    userRating: nil,
                    length: nil,
                    orderBy: OrderBy(),
                    limit: Int(INT32_MAX))
                self.trails = try trailService!.findTrails(byMapBoundsCriteria: searchCriteria)
            }
        }
        catch {
            print("\(error)")
        }

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
                if let count = self.trails?.count {
                    self.trailCount = count
                }
            }
        }
        catch {
            debugPrint("\(error)")
        }
    }
    
    func getFormattedTrailDistance(distance:Double?) -> String {
        // Convert from kilometers to miles
        if let trailDistance = distance {
             return GeoUtils.distanceKilometersToMiles(kilometers: trailDistance)
         }
         else {
             return "-- mi"
         }
    }
}



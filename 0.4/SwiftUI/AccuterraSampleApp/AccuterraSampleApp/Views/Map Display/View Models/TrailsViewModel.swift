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
}



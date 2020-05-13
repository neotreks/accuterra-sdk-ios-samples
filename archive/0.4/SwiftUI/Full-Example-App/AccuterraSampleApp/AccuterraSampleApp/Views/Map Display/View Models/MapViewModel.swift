//
//  MapViewModel.swift
//  AccuterraSampleApp
//
//  Created by Brian Elliott on 4/30/20.
//  Copyright © 2020 NeoTreks, Inc. All rights reserved.
//

import SwiftUI
import Combine
import AccuTerraSDK
import Mapbox
import CoreLocation

class MapViewModel {
    
    func getTrailBounds(trailId:Int64, trail: Trail) -> (MapBounds?, UIEdgeInsets, Int64) {
        if let locationInfo = trail.locationInfo {
            let bounds = try? MapBounds(minLat: locationInfo.mapBounds.minLat, minLon: locationInfo.mapBounds.minLon, maxLat: locationInfo.mapBounds.maxLat, maxLon: locationInfo.mapBounds.maxLon)
            return (bounds, edgeInsets:UIEdgeInsets(top: 50, left: 50, bottom: 50, right: 50), trailId)
        }
        return (nil, UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0), trailId)
    }

    func getColoradoBounds() -> MapBounds {
        return try! MapBounds( minLat: 37.99906, minLon: -109.04265, maxLat: 41.00097, maxLon: -102.04607)
    }
    
    func getCastleRockLocation() -> CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: 39.3722, longitude: -104.8561)
    }
    
    func getDenverLocation() -> CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: 39.7392, longitude: -104.9903)
    }
}




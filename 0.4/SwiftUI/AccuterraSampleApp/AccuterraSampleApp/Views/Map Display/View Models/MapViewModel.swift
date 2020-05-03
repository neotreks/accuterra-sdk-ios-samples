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
    
    func setTrailBounds(trailId:Int64, trail: Trail) -> MapInteractions {
        if let locationInfo = trail.locationInfo {
            let bounds = try? MapBounds(minLat: locationInfo.mapBounds.minLat, minLon: locationInfo.mapBounds.minLon, maxLat: locationInfo.mapBounds.maxLat, maxLon: locationInfo.mapBounds.maxLon)
            return MapInteractions(mapCenter: nil, mapBounds: bounds, edgeInsets:UIEdgeInsets(top: 50, left: 50, bottom: 50, right: 50), zoomAnimation: false, selectedTrailId: trailId)
        }
        return MapInteractions()
    }
    
    func setColoradoBounds() -> MapInteractions {
        let boundsColorado = try! MapBounds( minLat: 37.99906, minLon: -109.04265, maxLat: 41.00097, maxLon: -102.04607)
        return MapInteractions(mapCenter: nil, mapBounds: boundsColorado, zoomAnimation: false)
    }
    
    func setCastleRockLocation() -> MapInteractions {
        return MapInteractions(mapCenter: getCastleRockLocation(), mapBounds: nil, zoomAnimation: true)
    }
    
    func setDenverLocation() -> MapInteractions {
        return MapInteractions(mapCenter: getDenverLocation(), mapBounds: nil, zoomAnimation: false)
    }
    
    func getCastleRockLocation() -> CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: 39.3722, longitude: -104.8561)
    }
    
    func getDenverLocation() -> CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: 39.7392, longitude: -104.9903)
    }
}




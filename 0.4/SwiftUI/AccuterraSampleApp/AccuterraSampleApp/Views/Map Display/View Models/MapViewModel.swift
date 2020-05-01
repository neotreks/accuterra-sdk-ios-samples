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
    
    func setColoradoBounds() -> MapInteractions {
        let northeast = CLLocationCoordinate2D(latitude: 40.989329, longitude: -102.062592)
        let southwest = CLLocationCoordinate2D(latitude: 36.986207, longitude: -109.049896)
        let colorado = MGLCoordinateBounds(sw: southwest, ne: northeast)
        return MapInteractions(mapCenter: nil, mapBounds: colorado, zoomAnimation: false)
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




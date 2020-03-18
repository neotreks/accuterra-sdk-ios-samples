//
//  MapInteraction.swift
//  AccuterraSampleApp
//
//  Created by Brian Elliott on 3/17/20.
//  Copyright © 2020 BaseMap. All rights reserved.
//

import Foundation
import SwiftUI
import Combine
import Mapbox

class MapInteraction: ObservableObject {
    
    @Published var mapCenter:CLLocationCoordinate2D? = nil
    @Published var mapBounds: MGLCoordinateBounds? = nil
    @Published var zoomAnimation: Bool = false
    
    static func getColoradoBounds() -> MGLCoordinateBounds {
        // Colorado’s bounds
        let northeast = CLLocationCoordinate2D(latitude: 40.989329, longitude: -102.062592)
        let southwest = CLLocationCoordinate2D(latitude: 36.986207, longitude: -109.049896)
        let colorado = MGLCoordinateBounds(sw: southwest, ne: northeast)
        return colorado
    }
    
    static func getCastleRockLocation() -> CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: 39.3722, longitude: -104.8561)
    }
    
    static func getDenverLocation() -> CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: 39.7392, longitude: -104.9903)
    }
}

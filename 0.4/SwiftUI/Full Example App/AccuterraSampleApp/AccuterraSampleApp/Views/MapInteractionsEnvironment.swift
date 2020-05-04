//
//  MapInteractionsEnvironment.swift
//  AccuterraSampleApp
//
//  Created by Brian Elliott on 5/2/20.
//  Copyright © 2020 NeoTreks, Inc. All rights reserved.
//

import Combine
import AccuTerraSDK
import Mapbox

class MapInteractionsEnvironment: ObservableObject {
    @Published var mapCenter: CLLocationCoordinate2D? = nil
    @Published var mapBounds: MapBounds? = nil
    @Published var edgeInsets:UIEdgeInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
    @Published var zoomAnimation: Bool = false
    @Published var selectedTrailId:Int64 = 0
    
    func resetEnv() {
        mapCenter = nil
        mapBounds = try! MapBounds( minLat: 37.99906, minLon: -109.04265, maxLat: 41.00097, maxLon: -102.04607)
        edgeInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
        zoomAnimation = false
        selectedTrailId = 0
    }
}




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

struct MapInteractionsEnvironment {
    
    var mapCenter: CLLocationCoordinate2D?
    var mapBounds: MapBounds?
    var edgeInsets: UIEdgeInsets?
    var zoomAnimation: Bool = false
    var selectedTrailId:Int64 = 0
    
    let defaultEdgeInserts = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
    
    mutating func setInteractions(center:CLLocationCoordinate2D? = nil, bounds:MapBounds? = nil, insets:UIEdgeInsets? = nil, zoom:Bool = false, trailId:Int64 = 0) {
        mapCenter = center
        mapBounds = bounds
        edgeInsets = insets
        zoomAnimation = zoom
        selectedTrailId = trailId
    }
    
    mutating func resetEnv() {
        self.mapCenter = nil
        self.mapBounds = try! MapBounds( minLat: 37.99906, minLon: -109.04265, maxLat: 41.00097, maxLon: -102.04607)
        self.edgeInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
        self.zoomAnimation = false
        self.selectedTrailId = 0
    }
}




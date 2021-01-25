//
//  SearchFilters.swift
//  AccuterraSampleApp
//
//  Created by Brian Elliott on 5/8/20.
//  Copyright © 2020 NeoTreks, Inc. All rights reserved.
//

import AccuTerraSDK

struct SearchFilters {
    
    var mapBounds: MapBounds?

    mutating func setFilters(bounds:MapBounds? = nil) {
        mapBounds = bounds
    }
    
    mutating func resetFilters() {
        self.mapBounds = nil
    }
}

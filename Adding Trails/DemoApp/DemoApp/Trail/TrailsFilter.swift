//
//  TrailsFilter.swift
//  DemoApp
//
//  Created by Rudolf Kopřiva on 03/03/2020.
//  Copyright © 2020 NeoTreks. All rights reserved.
//

import Foundation
import AccuTerraSDK

///
/// Holds trail filtering parameters
///
struct TrailsFilter {
    var trailNameFilter: String?
    var boundingBoxFilter: MapBounds?
    var maxDifficulty: TechnicalRating?
    var minUserRating: Int?
    var maxTripDistance: Int?
}

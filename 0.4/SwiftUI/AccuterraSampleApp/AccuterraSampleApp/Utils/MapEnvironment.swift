//
//  MapEnvironment.swift
//  AccuterraSampleApp
//
//  Created by Brian Elliott on 4/30/20.
//  Copyright © 2020 NeoTreks, Inc. All rights reserved.
//

import SwiftUI
import Combine
import AccuTerraSDK
import Mapbox

struct FeatureToggles {
    var displayTrails:Bool
    var allowTrailTaps:Bool
    var allowPOITaps:Bool
    var filteringOn = false
}

struct MapInteractions {
    var mapCenter: CLLocationCoordinate2D? = nil
    var mapBounds: MapBounds? = nil
    var edgeInsets:UIEdgeInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
    var zoomAnimation: Bool = false
    var selectedTrailId:Int64 = 0
}

struct MapAlertMessages {
    var displayAlert: Bool = false
    var title:String = "Alert"
    var message:String = ""
}

struct TrailsFilter {
    var trailNameFilter: String?
    var boundingBoxFilter: MapBounds?
    var maxDifficulty: TechnicalRating?
    var minUserRating: Int?
    var maxTripDistance: Int?
    var mapCenter: MapLocation?
}

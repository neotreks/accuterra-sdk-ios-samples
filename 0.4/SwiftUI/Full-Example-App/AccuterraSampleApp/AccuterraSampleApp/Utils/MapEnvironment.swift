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
    var updateSearchByMapBounds:Bool = false
    var filteringOn = false
}

//struct MapInteractions {
//    var mapCenter: CLLocationCoordinate2D? = nil
//    var mapBounds: MapBounds? = nil
//    var edgeInsets:UIEdgeInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
//    var zoomAnimation: Bool = false
//    var selectedTrailId:Int64 = 0
//}

struct MapAlertMessages {
    var displayAlert: Bool = false
    var title:String = "Alert"
    var message:String = ""
}

struct TrailItem: Identifiable, Hashable {

    let id: UUID
    let trailId: Int64
    let title: String
    let description: String
    let distance:Double?
    let rating:UserRating?
    let difficultyLow:TechnicalRating?
    let difficultyHigh:TechnicalRating?

    init(trailId: Int64, title: String, description: String, distance:Double?, rating:UserRating?, difficultyLow:TechnicalRating?, difficultyHigh:TechnicalRating?) {
        self.id = UUID()
        self.trailId = trailId
        self.title = title
        self.description = description
        self.distance = distance
        self.rating = rating
        self.difficultyLow = difficultyLow
        self.difficultyHigh = difficultyHigh
    }
    
    static func == (lhs: TrailItem, rhs: TrailItem) -> Bool {
      return lhs.title == rhs.title
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(title)
    }
}

struct TrailsFilter {
    var trailNameFilter: String?
    var boundingBoxFilter: MapBounds?
    var maxDifficulty: TechnicalRating?
    var minUserRating: Int?
    var maxTripDistance: Int?
    var mapCenter: MapLocation?
}

enum UserRatingStarFill: Int {
    case full = 0
    case partial
    case none
}

struct UserRatingStars {
    var starOne:UserRatingStarFill
    var starTwo:UserRatingStarFill
    var starThree:UserRatingStarFill
    var starFour:UserRatingStarFill
    var starFive:UserRatingStarFill
}

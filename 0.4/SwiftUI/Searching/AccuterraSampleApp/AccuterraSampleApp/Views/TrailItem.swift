//
//  TrailItem.swift
//  AccuterraSampleApp
//
//  Created by Brian Elliott on 5/3/20.
//  Copyright © 2020 NeoTreks, Inc. All rights reserved.
//

import AccuTerraSDK

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

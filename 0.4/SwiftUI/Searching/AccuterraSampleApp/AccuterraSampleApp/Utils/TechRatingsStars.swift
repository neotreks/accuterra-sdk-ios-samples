//
//  TechRatingColorMapper.swift
//  AccuterraSampleApp
//
//  Created by Brian Elliott on 5/2/20.
//  Copyright © 2020 NeoTreks, Inc. All rights reserved.
//

import Foundation
import AccuTerraSDK
import SwiftUI

class TechRatingColorMapper {
    static func getTechRatingColor(techRatingCode: String) -> Color {
        if let techRating = SdkTechRating(rawValue: techRatingCode.uppercased()) {
            return Color(techRating.rawValue)
        } else {
            return Color("DifficultyUnknown")
        }
    }
}

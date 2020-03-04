//
//  TechRatingColorMapper.swift
//  DemoApp
//
//  Created by Rudolf Kopřiva on 02/03/2020.
//  Copyright © 2020 NeoTreks. All rights reserved.
//

import Foundation
import AccuTerraSDK
import UIKit

class TechRatingColorMapper {
    static func getTechRatingColor(techRatingCode: String) -> UIColor {
        if let techRating = SdkTechRating(rawValue: techRatingCode.uppercased()) {
            return UIColor(named: techRating.rawValue)  ?? UIColor.white
        } else {
            return UIColor(named: "DifficultyUnknown") ?? UIColor.white
        }
    }
}

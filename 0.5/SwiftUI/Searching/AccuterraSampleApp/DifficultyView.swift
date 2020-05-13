//
//  UserRatingsView.swift
//  AccuterraSampleApp
//
//  Created by Brian Elliott on 5/2/20.
//  Copyright © 2020 NeoTreks, Inc. All rights reserved.
//

import SwiftUI
import AccuTerraSDK

import SwiftUI

struct DifficultyView: View {
    
    var fillColor:Color = .blue
    
    init(difficultyLow:TechnicalRating?, difficultyHigh:TechnicalRating?) {
        if let difficulty = difficultyHigh {
            fillColor = TechRatingColorMapper.getTechRatingColor(techRatingCode: difficulty.code)
        }
    }
    
    var body: some View {
        Rectangle()
        .fill(fillColor)
        .frame(width: 10, height: nil)
    }
}


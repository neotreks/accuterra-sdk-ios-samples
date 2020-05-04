//
//  TrailCard.swift
//  AccuterraSampleApp
//
//  Created by Brian Elliott on 5/3/20.
//  Copyright © 2020 NeoTreks, Inc. All rights reserved.
//

import SwiftUI

struct TrailCard: View {
    
    @ObservedObject var vm = TrailsViewModel()
    let trailItem: TrailItem
    
    var body: some View {
        HStack {
            DifficultyView(difficultyLow: trailItem.difficultyLow, difficultyHigh: trailItem.difficultyHigh)
            VStack(alignment: .leading) {
                Text(trailItem.title)
                    .font(.title)
                    .bold()
                HStack {
                    UserRatingsView(rating: trailItem.rating)
                }
                Text(vm.getFormattedTrailDistance(distance: trailItem.distance))
                    .font(.caption)
                    .frame(width: nil, height: 20, alignment: .leading)
                Text(trailItem.description)
                    .font(.body)
                    .frame(width: nil, height: 75, alignment: .leading)
                    .lineLimit(3)
            }
        }
    }
}

//
//  TrailCard.swift
//  AccuterraSampleApp
//
//  Created by Brian Elliott on 5/2/20.
//  Copyright © 2020 NeoTreks, Inc. All rights reserved.
//

import SwiftUI

struct TrailCard: View {
    
    let trailItem: TrailItem
    
    var body: some View {
        HStack {
            Rectangle()
            .fill(Color.green)
            .frame(width: 10, height: nil)
            VStack(alignment: .leading) {
                                        Text(trailItem.title)
                                            .font(.title)
                                            .bold()
                                        HStack {
                                            UserRatingsView(rating: trailItem.rating)
                                        }
                                        Text(String(format: "%.2f mi", trailItem.distance ?? 0.0))
                                            .font(.caption)
                                            .frame(width: nil, height: 20, alignment: .leading)
                                        Text(trailItem.description)
                                            .font(.body)
                                            .frame(width: nil, height: 75, alignment: .leading)
            }
        }
    }
}

//
//  TrailListRow.swift
//  AccuterraSampleApp
//
//  Created by Brian Elliott on 5/1/20.
//  Copyright © 2020 NeoTreks, Inc. All rights reserved.
//

import SwiftUI

struct TrailListRow: View {
    var trailName: String
    let rowImage:Image = Image(systemName: "globe")

    var body: some View {
        HStack {
            rowImage
                .resizable()
                .frame(width:15, height:15)
            Text(trailName)
            Spacer()
        }
    }
}

struct TrailListRow_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            TrailListRow(trailName: "Trail 1")
            TrailListRow(trailName: "Trail 2")
        }
        .previewLayout(.fixed(width: 300, height: 50))
    }
}


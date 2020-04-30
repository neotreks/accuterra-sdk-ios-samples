//
//  TrailDetailsViewModel.swift
//  AccuterraSampleApp
//
//  Created by Brian Elliott on 4/25/20.
//  Copyright © 2020 NeoTreks, Inc. All rights reserved.
//

import SwiftUI
import Combine
import AccuTerraSDK

class TrailDetailsViewModel: ObservableObject {
    
    var trailDetails = [(name: String, values: [(key: String, value: String)])]()
    @Published var trailId:Int64 = 0

    func getTrailDetails(trailId:Int64) {
        if trailId > 0 {
            let trailDetailsInfo = TrailDetailsInfo(trailId: trailId)
            for i in 0..<15 + trailDetailsInfo.waypoints.count {
                if let itemArray = trailDetailsInfo.getSection(sectionId:i) {
                    let sectionName = itemArray.name
                    var itemIds = itemArray.values.makeIterator()
                    var rows = [(key: String, value: String)]()
                    if itemArray.values.count <= 0 {
                        rows.append((key:"No Information Available", value:""))
                    }
                    else {
                        while let next = itemIds.next() {
                            if next.value.count > 0 {
                                rows.append((key:next.key.trimmingCharacters(in: .whitespacesAndNewlines), value:next.value.trimmingCharacters(in: .whitespacesAndNewlines)))
                            }
                            else {
                                rows.append((key:next.key.trimmingCharacters(in: .whitespacesAndNewlines), value:"N/A"))
                            }
                        }
                    }
                    trailDetails.append((name: sectionName, values: rows))
                }
            }
            objectWillChange.send()
        }
    }
}


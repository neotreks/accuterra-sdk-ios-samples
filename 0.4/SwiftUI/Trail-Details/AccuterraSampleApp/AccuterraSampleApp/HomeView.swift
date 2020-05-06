//
//  ContentView.swift
//  AccuterraSampleApp
//
//  Created by Brian Elliott on 5/3/20.
//  Copyright © 2020 NeoTreks, Inc. All rights reserved.
//

import SwiftUI
import AccuTerraSDK
import Mapbox

struct HomeView: View {
    
    @EnvironmentObject var viewRouter: ViewRouter
    @State var selectedTrailId:Int64 = 0

    
    var body: some View {
        VStack() {
            MapView(selectedTrailId: $selectedTrailId)
            Spacer()
            HStack(spacing: 30) {
                if selectedTrailId == 0 {
                    Text("Picked Trail ID: N/A")
                }
                else {
                    Text("Picked Trail ID: \(selectedTrailId)")
                }
                NavigationLink(destination: DetailView(trailId:selectedTrailId)) {
                    Text("Trail Details")
                }
            }
            .padding()
        }
    }
}


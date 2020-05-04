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
    
    // @ObservedObject var viewRouter: ViewRouter
    @ObservedObject var vm = TrailsViewModel()
    
    init() {
        vm.doTrailsSearch()
    }
    
    var body: some View {
        VStack() {
            MapView()
            .edgesIgnoringSafeArea(.vertical)
            Spacer()
            HStack(spacing: 10) {
                Text("Number of trails: \(vm.trailCount)")
                if vm.trails != nil {
                    NavigationLink(destination: TrailListView(trails:vm.trails!)) {
                        Text("Trail List")
                    }
                }
            }
        }
    }
}


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
    @ObservedObject var vm = TrailsViewModel()
    
    init() {
        print("HomeView init ...")
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

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView().environmentObject(ViewRouter())
    }
}


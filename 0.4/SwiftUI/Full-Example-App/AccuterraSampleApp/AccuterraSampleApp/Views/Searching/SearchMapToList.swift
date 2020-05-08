//
//  SearchingMapToList.swift
//  AccuterraSampleApp
//
//  Created by Brian Elliott on 4/17/20.
//  Copyright © 2020 NeoTreks, Inc. All rights reserved.
//

import SwiftUI
import AccuTerraSDK
import Mapbox
import Combine

struct SearchMapToList: View {
    
    @Environment(\.presentationMode) var mode: Binding<PresentationMode>
    @EnvironmentObject var env: AppEnvironment
    @State var alertMessages = MapAlertMessages()
    @State var filter = TrailsFilter()
    @ObservedObject var vm = TrailsViewModel()
    var featureToggles = FeatureToggles(displayTrails: true, allowTrailTaps: true, allowPOITaps: false, updateSearchByMapBounds:true, filteringOn:true)
    var mapVm = MapViewModel()

//    init() {
//        vm.getTrailsByBounds()
//    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                MapView(features: self.featureToggles, mapAlerts:self.$alertMessages)
                    .frame(width: geometry.size.width, height: geometry.size.height / 2)
                    .background(Color.orange)
                List {
                    if self.vm.trails != nil {
                        ForEach(self.vm.trails!.indices, id: \.self){ idx in
                            HStack {
                                Text(self.vm.trails![idx].name)
                            }
                        }
                    }
                    else {
                        Text("No trails found!")
                    }
                }
                .frame(width: geometry.size.width, height: geometry.size.height / 2)
            }
        }
        .navigationBarTitle(Text("Search Map to List"), displayMode: .inline)
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(leading: Button(action : {
                self.env.mapIntEnv.resetEnv()
                self.mode.wrappedValue.dismiss()
            }){
                Image(systemName: "arrow.left")
            })
    }
}

extension View {
    func Print(_ vars: Any...) -> some View {
        for v in vars { print(v) }
        return EmptyView()
    }
}

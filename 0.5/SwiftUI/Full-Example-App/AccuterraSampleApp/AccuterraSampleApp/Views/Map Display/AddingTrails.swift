//
//  AddingTrails.swift
//  AccuterraSampleApp
//
//  Created by Brian Elliott on 4/17/20.
//  Copyright © 2020 NeoTreks, Inc. All rights reserved.
//

import SwiftUI
import AccuTerraSDK
import Mapbox
import Combine

struct AddingTrails: View {
    
    @Environment(\.presentationMode) var mode: Binding<PresentationMode>
    @EnvironmentObject var env: AppEnvironment
    @ObservedObject var vm = TrailsViewModel()
    @State var mapInteractions = MapInteractions()
    var featureToggles = FeatureToggles(displayTrails: true, allowTrailTaps: false, allowPOITaps: false)
    @State var alertMessages = MapAlertMessages()
    let initialMapDefaults:MapInteractions = MapInteractions()
    var mapVm = MapViewModel()
    
    init() {
        vm.doTrailsSearch()
    }

    var body: some View {
        VStack() {
            MapView(features: featureToggles, mapAlerts:$alertMessages)
            Spacer()
            HStack(spacing: 10) {
                Text("Number of trails: \(vm.trailCount)")
                if vm.trails != nil {
                    NavigationLink(destination: TrailListView(trails:vm.trails!)) {
                        Text("Trail List")
                    }
                }
            }
            .padding()
            .alert(isPresented:$alertMessages.displayAlert) {
                Alert(title: Text(alertMessages.title), message: Text(alertMessages.message), dismissButton: .default(Text("OK")))
            }
        }
        .navigationBarTitle(Text("Adding Trails"), displayMode: .inline)
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(leading: Button(action : {
                self.env.mapIntEnv.resetEnv()
                self.mode.wrappedValue.dismiss()
            }){
                Image(systemName: "arrow.left")
            })
    }
    
}

struct AddingTrails_Previews: PreviewProvider {
    static var previews: some View {
        return AddingTrails()
    }
}


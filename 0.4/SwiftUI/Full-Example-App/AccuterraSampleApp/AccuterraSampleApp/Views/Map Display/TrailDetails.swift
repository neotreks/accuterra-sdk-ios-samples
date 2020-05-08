//
//  TrailDetails.swift
//  AccuterraSampleApp
//
//  Created by Brian Elliott on 4/17/20.
//  Copyright © 2020 NeoTreks, Inc. All rights reserved.
//

import SwiftUI
import AccuTerraSDK
import Mapbox
import Combine


struct TrailDetails: View {

    @Environment(\.presentationMode) var mode: Binding<PresentationMode>
    @EnvironmentObject var env: AppEnvironment
    var featureToggles = FeatureToggles(displayTrails: true, allowTrailTaps: true, allowPOITaps: false)
    @State var alertMessages = MapAlertMessages()
    var mapVm = MapViewModel()
    let initialMapDefaults:MapInteractions = MapInteractions()
    
    init() {
        initialMapDefaults.defaults.mapBounds = mapVm.getColoradoBounds()
    }
    
    var body: some View {
        VStack() {
            MapView(initialState: initialMapDefaults, features: featureToggles, mapAlerts:$alertMessages)
            Spacer()
            HStack(spacing: 30) {
                if env.mapIntEnv.selectedTrailId == 0 {
                    Text("Picked Trail ID: N/A")
                }
                else {
                    Text("Picked Trail ID: \(env.mapIntEnv.selectedTrailId)")
                }
                NavigationLink(destination: DetailView(trailId:env.mapIntEnv.selectedTrailId)) {
                    Text("Trail Details")
                }
                .disabled(env.mapIntEnv.selectedTrailId == 0)
                .alert(isPresented:$alertMessages.displayAlert) {
                    Alert(title: Text(alertMessages.title), message: Text(alertMessages.message), dismissButton: .default(Text("OK")))
                }
            }
            .padding()
        }
        .navigationBarTitle(Text("Trail Details"), displayMode: .inline)
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(leading: Button(action : {
                self.env.mapIntEnv.resetEnv()
                self.mode.wrappedValue.dismiss()
            }){
                Image(systemName: "arrow.left")
            })
    }
}

struct TrailDetails_Previews: PreviewProvider {
    static var previews: some View {
        return TrailDetails()
    }
}

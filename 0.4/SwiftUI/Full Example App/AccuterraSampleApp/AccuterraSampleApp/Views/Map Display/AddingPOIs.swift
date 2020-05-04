//
//  AddingPOIs.swift
//  AccuterraSampleApp
//
//  Created by Brian Elliott on 4/17/20.
//  Copyright © 2020 NeoTreks, Inc. All rights reserved.
//

import SwiftUI
import AccuTerraSDK
import Mapbox
import Combine

struct AddingPOIs: View {
    
    @Environment(\.presentationMode) var mode: Binding<PresentationMode>
    @EnvironmentObject var env: MapInteractionsEnvironment
    var featureToggles = FeatureToggles(displayTrails: true, allowTrailTaps: true, allowPOITaps: true)
    @State var alertMessages = MapAlertMessages()
    
    var body: some View {
        VStack() {
            MapView(features: featureToggles, mapAlerts:$alertMessages)
            Spacer()
            HStack(spacing: 30) {
                if env.selectedTrailId == 0 {
                    Text("Picked Trail ID: N/A")
                }
                else {
                    Text("Picked Trail ID: \(env.selectedTrailId)")
                }
                NavigationLink(destination: DetailView(trailId:env.selectedTrailId)) {
                    Text("Trail Details")
                }
                .disabled(env.selectedTrailId == 0)
                .alert(isPresented:$alertMessages.displayAlert) {
                    Alert(title: Text(alertMessages.title), message: Text(alertMessages.message), dismissButton: .default(Text("OK")))
                }
            }
            .padding()
        }
        .navigationBarTitle(Text("Adding POIs"), displayMode: .inline)
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(leading: Button(action : {
                self.env.resetEnv()
                self.mode.wrappedValue.dismiss()
            }){
                Image(systemName: "arrow.left")
            })
    }
    
}

struct AddingPOIs_Previews: PreviewProvider {
    static var previews: some View {
        return CreateMap()
    }
}

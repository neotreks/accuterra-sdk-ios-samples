//
//  Create_a_Map.swift
//  AccuterraSampleApp
//
//  Created by Brian Elliott on 4/17/20.
//  Copyright © 2020 NeoTreks, Inc. All rights reserved.
//

import SwiftUI
import AccuTerraSDK
import Mapbox
import Combine

struct CreateMap: View {
    
    @Environment(\.presentationMode) var mode: Binding<PresentationMode>
    @State var mapInteractions = MapInteractions()
    var featureToggles = FeatureToggles(displayTrails: false, allowTrailTaps: false, allowPOITaps: false)
    @State var alertMessages = MapAlertMessages()
    
    var body: some View {
        MapView(mapInteractions:$mapInteractions, features: featureToggles, mapAlerts:$alertMessages)
        .navigationBarTitle(Text("Create a Map"), displayMode: .inline)
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(leading: Button(action : {
                self.mode.wrappedValue.dismiss()
            }){
                Image(systemName: "arrow.left")
            })
        .edgesIgnoringSafeArea([.bottom])
    }
    
}

struct CreateMap_Previews: PreviewProvider {
    static var previews: some View {
        return CreateMap()
    }
}

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
    @EnvironmentObject var settings: AppSettings
    
    @ObservedObject var mapInteraction = MapInteraction()
    @State var annotations: [MGLPointAnnotation] = [
        MGLPointAnnotation(title: "Mapbox", coordinate: .init(latitude: 37.791434, longitude: -122.396267))
    ]
    @State var selectedTrailId:Int64 = 0
    var featureToggles = FeatureToggles(displayTrails: false, allowTrailTaps: false, allowPOITaps: false)
    
    var body: some View {
        MapView(annotations: $annotations, selectedTrailId: $selectedTrailId, mapCenter: self.mapInteraction.mapCenter, mapBounds: self.mapInteraction.mapBounds, zoomAnimation: self.mapInteraction.zoomAnimation, features: featureToggles)
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

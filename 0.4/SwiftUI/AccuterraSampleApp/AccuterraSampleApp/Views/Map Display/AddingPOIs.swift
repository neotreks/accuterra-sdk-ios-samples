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
    @ObservedObject var mapInteraction = MapInteraction()
    @State var annotations: [MGLPointAnnotation] = [
        MGLPointAnnotation(title: "Mapbox", coordinate: .init(latitude: 37.791434, longitude: -122.396267))
    ]
    @State var selectedTrailId:Int64 = 0
    var featureToggles = FeatureToggles(displayTrails: true, allowTrailTaps: true, allowPOITaps: true)
    
    var body: some View {
        VStack() {
            MapView(annotations: $annotations, selectedTrailId: $selectedTrailId, mapCenter: self.mapInteraction.mapCenter, mapBounds: self.mapInteraction.mapBounds, zoomAnimation: self.mapInteraction.zoomAnimation, features: featureToggles)
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
                .disabled(selectedTrailId == 0)
            }
            .padding()
        }
        .navigationBarTitle(Text("Adding POIs"), displayMode: .inline)
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(leading: Button(action : {
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


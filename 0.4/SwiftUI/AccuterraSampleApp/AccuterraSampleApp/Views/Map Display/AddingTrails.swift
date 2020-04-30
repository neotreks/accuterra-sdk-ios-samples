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
    @EnvironmentObject var settings: AppSettings
    @ObservedObject var mapInteraction = MapInteraction()
    @ObservedObject var vm = TrailsViewModel()
    var featureToggles = FeatureToggles(displayTrails: true, allowTrailTaps: false, allowPOITaps: false)

    @State var annotations: [MGLPointAnnotation] = [
        MGLPointAnnotation(title: "Mapbox", coordinate: .init(latitude: 37.791434, longitude: -122.396267))
    ]
    @State var selectedTrailId:Int64 = 0
    
    init() {
        vm.doTrailsSearch()
    }

    var body: some View {
        VStack() {
            MapView(annotations: $annotations, selectedTrailId: $selectedTrailId, mapCenter: self.mapInteraction.mapCenter, mapBounds: self.mapInteraction.mapBounds, zoomAnimation: self.mapInteraction.zoomAnimation, features: featureToggles)
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
        }
        .navigationBarTitle(Text("Adding Trails"), displayMode: .inline)
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(leading: Button(action : {
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


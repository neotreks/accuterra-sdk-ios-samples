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
    @ObservedObject var mapInteraction = MapInteraction()
    @ObservedObject var vm = TrailsViewModel()
    @State private var showingAlert = false
    @State var annotations: [MGLPointAnnotation] = [
        MGLPointAnnotation(title: "Mapbox", coordinate: .init(latitude: 37.791434, longitude: -122.396267))
    ]
    @State var selectedTrail:Int64 = 0

    var body: some View {
                Text("hello")
//        VStack() {
//            ZStack(alignment: .top) {
////                MapView(annotations: $annotations, mapCenter: self.mapInteraction.mapCenter, mapBounds: self.mapInteraction.mapBounds, zoomAnimation: self.mapInteraction.zoomAnimation ).initMap()
//                MapView(annotations: $annotations, mapCenter: self.mapInteraction.mapCenter, mapBounds: self.mapInteraction.mapBounds, zoomAnimation: self.mapInteraction.zoomAnimation, selectedTrail: $selectedTrail )
//            }
//            Spacer()
////            HStack(spacing: 10) {
////                Text("Number of trails: \(vm.trailCount)")
////                Button(action: {
////                    self.showingAlert = true
////                    self.vm.doTrailsSearch()
////                }) {
////                    Text("Get All Trails")
////                }
////                .alert(isPresented: $showingAlert) {
////                    Alert(title: Text("Trail Info"), message: Text("Number of Trails: \(vm.trailCount)"), dismissButton: .default(Text("OK")))
////                }
// //           }
//            .padding()
//        }
//        .navigationBarTitle(Text("Adding Trails"), displayMode: .inline)
//            .navigationBarBackButtonHidden(true)
//            .navigationBarItems(leading: Button(action : {
//                self.mode.wrappedValue.dismiss()
//            }){
//                Image(systemName: "arrow.left")
//            })
    }
    
}

struct AddingTrails_Previews: PreviewProvider {
    static var previews: some View {
        return AddingTrails()
    }
}


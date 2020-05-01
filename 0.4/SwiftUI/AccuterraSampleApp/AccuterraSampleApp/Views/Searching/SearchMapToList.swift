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

    
    var body: some View {
                Text("hello")
//        ZStack(alignment: .top) {
////            MapView(annotations: $annotations, mapCenter: self.mapInteraction.mapCenter, mapBounds: self.mapInteraction.mapBounds, zoomAnimation: self.mapInteraction.zoomAnimation ).initMap()
//            MapView(annotations: $annotations, mapCenter: self.mapInteraction.mapCenter, mapBounds: self.mapInteraction.mapBounds, zoomAnimation: self.mapInteraction.zoomAnimation, selectedTrail: $selectedTrail )
//        }
//        .navigationBarTitle(Text("Adding POIs"), displayMode: .inline)
//            .navigationBarBackButtonHidden(true)
//            .navigationBarItems(leading: Button(action : {
//                self.mode.wrappedValue.dismiss()
//            }){
//                Image(systemName: "arrow.left")
//            })
//        .edgesIgnoringSafeArea([.bottom])
    }
    
}

struct SearchMapToList_Previews: PreviewProvider {
    static var previews: some View {
        return CreateMap()
    }
}

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
    @ObservedObject var mapInteraction = MapInteraction()
    @State var selectedTrailId:Int64 = 0
    
    @State var annotations: [MGLPointAnnotation] = [
        MGLPointAnnotation(title: "Mapbox", coordinate: .init(latitude: 37.791434, longitude: -122.396267))
    ]
    
    var body: some View {
        VStack() {
            ZStack(alignment: .top) {
                MapView(annotations: $annotations, mapCenter: self.mapInteraction.mapCenter, mapBounds: self.mapInteraction.mapBounds, zoomAnimation: self.mapInteraction.zoomAnimation, selectedTrailId: $selectedTrailId, mapTappingActive: true)
            }
            Spacer()
            HStack(spacing: 30) {
                Text("Trail ID: \(selectedTrailId)")
                NavigationLink(destination: DetailView(trailId:selectedTrailId)) {
                    Text("Trail Details")
                }
            }
            .padding()
        }
        .navigationBarTitle(Text("Trail Details"), displayMode: .inline)
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(leading: Button(action : {
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

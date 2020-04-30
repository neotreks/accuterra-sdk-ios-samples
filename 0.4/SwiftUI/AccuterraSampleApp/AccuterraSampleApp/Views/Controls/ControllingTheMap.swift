//
//  ControllingTheMap.swift
//  AccuterraSampleApp
//
//  Created by Brian Elliott on 4/17/20.
//  Copyright © 2020 NeoTreks, Inc. All rights reserved.
//

import SwiftUI
import AccuTerraSDK
import Mapbox
import Combine

struct ControllingTheMap: View {
    
    @Environment(\.presentationMode) var mode: Binding<PresentationMode>
    @ObservedObject var mapInteraction = MapInteraction()
    @State var annotations: [MGLPointAnnotation] = [
        MGLPointAnnotation(title: "Mapbox", coordinate: .init(latitude: 37.791434, longitude: -122.396267))
    ]
    @State var selectedTrailId:Int64 = 0
    var featureToggles = FeatureToggles(displayTrails: true, allowTrailTaps: true, allowPOITaps: true)
    
    var body: some View {
        ZStack(alignment: .top) {
            MapView(annotations: $annotations, selectedTrailId: $selectedTrailId, mapCenter: self.mapInteraction.mapCenter, mapBounds: self.mapInteraction.mapBounds, zoomAnimation: self.mapInteraction.zoomAnimation, features: featureToggles)
            .edgesIgnoringSafeArea(.vertical)
            VStack(spacing: 20) {
                Text("Go to Location:")
                HStack {
                    Button(action: {
                        self.mapInteraction.mapCenter = nil
                        self.mapInteraction.zoomAnimation = false
                        self.mapInteraction.mapBounds = MapInteraction.getColoradoBounds()
                    }, label: {
                        Text("CO")
                        .padding()
                            .background(Color.white)
                    })
                    Button(action: {
                        self.mapInteraction.mapBounds = nil
                        self.mapInteraction.zoomAnimation = false
                        self.mapInteraction.mapCenter = MapInteraction.getDenverLocation()
                    }, label: {
                        Text("Denver")
                        .padding()
                        .background(Color.white)
                    })
                    Button(action: {
                        self.mapInteraction.mapBounds = nil
                        self.mapInteraction.zoomAnimation = true
                        self.mapInteraction.mapCenter = MapInteraction.getCastleRockLocation()
                    }, label: {
                        Text("Castle Rock")
                        .padding()
                            .background(Color.white)
                    })
                }.shadow(radius: 3)
            }
            .frame(height: 100.0)
        }
        .navigationBarTitle(Text("Controlling the Map"), displayMode: .inline)
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(leading: Button(action : {
                self.mode.wrappedValue.dismiss()
            }){
                Image(systemName: "arrow.left")
            })
    }
}

struct ControllingTheMap_Previews: PreviewProvider {
    static var previews: some View {
        return CreateMap()
    }
}

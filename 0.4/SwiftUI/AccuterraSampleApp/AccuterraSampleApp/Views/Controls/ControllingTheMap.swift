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
    var mapVm = MapViewModel()
    @State var mapInteractions = MapInteractions()
    var featureToggles = FeatureToggles(displayTrails: true, allowTrailTaps: true, allowPOITaps: true)

    var body: some View {
        ZStack(alignment: .top) {
            MapView(mapInteractions:$mapInteractions, features: featureToggles)
            .edgesIgnoringSafeArea(.vertical)
            VStack(spacing: 20) {
                Text("Go to Location:")
                HStack {
                    Button(action: {
                        self.mapInteractions = self.mapVm.setColoradoBounds()
                    }, label: {
                        Text("CO")
                        .padding()
                            .background(Color.white)
                    })
                    Button(action: {
                        self.mapInteractions = self.mapVm.setDenverLocation()
                    }, label: {
                        Text("Denver")
                        .padding()
                        .background(Color.white)
                    })
                    Button(action: {
                        self.mapInteractions = self.mapVm.setCastleRockLocation()
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

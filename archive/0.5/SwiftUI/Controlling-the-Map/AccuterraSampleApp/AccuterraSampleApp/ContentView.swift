//
//  ContentView.swift
//  AccuterraSampleApp
//
//  Created by Brian Elliott on 5/3/20.
//  Copyright © 2020 NeoTreks, Inc. All rights reserved.
//

import SwiftUI
import AccuTerraSDK
import Mapbox

struct ContentView: View {
    
    @ObservedObject var mapInteraction = MapInteraction()
    
    var body: some View {
        ZStack(alignment: .top) {
            MapView(mapCenter: self.mapInteraction.mapCenter, mapBounds: self.mapInteraction.mapBounds, zoomAnimation: self.mapInteraction.zoomAnimation)
            .edgesIgnoringSafeArea(.vertical)
            VStack(spacing: 20) {
                Text("Go to Location:")
                HStack {
                    Button(action: {
                        print("CO tapped!")
                        self.mapInteraction.mapCenter = nil
                        self.mapInteraction.zoomAnimation = false
                        self.mapInteraction.mapBounds = MapInteraction.getColoradoBounds()
                    }, label: {
                        Text("CO")
                        .padding()
                            .background(Color.white)
                    })
                    Button(action: {
                        print("Denver tapped!")
                        self.mapInteraction.mapBounds = nil
                        self.mapInteraction.zoomAnimation = false
                        self.mapInteraction.mapCenter = MapInteraction.getDenverLocation()
                    }, label: {
                        Text("Denver")
                        .padding()
                        .background(Color.white)
                    })
                    Button(action: {
                        print("Castle Rock tapped!")
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
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

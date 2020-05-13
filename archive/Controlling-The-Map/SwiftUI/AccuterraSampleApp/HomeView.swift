//
//  HomeView.swift
//  AccuterraSampleApp
//
//  Created by Brian Elliott on 3/15/20.
//  Copyright © 2020 BaseMap. All rights reserved.
//

import SwiftUI
import AccuTerraSDK
import Mapbox
import Combine

struct HomeView: View {
    
    @ObservedObject var mapInteraction = MapInteraction()
    
    var body: some View {
        ZStack(alignment: .top) {
            MapView(mapCenter: self.mapInteraction.mapCenter, mapBounds: self.mapInteraction.mapBounds, zoomAnimation: self.mapInteraction.zoomAnimation ).initMap()
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

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
//        let mapView = MapView(mapInteraction: MapInteraction(), mapView: AccuTerraMapView(frame: zero))
//        HomeView(mapView.initMap())
       // let map = AccuTerraMapView(frame: .zero)
        return HomeView()
    }
}

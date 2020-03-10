//
//  ContentView.swift
//  Create-a-Map
//
//  Created by Brian Elliott on 3/10/20.
//  Copyright © 2020 BaseMap. All rights reserved.
//

import SwiftUI
import Mapbox
import AccuTerraSDK

struct ContentView: View {
    var body: some View {
        NavigationView {
            ZStack(alignment: Alignment.top) {
                MapView().initMap()
            }
            .edgesIgnoringSafeArea(.vertical)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

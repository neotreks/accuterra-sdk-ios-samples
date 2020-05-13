//
//  TrailListView.swift
//  AccuterraSampleApp
//
//  Created by Brian Elliott on 5/3/20.
//  Copyright © 2020 NeoTreks, Inc. All rights reserved.
//

import SwiftUI
import AccuTerraSDK
import Mapbox
import Combine

struct TrailListView: View {
    
    @Environment(\.presentationMode) var mode: Binding<PresentationMode>
    var trails: Array<TrailBasicInfo>

    var body: some View {
        List {
            ForEach(trails.indices, id: \.self){ idx in
                Text(self.trails[idx].name)
            }
        }
        .navigationBarTitle(Text("Trail List"), displayMode: .inline)
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(leading: Button(action : {
                self.mode.wrappedValue.dismiss()
            }){
                Image(systemName: "arrow.left")
            })

    }
    
}

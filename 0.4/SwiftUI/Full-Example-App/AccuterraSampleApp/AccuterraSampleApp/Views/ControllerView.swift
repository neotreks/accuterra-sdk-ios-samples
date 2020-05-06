//
//  ControllerView.swift
//  AccuterraSampleApp
//
//  Created by Brian Elliott on 5/3/20.
//  Copyright © 2020 NeoTreks, Inc. All rights reserved.
//
import SwiftUI

struct ControllerView : View {
    
    @EnvironmentObject var appEnv: AppEnvironment
    
    var body: some View {
            VStack {
                if appEnv.currentPage == "download" {
                    DownloadView()
                } else if appEnv.currentPage == "home" {
                    NavigationView {
                        HomeView()
                        .navigationBarTitle(Text("AccuTerra SDK SwiftUI Samples"), displayMode: .inline)
                    }
                }
            }
    }
}

struct ControllerView_Previews : PreviewProvider {
    static var previews: some View {
        ControllerView().environmentObject(ViewRouter())
    }
}

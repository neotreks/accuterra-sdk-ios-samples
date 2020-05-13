//
//  ControllerView.swift
//  AccuterraSampleApp
//
//  Created by Brian Elliott on 5/3/20.
//  Copyright © 2020 NeoTreks, Inc. All rights reserved.
//
import SwiftUI

struct ControllerView : View {
    
    @EnvironmentObject var viewRouter: ViewRouter
    
    var body: some View {
            VStack {
                if viewRouter.currentPage == "download" {
                    DownloadView()
                } else if viewRouter.currentPage == "home" {
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

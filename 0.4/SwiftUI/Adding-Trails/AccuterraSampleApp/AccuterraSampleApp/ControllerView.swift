//
//  ControllerView.swift
//  AccuterraSampleApp
//
//  Created by Brian Elliott on 5/3/20.
//  Copyright © 2020 NeoTreks, Inc. All rights reserved.
//
import SwiftUI

struct ControllerView : View {
    
    @ObservedObject var viewRouter: ViewRouter
    
    var body: some View {
            VStack {
                if viewRouter.currentPage == "download" {
                    DownloadView(viewRouter: viewRouter)
                } else if viewRouter.currentPage == "home" {
                    NavigationView {
                        // HomeView(viewRouter: viewRouter)
                        HomeView()
                        .navigationBarTitle(Text("AccuTerra SDK SwiftUI Samples"), displayMode: .inline)
                    }
                }
            }
    }
}

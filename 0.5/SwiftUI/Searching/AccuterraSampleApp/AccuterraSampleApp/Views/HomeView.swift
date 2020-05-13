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

struct HomeView: View {
    
    @Environment(\.presentationMode) var mode: Binding<PresentationMode>
    @EnvironmentObject var viewRouter: ViewRouter
    @ObservedObject var vm = MapSearchingViewModel()
    @State var alertMessages = MapAlertMessages()
    @State private var firstTime = true
    @State var reset:Bool = false
    var mapVm = MapViewModel()

    var body: some View {
        ZStack(alignment: .top) {
            MapView(selectedTrailId: vm.selectedMapItem, defaultBounds: vm.defaultMapBounds, mapAlerts: alertMessages, resetMap:$reset)
            .edgesIgnoringSafeArea(.all)
            VStack(spacing: 12) {
                if !firstTime || vm.selectedMapItem > 0 {
                    Button(action: {
                        self.reset = true
                        self.vm.resetTrails()
                    }) {
                        Text("Clear")
                        .padding()
                        .background(Color.white)
                        .cornerRadius(25)
                    }
                    .padding(10.0)
                    .cornerRadius(5)
                }
                else {
                    HStack {
                        TextField("Search terms", text: $vm.searchQuery, onCommit: {
                            self.firstTime = false
                            UIApplication.shared.windows.filter {$0.isKeyWindow}.first?.endEditing(true)
                        })
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(Color.white)
                    }.padding()
                }
                
                if vm.isSearching {
                    Text("Searching...")
                }

                Spacer().frame(maxHeight: .infinity)
                ScrollView(.horizontal) {
                    HStack(spacing: 16) {
                        if vm.trails.count > 0 {
                            ForEach(vm.trails, id: \.self) { item in
                                VStack {
                                      Button(action: {
                                        self.vm.selectedMapItem = item.trailId
                                      }, label: {
                                        VStack(alignment: .leading, spacing: 4) {
                                             TrailCard(trailItem: item)
                                        }
                                      }).foregroundColor(.black)
                                      .padding()
                                          .frame(width: 275, height: 200)
                                          .background(Color.white)
                                      .cornerRadius(5)
                                }
                            }
                        }
                    }
                    .frame(maxHeight: .infinity)
                    .padding(.horizontal, 16)
                }.shadow(radius: 5)
                    .frame(maxHeight: 200)
                .edgesIgnoringSafeArea([.bottom])
                .alert(isPresented:$alertMessages.displayAlert) {
                    Alert(title: Text(alertMessages.title), message: Text(alertMessages.message), dismissButton: .default(Text("OK")))
                }
                Spacer().frame(height: vm.keyboardHeight)
            }
       }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}



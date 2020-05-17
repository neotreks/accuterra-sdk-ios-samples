//
//  MapSearchingView.swift
//  AccuterraSampleApp
//
//  Created by Brian Elliott on 5/1/20.
//  Copyright © 2020 NeoTreks, Inc. All rights reserved.
//
import SwiftUI
import AccuTerraSDK
import Mapbox
import Combine

struct MapSearchingView: View {
    
    @ObservedObject var vm = MapSearchingViewModel()
    @Environment(\.presentationMode) var mode: Binding<PresentationMode>
    @EnvironmentObject var env: AppEnvironment
    var featureToggles = FeatureToggles(displayTrails: true, allowTrailTaps: true, allowPOITaps: true)
    @State var alertMessages = MapAlertMessages()
    var mapVm = MapViewModel()
        
    var body: some View {
        ZStack(alignment: .top) {
            MapView(features: featureToggles, mapAlerts:$alertMessages)
            .edgesIgnoringSafeArea(.all)
            VStack(spacing: 12) {
                if self.env.mapIntEnv.selectedTrailId > 0 {
                    Button(action: {
                        self.env.mapIntEnv.mapBounds = self.mapVm.getColoradoBounds()
                        self.env.mapIntEnv.selectedTrailId = 0
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
                                        let id = item.trailId
                                        self.env.mapIntEnv.selectedTrailId = id
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
                .navigationBarTitle(Text("Search Map"), displayMode: .inline)
                    .navigationBarBackButtonHidden(true)
                    .navigationBarItems(leading: Button(action : {
                        self.env.mapIntEnv.resetEnv()
                        self.mode.wrappedValue.dismiss()
                    }){
                        Image(systemName: "arrow.left")
                    })
                .edgesIgnoringSafeArea([.bottom])
                .alert(isPresented:$alertMessages.displayAlert) {
                    Alert(title: Text(alertMessages.title), message: Text(alertMessages.message), dismissButton: .default(Text("OK")))
                }
                Spacer().frame(height: vm.keyboardHeight)
            }
       }
    }
}

struct MapSearchingView_Previews: PreviewProvider {
    static var previews: some View {
        MapSearchingView()
    }
}

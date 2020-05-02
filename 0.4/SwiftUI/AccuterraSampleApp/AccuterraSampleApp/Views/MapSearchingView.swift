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
    var featureToggles = FeatureToggles(displayTrails: true, allowTrailTaps: true, allowPOITaps: true)
    @State var mapInteractions = MapInteractions()
    @State var alertMessages = MapAlertMessages()
    
    var body: some View {
        ZStack(alignment: .top) {
            MapView(mapInteractions:$mapInteractions, features: featureToggles, mapAlerts:$alertMessages)
            // MapViewContainer()
            .edgesIgnoringSafeArea(.all)
            VStack(spacing: 12) {
                HStack {
                    TextField("Search terms", text: $vm.searchQuery, onCommit: {
                        UIApplication.shared.windows.filter {$0.isKeyWindow}.first?.endEditing(true)
                    })
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color.white)
                }.padding()

                if vm.isSearching {
                    Text("Searching...")
                }

                Spacer()

                ScrollView(.horizontal) {
                    HStack(spacing: 16) {
                        ForEach(vm.trails, id: \.self) { item in
                            Button(action: {
                                print(item.title)
                                print("test")
                                // self.vm.selectedMapItem = item

                            }, label: {
                                TrailCard(trailItem: item)
//                                VStack(alignment: .leading, spacing: 4) {
//                                    Text(item.title)
//                                        .font(.headline)
//                                    Text(item.description)
//                                    .lineLimit(2)
//                                }
                            }).foregroundColor(.black)

                            .padding()
                                .frame(width: 275, height: 175)
                                .background(Color.white)
                            .cornerRadius(5)
                        }
                    }
                    .padding(.horizontal, 16)
                }.shadow(radius: 5)
                .navigationBarTitle(Text("Search Map"), displayMode: .inline)
                    .navigationBarBackButtonHidden(true)
                    .navigationBarItems(leading: Button(action : {
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

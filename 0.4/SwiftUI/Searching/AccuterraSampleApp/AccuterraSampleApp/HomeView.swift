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
    @State var selectedTrailId:Int64 = 0
    @State var alertMessages = MapAlertMessages()
    var mapVm = MapViewModel()
    
    var body: some View {
        ZStack(alignment: .top) {
            MapView(selectedTrailId: $selectedTrailId, mapAlerts:$alertMessages)
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
                            }, label: {
                                TrailCard(trailItem: item)
                            }).foregroundColor(.black)
                            .padding()
                                .frame(width: 275, height: 200)
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

extension View {
    func Print(_ vars: Any...) -> some View {
        for v in vars { print(v) }
        return EmptyView()
    }
}



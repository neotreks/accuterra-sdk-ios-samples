//
//  DetailView.swift
//  AccuterraSampleApp
//
//  Created by Brian Elliott on 4/29/20.
//  Copyright © 2020 NeoTreks, Inc. All rights reserved.
//

import SwiftUI
import AccuTerraSDK
import Mapbox
import Combine

struct DetailRowItemView: View, Identifiable, Hashable {
    static func == (lhs: DetailRowItemView, rhs: DetailRowItemView) -> Bool {
        return lhs.id == rhs.id
    }

    let id: UUID
    let values:(key: String, value: String)
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(values.key)
                .fontWeight(.bold)
                .font(.headline)
            if values.value.count > 0 {
                Text(values.value)
                .fontWeight(.regular)
            }
        }
    }

    init(values:(key: String, value: String)) {
        self.id = UUID()
        self.values = values
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct DetailView: View {

    @Environment(\.presentationMode) var mode: Binding<PresentationMode>
    @ObservedObject var trailDetailsVM = TrailDetailsViewModel()
    var trailId:Int64 = 0
    
    init(trailId:Int64) {
        trailDetailsVM.getTrailDetails(trailId: trailId)
    }

    @State var annotations: [MGLPointAnnotation] = [
        MGLPointAnnotation(title: "Mapbox", coordinate: .init(latitude: 37.791434, longitude: -122.396267))
    ]
    
    var body: some View {
        List {
            ForEach(trailDetailsVM.trailDetails.indices, id: \.self){ idx in
                Section(header: Text(self.trailDetailsVM.trailDetails[idx].name)) {
                    ForEach(self.trailDetailsVM.trailDetails[idx].values.indices ) { index in
                        DetailRowItemView(values: self.trailDetailsVM.trailDetails[idx].values[index])
                    }
                }
            }
        }
        .navigationBarTitle(Text("Trail Info"), displayMode: .inline)
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(leading: Button(action : {
                self.mode.wrappedValue.dismiss()
            }){
                Image(systemName: "arrow.left")
            })

    }
    
    struct DetailView_Previews: PreviewProvider {
        static var previews: some View {
            return DetailView(trailId: 555)
        }
    }
    
}

extension View {
    func Print(_ vars: Any...) -> some View {
        for v in vars { print(v) }
        return EmptyView()
    }
}



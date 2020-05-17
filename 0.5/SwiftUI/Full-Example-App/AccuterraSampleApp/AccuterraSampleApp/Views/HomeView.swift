//
//  ContentView.swift
//  AccuterraSampleApp
//
//  Created by Brian Elliott on 4/16/20.
//  Copyright © 2020 NeoTreks, Inc. All rights reserved.
//

import SwiftUI

struct ListItems: Identifiable {
    var id = UUID()
    var section: String
    var navLinkItems:Array<NavLinkView>
}

struct NavLinkView: Identifiable, Hashable {

    let id: UUID
    let title: String
    let destination: AnyView

    init(title: String, destination: AnyView) {
        self.id = UUID()
        self.title = title
        self.destination = destination
    }
    
    static func == (lhs: NavLinkView, rhs: NavLinkView) -> Bool {
      return lhs.title == rhs.title
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(title)
    }
}

struct HomeView: View {
    
    @EnvironmentObject var env: AppEnvironment
    
    var itemArray = [
        ListItems(section:"Map Display", navLinkItems:
                            [NavLinkView(title: "Creating a Map", destination: AnyView(CreateMap())),
                            NavLinkView(title: "Adding Trails", destination: AnyView(AddingTrails())),
                            NavLinkView(title: "Displaying Trail Details", destination: AnyView(TrailDetails())),
                            NavLinkView(title: "Adding POIs", destination: AnyView(AddingPOIs())),
                            ]),
        ListItems(section:"Controls", navLinkItems:
                            [NavLinkView(title: "Controlling the Map", destination: AnyView(ControllingTheMap())),
                            NavLinkView(title: "Interacting with the Map", destination: AnyView(InteractingWithMap())),
                            ]),
        ListItems(section:"Searching", navLinkItems:
                            [NavLinkView(title: "List to Map", destination: AnyView(SearchListToMap())),
                            NavLinkView(title: "Map to List", destination: AnyView(SearchMapToList())),
                            NavLinkView(title: "Search Map", destination: AnyView(MapSearchingView())),
                            ]),
        ListItems(section:"Filtering", navLinkItems:
                            [NavLinkView(title: "Map Filtering", destination: AnyView(FilteringMap()))
                            ]),
    ]
    
    var body: some View {
        List {
            ForEach(itemArray.indices, id: \.self){ idx in
                Section(header: Text(self.itemArray[idx].section)) {
                    ForEach(self.itemArray[idx].navLinkItems, id: \.self) { item in
                        NavigationLink(destination: (item.destination).environmentObject(self.env)) {
                            Text(item.title)
                        }
                     }
                }
            }
        }
        .navigationBarTitle(Text("AccuTerra SDK SwiftUI Samples"), displayMode: .inline)
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}

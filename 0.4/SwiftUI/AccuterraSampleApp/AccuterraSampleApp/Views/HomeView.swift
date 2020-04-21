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
    var items: Array<String>
}

struct HomeView: View {
    
    @ObservedObject var viewRouter: ViewRouter
    
    var itemArray = [
        ListItems(section:"Map Display", items:["Creating a Map", "Adding Trails", "Displaying Trail Details", "Adding POIs"]),
        ListItems(section:"Controls", items:["Controlling the Map", "Interacting with the Map"]),
        ListItems(section:"Searching", items:["List to Map", "Map to List", "Search Term to Map", "Search Term to List"]),
        ListItems(section:"Filtering", items:["Difficulty Filter Criteria", "Map Filtering", "Map Bounds Filtering"]),
        ListItems(section:"Customizing", items:["Custom Trail & POI Styles"])
     ]
    
    var destinationArray = ["CreateMap", "AddingTrails", "TrailDetails", "AddingPOIs", "ControllingTheMap", "InteractingWithMap", "SearchListToMap", "SearchMapToList", "SearchTermToMap", "SearchTermToList", "FilteringCriteria", "FilteringMap", "FilteringMapBounds", "CustomizingTrailsandPOIs"]
    
    var body: some View {
        
            List {
                ForEach(itemArray.indices, id: \.self){ idx in
                    Section(header: Text(self.itemArray[idx].section)) {
                        ForEach(self.itemArray[idx].items, id: \.self) { item in
                            NavigationLink(destination: DisplayItem(item: item)) {
                                Text(item)
                            }
                         }
                    }
                }
            }
            .navigationBarTitle(Text("AccuTerra SDK Samples"), displayMode: .inline)

    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(viewRouter: ViewRouter())
    }
}

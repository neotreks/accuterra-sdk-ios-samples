//
//  MapSearchingViewModel.swift
//  AccuterraSampleApp
//
//  Created by Brian Elliott on 4/27/20.
//  Copyright © 2020 NeoTreks, Inc. All rights reserved.
//

import SwiftUI
import MapKit
import Combine

// keep track of properties that your view needs to render
class MapSearchingViewModel: NSObject, ObservableObject {
    
    @Published var isSearching = false
    @Published var searchQuery = ""
    
    override init() {
        super.init()
        print("Initializing view model")
        // self.performSearch(query: searchQuery)
        
    }
    
    fileprivate func performSearch(query: String) {
        isSearching = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) { // Change `2.0` to the desired number of seconds.
            self.isSearching = true
        }
    }
}

//
//  AppEnvironment.swift
//  AccuterraSampleApp
//
//  Created by Brian Elliott on 5/6/20.
//  Copyright © 2020 NeoTreks, Inc. All rights reserved.
//
import Combine
import AccuTerraSDK
import Mapbox

class AppEnvironment: ObservableObject {
        
    let objectWillChange = PassthroughSubject<AppEnvironment,Never>()
    let mapIntEnv = MapInteractions()
    
    var currentPage: String = "download" {
        didSet {
            objectWillChange.send(self)
        }
    }
}

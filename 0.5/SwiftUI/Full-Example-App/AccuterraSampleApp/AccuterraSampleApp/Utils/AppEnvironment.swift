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
    @Published var mapIntEnv = MapInteractionsEnvironment()
    // View routing: https://blckbirds.com/post/how-to-navigate-between-views-in-swiftui-by-using-an-environmentobject/
    @Published var currentPage: String = "download"
}

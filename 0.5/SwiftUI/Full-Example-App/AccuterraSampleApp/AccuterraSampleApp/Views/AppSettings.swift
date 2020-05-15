//
//  GameSettings.swift
//  AccuterraSampleApp
//
//  Created by Brian Elliott on 4/28/20.
//  Copyright © 2020 NeoTreks, Inc. All rights reserved.
//
import Combine


class AppSettings: ObservableObject {
    @Published var selectedTrailId:Int64 = 0
}

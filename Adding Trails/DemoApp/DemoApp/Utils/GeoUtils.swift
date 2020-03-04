//
//  File.swift
//  DemoApp
//
//  Created by Brian Elliott on 2/7/20.
//  Copyright © 2020 NeoTreks. All rights reserved.
//

import Foundation

public class GeoUtils {

    public static func distanceKilometersToMiles(kilometers: Double) -> String {
        return String(format: "%.1f mi", kilometers * 0.621371)
    }
}

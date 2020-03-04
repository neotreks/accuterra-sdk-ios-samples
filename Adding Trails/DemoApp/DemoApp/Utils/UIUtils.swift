//
//  UIUtils.swift
//  DemoApp
//
//  Created by Brian Elliott on 2/21/20.
//  Copyright © 2020 NeoTreks. All rights reserved.
//

public class UIUtils {
    
    static func getIndexFromTask(task: TaskTypes) -> Int {
        var pointer = 0
        for item in TaskBar.tasks {
            if item.value == task {
                pointer = item.key
                break
            }
        }
        return pointer
    }

    ///
    /// Converts distance in kilometers to miles
    /// - parameters:
    ///    - kilometers: value in km
    /// - returns: distance in miles
    ///
    public static func distanceKilometersToMiles(kilometers: Double) -> String {
        return String(format: "%.1f mi", kilometers * 0.621371)
    }
}

//
//  UIColor.swift
//  AccuterraSampleApp
//
//  Created by Brian Elliott on 3/21/20.
//  Copyright © 2020 NeoTreks, Inc. All rights reserved.
//

import UIKit

extension UIColor {
    
    static func rgb(red: CGFloat, green: CGFloat, blue: CGFloat) -> UIColor {
        return UIColor(red: red/255, green: green/255, blue: blue/255, alpha: 1)
    }
    
    static var Active: UIColor? {
        return UIColor(named: "Active")
    }
    
    static var Inactive: UIColor? {
        return UIColor(named: "Inactive")
    }
    
}

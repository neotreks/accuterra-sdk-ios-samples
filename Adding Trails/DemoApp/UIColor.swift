//
//  UIColor.swift
//  DemoApp
//
//  Created by Brian Elliott on 2/18/20.
//  Copyright © 2020 NeoTreks. All rights reserved.
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
    
    static var TaskbarTextColor: UIColor? {
        return UIColor(named: "TaskbarTextColor")
    }
    
    static var TaskbarActiveTextColor: UIColor? {
        return UIColor(named: "TaskbarActiveTextColor")
    }
    
    static var TaskbarBackgroundColor: UIColor? {
        return UIColor(named: "TaskbarBackgroundColor")
    }
    
    static var TaskbarActiveBarColor: UIColor? {
        return UIColor(named: "TaskbarActiveBarColor")
    }
    
}



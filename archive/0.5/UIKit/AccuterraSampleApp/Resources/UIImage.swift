//
//  UIImage.swift
//  DemoApp
//
//  Created by Brian Elliott on 2/9/20.
//  Copyright © 2020 NeoTreks. All rights reserved.
//

import UIKit

extension UIImage {
    // SF Symbols are supported in iOS 13 but need to be assets for iOS < 13 - so use SF Symbols MacOS app and export to assets
    static var searchImage: UIImage? {
        return UIImage(named: "magnifyingglass")
    }
    static var filterImage: UIImage? {
        return UIImage(named: "filter")
    }
}


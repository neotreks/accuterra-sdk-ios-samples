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
    static var fullStarImage: UIImage? {
        return UIImage(named: "star.fill")
    }
    static var partialStarImage: UIImage? {
        return UIImage(named: "star.lefthalf.fill")
    }
    static var emptyStarImage: UIImage? {
        return UIImage(named: "star")
    }
    static var bookmarkImage: UIImage? {
        return UIImage(named: "bookmark")
    }
    static var chevronRightImage: UIImage? {
        return UIImage(named: "chevron.right")
    }
    static var chevronUpImage: UIImage? {
        return UIImage(named: "chevron.up")
    }
    static var chevronDownImage: UIImage? {
        return UIImage(named: "chevron.down")
    }
    static var mappinAndEllipseImage: UIImage? {
        return UIImage(named: "mappin.and.ellipse")
    }
    static var getThereImage: UIImage? {
        return UIImage(named: "arrow.up.right.diamond.fill")
    }
    static var downloadImage: UIImage? {
        return UIImage(named: "square.and.arrow.down.fill")
    }
    static var startNavigationImage: UIImage? {
        return UIImage(named: "location.north")
    }
    static var currentLocationImage: UIImage? {
        return UIImage(named: "scope")
    }
    static var searchImage: UIImage? {
        return UIImage(named: "magnifyingglass")
    }
    static var filterImage: UIImage? {
        return UIImage(named: "filter")
    }
    
    static func ==(lhs: UIImage, rhs: UIImage) -> Bool {
        if let lhsData = lhs.pngData(), let rhsData = rhs.pngData() {
            return lhsData == rhsData
        }
        return false
    }
}

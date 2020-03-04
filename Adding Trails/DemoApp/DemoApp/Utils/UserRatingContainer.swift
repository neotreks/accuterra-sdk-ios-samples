//
//  UserRatingContainer.swift
//  DemoApp
//
//  Created by Brian Elliott on 2/12/20.
//  Copyright © 2020 NeoTreks. All rights reserved.
//

import Foundation
import UIKit

public class UserRatingContainer {
    var starOne: UIImageView
    var starTwo: UIImageView
    var starThree: UIImageView
    var starFour: UIImageView
    var starFive: UIImageView
    
    public init(one: UIImageView, two: UIImageView, three: UIImageView, four: UIImageView, five: UIImageView) {
        self.starOne = one
        self.starTwo = two
        self.starThree = three
        self.starFour = four
        self.starFive = five
    }
}

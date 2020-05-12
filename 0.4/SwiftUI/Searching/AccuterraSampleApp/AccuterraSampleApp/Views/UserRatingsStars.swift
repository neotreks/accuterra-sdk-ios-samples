//
//  UserRatingsStars.swift
//  AccuterraSampleApp
//
//  Created by Brian Elliott on 5/3/20.
//  Copyright © 2020 NeoTreks, Inc. All rights reserved.
//

enum UserRatingStarFill: Int {
    case full = 0
    case partial
    case none
}

struct UserRatingStars {
    var starOne:UserRatingStarFill
    var starTwo:UserRatingStarFill
    var starThree:UserRatingStarFill
    var starFour:UserRatingStarFill
    var starFive:UserRatingStarFill
}

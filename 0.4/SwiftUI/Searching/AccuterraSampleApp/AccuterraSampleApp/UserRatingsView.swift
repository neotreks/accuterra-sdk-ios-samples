//
//  UserRatingsView.swift
//  AccuterraSampleApp
//
//  Created by Brian Elliott on 5/2/20.
//  Copyright © 2020 NeoTreks, Inc. All rights reserved.
//

import SwiftUI
import AccuTerraSDK

import SwiftUI

struct UserRatingsView: View {
    
    var imageOne:Image = Image(systemName: "star")
    var imageTwo:Image = Image(systemName: "star")
    var imageThree:Image = Image(systemName: "star")
    var imageFour:Image = Image(systemName: "star")
    var imageFive:Image = Image(systemName: "star")
    var starColor:Color = .blue
    var vm = UserRatingsViewModel()
    
    init(rating: UserRating?) {
        if let userRating = rating {
            let userRatingStars = vm.getUserRatings(userRating: userRating)
            self.setStar(userRatingStars:userRatingStars, sequence:1)
            self.setStar(userRatingStars:userRatingStars, sequence:2)
            self.setStar(userRatingStars:userRatingStars, sequence:3)
            self.setStar(userRatingStars:userRatingStars, sequence:4)
            self.setStar(userRatingStars:userRatingStars, sequence:5)
        }
    }
    
    var body: some View {
        HStack {
            Group {
                imageOne
                .imageScale(.medium)
                .foregroundColor(starColor)
                imageTwo
                .imageScale(.medium)
                .foregroundColor(starColor)
                imageThree
                .imageScale(.medium)
                .foregroundColor(starColor)
                imageFour
                .imageScale(.medium)
                .foregroundColor(starColor)
                imageFive
                .imageScale(.medium)
                .foregroundColor(starColor)
            }
        }
    }
    
    mutating func setStar(userRatingStars: UserRatingStars, sequence: Int) {
      
        if sequence == 5 {
            self.imageFive = getStarImage(fillType: userRatingStars.starFive)
        }
        else if sequence == 4 {
            self.imageFour = getStarImage(fillType: userRatingStars.starFour)
        }
        else if sequence == 3 {
            self.imageThree = getStarImage(fillType: userRatingStars.starThree)
        }
        else if sequence == 2 {
            self.imageTwo = getStarImage(fillType: userRatingStars.starTwo)
        }
        else if sequence == 1 {
            self.imageOne = getStarImage(fillType: userRatingStars.starOne)
        }
        else {
            self.imageOne = Image(systemName: "star")
        }
    }
    
    private func getStarImage(fillType: UserRatingStarFill) -> Image {
        if fillType == .full {
            return Image(systemName: "star.fill")
        }
        else if fillType == .partial {
            return Image(systemName: "star.lefthalf.fill")
        }
        else {
            return Image(systemName: "star")
        }
    }

}


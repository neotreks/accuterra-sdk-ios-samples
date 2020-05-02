//
//  UserRatingsViewModel.swift
//  AccuterraSampleApp
//
//  Created by Brian Elliott on 5/2/20.
//  Copyright © 2020 NeoTreks, Inc. All rights reserved.
//

import SwiftUI
import AccuTerraSDK

class UserRatingsViewModel {
    
    func getUserRatings(userRating: UserRating?) -> UserRatingStars {
        
        var userRatingStars = UserRatingStars(starOne: .none, starTwo: .none, starThree: .none, starFour: .none, starFive: .none)
        
        if let rating = userRating?.rating {
            // round to float with one place
            let roundedRating = roundToPlaces(value: rating, places: 1)
            
            // start with left sidset each star and 1/2 fill those > .5
            var runningValue = roundedRating
            for seq in 1...5 {
                
                if runningValue >= 1 {
                    setStarFillLevel(starContainer: &userRatingStars, sequence: seq, fillType: .full)
                }
                else if runningValue < 1 {
                    let test = checkBounds(ratingRemainder: runningValue)
                    // show a 1/2 star if rating is 0.1 or greater
                    if test >= 0.1 {
                        setStarFillLevel(starContainer: &userRatingStars, sequence: seq, fillType: .partial)
                    }
                    else {
                        setStarFillLevel(starContainer: &userRatingStars, sequence: seq, fillType: .none)
                    }
                }
                runningValue -= 1
            }
        }
        
        return userRatingStars
    }

    private func setStarFillLevel(starContainer: inout UserRatingStars, sequence: Int, fillType: UserRatingStarFill) {
      
        if sequence == 5 {
            starContainer.starFive = fillType
        }
        else if sequence == 4 {
            starContainer.starFour = fillType
        }
        else if sequence == 3 {
            starContainer.starThree = fillType
        }
        else if sequence == 2 {
            starContainer.starTwo = fillType
        }
        else if sequence == 1 {
            starContainer.starOne = fillType
        }
    }

    private func roundToPlaces(value: Double, places: Int) -> Double {
      let divisor = pow(10.0, Double(places))
      return round(value * divisor) / divisor
    }

    //
    // derived from: https://iosexample.com/a-star-rating-control-for-ios-swift/
    //
    private func checkBounds(ratingRemainder: Double) -> Double {
      
      var result = ratingRemainder
      
      if result > 1 { result = 1 }
      if result < 0 { result = 0 }
        
      return result
      
    }
}


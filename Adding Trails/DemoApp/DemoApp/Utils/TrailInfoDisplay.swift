//
//  TrailInfoDisplay.swift
//  DemoApp
//
//  Created by Brian Elliott on 2/8/20.
//  Copyright © 2020 NeoTreks. All rights reserved.
//

import UIKit
import AccuTerraSDK

enum StarFillMode: Int {
    case full = 0
    case partial
    case none
}

public class TrailInfoDisplay {
    
    private static let totalStars = 5
    
    init() {
    }
    
    //
    // derived from: https://iosexample.com/a-star-rating-control-for-ios-swift/
    //
    private static func checkBounds(ratingRemainder: Double) -> Double {
      
      var result = ratingRemainder
      
      if result > 1 { result = 1 }
      if result < 0 { result = 0 }
        
      return result
      
    }
    
    private static func setStarFillLevel(imageContainer: inout UserRatingContainer, sequence: Int, fillType: StarFillMode) {
      
        if sequence == 5 {
            setStarImage(star: &imageContainer.starFive, fillType: fillType)
        }
        else if sequence == 4 {
          setStarImage(star: &imageContainer.starFour, fillType: fillType)
        }
        else if sequence == 3 {
          setStarImage(star: &imageContainer.starThree, fillType: fillType)
        }
        else if sequence == 2 {
          setStarImage(star: &imageContainer.starTwo, fillType: fillType)
        }
        else if sequence == 1 {
          setStarImage(star: &imageContainer.starOne, fillType: fillType)
        }
    }
    
    // Set all but description
    private static func setDisplayFieldValuesPartial(trailTitleLabel: inout UILabel, distanceLabel: inout UILabel, userRatingsContainer: inout UserRatingContainer, basicTrailInfo: TrailBasicInfo?) {
        
        if let name = basicTrailInfo?.name {
            trailTitleLabel.text = name
        }
        else {
            trailTitleLabel.text = "--"
        }
        
        if let trailDistance = basicTrailInfo?.length {
            distanceLabel.text = GeoUtils.distanceKilometersToMiles(kilometers: trailDistance)
        }
        else {
            distanceLabel.text = "-- mi"
        }
        
        setUserRatings(basicTrailInfo: basicTrailInfo, userRatingsContainer: &userRatingsContainer)
    }
    
    // function is public to allow for XCTest calls
    public static func setUserRatings(basicTrailInfo: TrailBasicInfo?,  userRatingsContainer: inout UserRatingContainer) {
        if let userRating = basicTrailInfo?.userRating?.rating {
            // round to float with one place
            let roundedRating = roundToPlaces(value: userRating, places: 1)
            
            // start with left sidset each star and 1/2 fill those > .5
            var runningValue = roundedRating
            for seq in 1...5 {
                
                if runningValue >= 1 {
                    setStarFillLevel(imageContainer: &userRatingsContainer, sequence: seq, fillType: .full)
                }
                else if runningValue < 1 {
                    let test = checkBounds(ratingRemainder: runningValue)
                    // show a 1/2 star if rating is 0.1 or greater
                    if test >= 0.1 {
                        setStarFillLevel(imageContainer: &userRatingsContainer, sequence: seq, fillType: .partial)
                    }
                    else {
                        setStarFillLevel(imageContainer: &userRatingsContainer, sequence: seq, fillType: .none)
                    }
                }
                runningValue -= 1
            }
        }
        else {
            setStarImage(star: &userRatingsContainer.starOne, fillType: .none)
            setStarImage(star: &userRatingsContainer.starTwo, fillType: .none)
            setStarImage(star: &userRatingsContainer.starThree, fillType: .none)
            setStarImage(star: &userRatingsContainer.starFour, fillType: .none)
            setStarImage(star: &userRatingsContainer.starFive, fillType: .none)
        }
    }
    
    private static func setStarImage(star: inout UIImageView, fillType: StarFillMode) {
        if fillType == .full {
            star.image = UIImage.fullStarImage
        }
        else if fillType == .partial {
            star.image = UIImage.partialStarImage
        }
        else if fillType == .none {
            star.image = UIImage.emptyStarImage
        }
    }
    
    // Description with a UILabel (Trail List)
    public static func setDisplayFieldValues(trailTitleLabel: inout UILabel, descriptionLabel: inout UILabel, distanceLabel: inout UILabel, userRatings: inout UserRatingContainer, difficultyColorBar: inout UILabel, basicTrailInfo: TrailBasicInfo?) {
        
        setDisplayFieldValuesPartial(trailTitleLabel: &trailTitleLabel, distanceLabel: &distanceLabel, userRatingsContainer: &userRatings, basicTrailInfo: basicTrailInfo)
        
        if let description = basicTrailInfo?.highlights {
            descriptionLabel.text = description
        }
        else {
            descriptionLabel.text = "N/A"
        }
        
        if let difficulty = basicTrailInfo?.techRatingHigh {
            let techRatingColor = TechRatingColorMapper.getTechRatingColor(techRatingCode: difficulty.code)
            difficultyColorBar.backgroundColor = techRatingColor
        }
        else {
           difficultyColorBar.backgroundColor = UIColor.white
        }
    }
        
    // Description with a UITextView (Trail Info)
    public static func setDisplayFieldValues(trailTitleLabel: inout UILabel, descriptionTextView: inout UITextView, distanceLabel: inout UILabel, userRatings: inout UserRatingContainer, userRatingCountLabel: inout UILabel, userRatingValueLabel: inout UILabel, difficultyLabel: inout UILabel, basicTrailInfo: TrailBasicInfo?) {
        
        setDisplayFieldValuesPartial(trailTitleLabel: &trailTitleLabel, distanceLabel: &distanceLabel, userRatingsContainer: &userRatings, basicTrailInfo: basicTrailInfo)
        
        if let description = basicTrailInfo?.highlights {
            descriptionTextView.text = description
        }
        else {
            descriptionTextView.text = "N/A"
        }
        
        if let userRatingCount = basicTrailInfo?.userRating?.ratingCount {
            userRatingCountLabel.text = String(format: "(%d)", userRatingCount)
        }
        else {
            userRatingCountLabel.text = "*"
        }
        
        if let userRating = basicTrailInfo?.userRating?.rating {
            userRatingValueLabel.text = String(format: "%.1f", Double(round(userRating * 10) / 10))
        }
        else {
            userRatingValueLabel.text = "*"
        }
        
        if let difficulty = basicTrailInfo?.techRatingHigh {
            difficultyLabel.text = difficulty.name
        }
        else {
           difficultyLabel.text = "UNKNOWN"
        }
    }
    
    public static func roundToPlaces(value: Double, places: Int) -> Double {
      let divisor = pow(10.0, Double(places))
      return round(value * divisor) / divisor
    }
    
    public static func centerButtonImageAndTitle(button: UIButton, tileOffset: Double, imageOffset: Double) {
      let spacing: CGFloat = 5
      let titleSize = button.titleLabel!.frame.size
      let imageSize = button.imageView!.frame.size

        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: -imageSize.width - CGFloat(tileOffset), bottom: -(imageSize.height + spacing), right: 0)
      button.imageEdgeInsets = UIEdgeInsets(top: -(titleSize.height + spacing), left: -imageSize.width/2 - CGFloat(imageOffset), bottom: 0, right: -titleSize.width)
    }
}

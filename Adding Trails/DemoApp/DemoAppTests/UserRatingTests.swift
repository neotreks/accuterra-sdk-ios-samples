//
//  DemoAppUserRatingTests.swift
//  DemoAppTests
//
//  Created by Brian Elliott on 2/11/20.
//  Copyright © 2020 NeoTreks. All rights reserved.
//

import XCTest
import AccuTerraSDK

class UserRatingTests: XCTestCase {

    var starOneImageView: UIImageView? = nil
    var starTwoImageView:UIImageView? = nil
    var starThreeImageView:UIImageView? = nil
    var starFourImageView:UIImageView? = nil
    var starFiveImageView:UIImageView? = nil
    var userRatingsImageViews: UserRatingContainer?
    
    override func setUp() {
        
        starOneImageView = UIImageView()
        starTwoImageView = UIImageView()
        starThreeImageView = UIImageView()
        starFourImageView = UIImageView()
        starFiveImageView = UIImageView()
        userRatingsImageViews = UserRatingContainer(one: starOneImageView!, two: starTwoImageView!, three: starThreeImageView!, four: starFourImageView!, five: starFiveImageView!)
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testUserRatingsDisplay() {
        let userRating = UserRating(rating: 2.9, ratingCount: 380)
        let lowRating = TechnicalRating(code: "", name: "", description:  nil, level: 1)
        let highRating = TechnicalRating(code: "", name: "", description:  nil, level: 2)
        
        let info = TrailBasicInfo(id:1, techRatingLow:lowRating, techRatingHigh:highRating, publishedFrom:Date.now(), name:"Test Trail", highlights: "Description of the trail", length: 1.0, userRating: userRating, distance: 1.0)

         if let basicInfo = info {
            TrailInfoDisplay.setUserRatings(basicTrailInfo: info,  userRatingsContainer: &userRatingsImageViews!)
            let results = formatResults(userRatingsContainer: userRatingsImageViews!)
            XCTAssert(results != "X-X-1/2-O-O", "User Rating of 2.9 (X-X-1/2-O-O) user rating display was not as expected - got \(results)!")
         }
         else {
            XCTFail("Trail service is nil")
         }
    }
    
    func formatResults(userRatingsContainer: UserRatingContainer) -> String {
        var first = "*"
        var second = "*"
        var third = "*"
        var forth = "*"
        var fifth = "*"
        
        if userRatingsContainer.starOne.image == UIImage.fullStarImage {
            first = "X"
        }
        else if userRatingsContainer.starOne.image == UIImage.partialStarImage {
            first = "1/2"
        }
        else if userRatingsContainer.starOne.image == UIImage.emptyStarImage {
            first = "O"
        }
        
        if userRatingsContainer.starTwo.image == UIImage.fullStarImage {
            second = "X"
        }
        else if userRatingsContainer.starTwo.image == UIImage.partialStarImage {
            second = "1/2"
        }
        else if userRatingsContainer.starTwo.image == UIImage.emptyStarImage {
            second = "O"
        }
        
        if userRatingsContainer.starThree.image == UIImage.fullStarImage {
            third = "X"
        }
        else if userRatingsContainer.starThree.image == UIImage.partialStarImage {
            third = "1/2"
        }
        else if userRatingsContainer.starThree.image == UIImage.emptyStarImage {
            third = "O"
        }
        
        if userRatingsContainer.starFour.image == UIImage.fullStarImage {
            forth = "X"
        }
        else if userRatingsContainer.starFour.image == UIImage.partialStarImage {
            forth = "1/2"
        }
        else if userRatingsContainer.starFour.image == UIImage.emptyStarImage {
            forth = "O"
        }
        
        if userRatingsContainer.starFive.image == UIImage.fullStarImage {
            fifth = "X"
        }
        else if userRatingsContainer.starFive.image == UIImage.partialStarImage {
            fifth = "1/2"
        }
        else if userRatingsContainer.starFive.image == UIImage.emptyStarImage {
            fifth = "O"
        }
        return "\(first)-\(second)-\(third)-\(forth)-\(fifth)"
    }

}

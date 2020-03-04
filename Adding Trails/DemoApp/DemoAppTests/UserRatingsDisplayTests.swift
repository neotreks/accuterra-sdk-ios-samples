//
//  UserRatingsDisplayTests.swift
//  DemoAppTests
//
//  Created by Brian Elliott on 2/12/20.
//  Copyright © 2020 NeoTreks. All rights reserved.
//

import XCTest
import AccuTerraSDK
@testable import DemoApp

class UserRatingsDisplayTests: XCTestCase {
    
    static var trailService: ITrailService?
    static var userRatingsImageViews:UserRatingContainer?

    override func setUp() {
        let starOneImageView:UIImageView? = UIImageView()
        let starTwoImageView:UIImageView? = UIImageView()
        let starThreeImageView:UIImageView? = UIImageView()
        let starFourImageView:UIImageView? = UIImageView()
        let starFiveImageView:UIImageView? = UIImageView()
        UserRatingsDisplayTests.userRatingsImageViews = UserRatingContainer(one: starOneImageView!, two: starTwoImageView!, three: starThreeImageView!, four: starFourImageView!, five: starFiveImageView!)
        
        UserRatingsDisplayTests.trailService = ServiceFactory.getTrailService()
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testUserRatingsDisplay() throws {
        
        let trailId: Int64 = 371

         // Get basic trail info by its ID
        let trailsService = ServiceFactory.getTrailService()
        let basicInfo:TrailBasicInfo? = try trailsService.getTrailBasicInfoById(trailId)
        if let info = basicInfo {
            TrailInfoDisplay.setUserRatings(basicTrailInfo: info,  userRatingsContainer: &UserRatingsDisplayTests.userRatingsImageViews!)
            let results = formatResults(userRatingsContainer: UserRatingsDisplayTests.userRatingsImageViews!)
            XCTAssertEqual(results, "1/2-O-O-O-O", "\(info.name) - User Rating of was not as expected!")
        }
        else {
            XCTAssert(basicInfo != nil, "Basic Trail Info of ID \(trailId) was not found!")
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

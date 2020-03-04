//
//  TrailListTableviewCell.swift
//  DemoApp
//
//  Created by Brian Elliott on 2/8/20.
//  Copyright © 2020 NeoTreks. All rights reserved.
//

import UIKit
import AccuTerraSDK

class TrailListTableviewCell: UITableViewCell {
    @IBOutlet weak var trailTitle: UILabel!
    @IBOutlet weak var ratingStarOne: UIImageView!
    @IBOutlet weak var ratingStarTwo: UIImageView!
    @IBOutlet weak var ratingStarThree: UIImageView!
    @IBOutlet weak var ratingStarFour: UIImageView!
    @IBOutlet weak var ratingStarFive: UIImageView!
    @IBOutlet weak var trailDistanceLabel: UILabel!
    @IBOutlet weak var trailDescription: UILabel!
    @IBOutlet weak var bookmarkButton: UIButton!
    @IBOutlet weak var goToMapButton: UIButton!
    @IBOutlet weak var goToDetailsButton: UIButton!
    @IBOutlet weak var difficultyColorBarLabel: UILabel!
    
    weak var delegate: TrailListViewDelegate?
    var trail: TrailBasicInfo?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        bookmarkButton.layer.cornerRadius = 15.0
        bookmarkButton.layer.borderColor = UIColor.black.cgColor
        bookmarkButton.layer.borderWidth = 1.0
        
        goToMapButton.layer.cornerRadius = 15.0
        goToMapButton.layer.borderColor = UIColor.Active?.cgColor
        goToMapButton.layer.borderWidth = 1.0
        goToMapButton.tintColor = UIColor.Active
        
        goToDetailsButton.layer.cornerRadius = 15.0
        goToDetailsButton.layer.borderColor = UIColor.Active?.cgColor
        goToDetailsButton.layer.borderWidth = 1.0
        goToDetailsButton.tintColor = UIColor.Active
        
        bookmarkButton.imageView?.image = UIImage.bookmarkImage
        goToMapButton.imageView?.image = UIImage.mappinAndEllipseImage
        goToDetailsButton.imageView?.image = UIImage.chevronRightImage
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func bookmarkPicked(_ sender: Any) {
        print("bookmarkPicked")
    }
    
    @IBAction func goToDetailsPicked(_ sender: Any) {
        if let trail = self.trail  {
            self.delegate?.didTapTrailInfo(basicInfo: trail)
        }
    }
    
    @IBAction func goToMapPicked(_ sender: Any) {
        if let trail = self.trail  {
            self.delegate?.didTapTrailMap(basicInfo: trail)
        }
    }
    
}

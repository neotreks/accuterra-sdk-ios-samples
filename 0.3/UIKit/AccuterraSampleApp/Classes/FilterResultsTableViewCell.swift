//
//  FilterResultsTableViewCell.swift
//  AccuterraSampleApp
//
//  Created by Brian Elliott on 3/29/20.
//  Copyright © 2020 BaseMap. All rights reserved.
//

import UIKit

class FilterResultsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var trailNameLabel: UILabel!
    @IBOutlet weak var techDifficultyValue: UILabel!
    @IBOutlet weak var userRatingValue: UILabel!
    @IBOutlet weak var trailLengthValue: UILabel!
    @IBOutlet weak var distanceAwayValue: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

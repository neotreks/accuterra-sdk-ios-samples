//
//  FilterCriteriaTableViewCell.swift
//  AccuterraSampleApp
//
//  Created by Brian Elliott on 3/27/20.
//  Copyright © 2020 BaseMap. All rights reserved.
//

import UIKit

class FilterCriteriaTableViewCell: UITableViewCell {

    @IBOutlet weak var techRatingNameValue: UILabel!
    @IBOutlet weak var techRatingCodeValue: UILabel!
    @IBOutlet weak var techRatingDescriptionValue: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

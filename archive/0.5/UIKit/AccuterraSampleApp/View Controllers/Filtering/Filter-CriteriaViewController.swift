//
//  Filter-CriteriaViewController.swift
//  AccuterraSampleApp
//
//  Created by Brian Elliott on 3/27/20.
//  Copyright © 2020 NeoTreks, Inc. All rights reserved.
//

import UIKit
import AccuTerraSDK

class Filter_CriteriaViewController: UIViewController {

    var cellIdentifier="TechRatingTableviewCell"
    
    var techRatings = [TechnicalRating]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let ratings = getTechRatings() {
            techRatings = ratings
        }
    }
    
    func getTechRatings() -> [TechnicalRating]? {
        if let ratings = initTechRatings() {
            return Array(ratings.values.sorted(by: { (r1, r2) -> Bool in
                return r1.level < r2.level
            }))
        }
        return nil
    }
        
    private func initTechRatings() -> [String: TechnicalRating]?{
        var techRatings = [String: TechnicalRating]()
        if techRatings.count == 0 {
            if techRatings.count == 0 {
                do {
                    let ratings = try ServiceFactory.getEnumService().getTechRatings()
                    ratings.forEach { (rating) in
                        techRatings[rating.code] = rating
                    }
                    return techRatings
                }
                catch {
                    debugPrint("\(error)")
                }
            }
        }
        return techRatings
    }
}

extension Filter_CriteriaViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.techRatings.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell :FilterCriteriaTableViewCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! FilterCriteriaTableViewCell
        cell.techRatingNameValue.text = self.techRatings[indexPath.row].name
        cell.techRatingCodeValue.text = self.techRatings[indexPath.row].code
        cell.techRatingDescriptionValue.text = self.techRatings[indexPath.row].description
        return cell
    }
}

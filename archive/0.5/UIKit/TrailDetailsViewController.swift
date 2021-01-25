//
//  TrailDetailsViewController.swift
//  Displaying-Trail-Details
//
//  Created by Brian Elliott on 3/10/20.
//  Copyright © 2020 NeoTreks, Inc. All rights reserved.
//

import UIKit
import AccuTerraSDK

class TrailDetailsViewController: UIViewController {

    var trailId: Int64?
    var trailDetails: TrailDetails?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let id = self.trailId {
            self.trailDetails = TrailDetails(trailId: id)
        }
    }
}

extension TrailDetailsViewController : UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        guard let trailDetails = self.trailDetails else {
            return 0
        }
        return 15 + trailDetails.waypoints.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let trailDetails = self.trailDetails else {
            return 0
        }
        if let section = trailDetails.getSection(sectionId: section) {
            if section.values.count == 0 {
                return 1 // Show Empty Section note
            } else {
                return section.values.count
            }
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let trailDetails = self.trailDetails, let section = trailDetails.getSection(sectionId: section) {
            return section.name
        } else {
            return ""
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        
        if let trailDetails = self.trailDetails, let section = trailDetails.getSection(sectionId: indexPath.section) {
            if section.values.count == 0 {
                cell.textLabel?.text = "No information is available"
            } else {
                cell.textLabel?.text = section.values[indexPath.row].key
                var value = section.values[indexPath.row].value
                if value.count == 0 {
                    value = "N/A"
                }
                cell.detailTextLabel?.text = value
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if let trailDetails = self.trailDetails, let section = trailDetails.getSection(sectionId: indexPath.section) {
            if section.values.count > 0 {
                let key = section.values[indexPath.row].key
                let value = section.values[indexPath.row].value
                if value.count > 0 {
                    let alert = UIAlertController(title: key, message: value, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Close", style: .cancel, handler: nil))
                    self.present(alert, animated: false, completion: nil)
                }
            }
        }
        return nil
    }
    
    
}


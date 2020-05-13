//
//  TrailListViewController.swift
//  AccuterraSampleApp
//
//  Created by Brian Elliott on 3/24/20.
//  Copyright © 2020 NeoTreks, Inc. All rights reserved.
//

import Foundation
import UIKit
import AccuTerraSDK

class TrailListViewController: BaseViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var trails: Array<TrailBasicInfo>?
    private let cellReuseIdentifier: String = "Cell"
    private let appTitle = "AccuTerra Search"
    var trailsService: ITrailService?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
    }
}

extension TrailListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
                let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath) as UITableViewCell
        let text = self.trails?[indexPath.row].name
        cell.textLabel!.text = text
        cell.selectionStyle = .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.trails?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
}

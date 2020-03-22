//
//  HomeViewController.swift
//  AccuterraSampleApp
//
//  Created by Brian Elliott on 3/20/20.
//  Copyright © 2020 BaseMap. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {

    @IBOutlet var tableView: UITableView!
    
    private let cellReuseIdentifier: String = "Cell"
    
    var itemsInSections: Array<Array<String>> = [["List to Map", "Map to List", "Search Term to Map", "Search Term to List"], ["Filter to Map Display", "Filter to List Display"]]
    var sections: Array<String> = ["Searching", "Filtering"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "AccuTerra Searching"

        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let viewController = segue.destination as? BaseViewController {
            viewController.homeNavItem = navigationItem
        }
    }
}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
        
    func numberOfSections(in tableView: UITableView) -> Int {
        print("numberOfSectionsInTableView: \(self.sections.count)")
        return self.sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("numberOfRowsInSection: \(self.itemsInSections[section].count)")
        return self.itemsInSections[section].count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.sections[section]
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath) as UITableViewCell
        let text = self.itemsInSections[indexPath.section][indexPath.row]
        
        cell.textLabel!.text = text
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.performSegue(withIdentifier: self.itemsInSections[indexPath.section][indexPath.row], sender: nil)
    }
}

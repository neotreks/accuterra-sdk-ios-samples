//
//  Term-to-ListViewController.swift
//  AccuterraSampleApp
//
//  Created by Brian Elliott on 3/20/20.
//  Copyright © 2020 BaseMap. All rights reserved.
//

import UIKit
import AccuTerraSDK

class Term_to_ListViewController: BaseViewController {

    @IBOutlet var tableView: UITableView!
    
    private let cellReuseIdentifier: String = "Cell"
    private let appTitle = "AccuTerra Search"
    
    var trails: Array<TrailBasicInfo>?
        //= ["Trail 1", "Trail 2", "Trail 3", "Trail 4"]
    
    var searchController: UISearchController?
    var trailsFilter = TrailsFilter()
    
    var trailsService: ITrailService?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.dataSource = self
        self.tableView.delegate = self
        
                definesPresentationContext = true
        
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        
        self.searchTrails(searchText: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUpSearchBar()
    }
    
    func willPresentSearchController(_ searchController: UISearchController) {
        self.navigationController?.navigationBar.isTranslucent = true
    }

    func willDismissSearchController(_ searchController: UISearchController) {
        self.navigationController?.navigationBar.isTranslucent = false
    }
    
    var isSearchBarEmpty: Bool {
        return self.searchController?.searchBar.text?.isEmpty ?? true
    }
    
    func setUpSearchBar() {
        let searchButton = UIButton(type: .system)
        searchButton.tintColor = UIColor.Active
        searchButton.setImage(UIImage.searchImage, for: .normal)
        searchButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        searchButton.addTarget(self, action:#selector(self.searchTapped), for: .touchUpInside)
        
        self.navigationItem.setRightBarButtonItems([
            UIBarButtonItem(customView: searchButton)
        ], animated: false)
        
        self.navigationItem.setLeftBarButtonItems([
            UIBarButtonItem(title: "< Back", style: .plain, target: self, action: #selector(backTapped))
        ], animated: false)
        
        self.navigationItem.title = appTitle
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: nil, action: nil)
    }
    
    @objc func searchTapped() {
        self.searchController = UISearchController(searchResultsController:  nil)
        self.searchController?.hidesNavigationBarDuringPresentation = false
        self.searchController?.obscuresBackgroundDuringPresentation = false
        self.searchController?.searchBar.placeholder = "Trail Name"
        self.searchController?.searchBar.text = self.trailsFilter.trailNameFilter
        definesPresentationContext = true
        self.searchController?.searchBar.delegate = self
        self.navigationItem.titleView = searchController?.searchBar
        
        self.searchController?.searchBar.showsCancelButton = true
        self.searchController?.searchBar.becomeFirstResponder()
        self.navigationItem.setRightBarButtonItems(nil, animated: false)
        self.searchTrails(searchText: nil)
    }
    
    func searchTrails(searchText:String?) {
        
        guard SdkManager.shared.isTrailDbInitialized else {
            return
        }
        
        do {
            if self.trailsService == nil {
                trailsService = ServiceFactory.getTrailService()
            }
            
            if let trailManager = self.trailsService {
                let criteria = try TrailBasicSearchCriteria(searchString: searchText, limit: 20)
                let trails = try trailManager.findTrails(byBasicCriteria: criteria)
                if trails.count > 0 {
                    self.trails = trails
                    self.navigationItem.title = searchText
                    self.tableView.reloadData()
                }
            }
        }
        catch {
            debugPrint("\(error)")
        }
    }
    
    @objc func backTapped() {
        self.navigationController?.popViewController(animated: true)
    }
}

extension Term_to_ListViewController: UISearchBarDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        setUpSearchBar()
        self.searchController?.dismiss(animated: false, completion: nil)
        self.navigationItem.titleView = nil
        self.searchController = nil
        // Display all trails
        self.searchTrails(searchText: nil)
        self.navigationItem.title = appTitle
        self.tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        setUpSearchBar()
        self.searchController?.dismiss(animated: true, completion: nil)
        self.navigationItem.titleView = nil
        self.searchController = nil

        if let searchText = searchBar.text {
            self.searchTrails(searchText: searchText)
        }
    }
}

extension Term_to_ListViewController: UITableViewDelegate, UITableViewDataSource {
    
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

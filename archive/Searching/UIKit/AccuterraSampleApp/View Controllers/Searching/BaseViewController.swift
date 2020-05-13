//
//  BaseViewController.swift
//  DemoApp
//
//  Created by Brian Elliott on 2/25/20.
//  Copyright © 2020 NeoTreks. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {

    weak var homeNavItem: UINavigationItem?
    private let appTitle = "AccuTerra Search"
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNavBar()
    }
    
    func setNavBar() {
        self.navigationItem.setLeftBarButtonItems([
            UIBarButtonItem(title: "< Back", style: .plain, target: self, action: #selector(backTapped))
        ], animated: false)
        
        self.navigationItem.title = appTitle
        self.navigationItem.titleView = nil
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: nil, action: nil)
    }
    
    @objc func backTapped() {
        self.navigationController?.popViewController(animated: true)
    }
}

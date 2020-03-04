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

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNavBar()
    }
    
    func setNavBar() {
        self.homeNavItem?.leftBarButtonItem = nil
        self.homeNavItem?.setRightBarButtonItems(nil, animated: false)
        self.homeNavItem?.titleView = nil
    }
    
    var taskBar: TaskBar? {
        get {
            return ((self.parent as? HomePageViewController)?.homeDelegate as? HomeViewController)?.taskBar
        }
    }
}

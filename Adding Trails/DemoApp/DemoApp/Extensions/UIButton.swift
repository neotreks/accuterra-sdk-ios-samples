//
//  UIButton.swift
//  DemoApp
//
//  Created by Brian Elliott on 2/8/20.
//  Copyright © 2020 NeoTreks. All rights reserved.
//

import UIKit

extension UIButton {
    override open var isHighlighted: Bool {
        didSet {
            backgroundColor = isHighlighted ? UIColor.lightGray : UIColor.white
        }
    }
}

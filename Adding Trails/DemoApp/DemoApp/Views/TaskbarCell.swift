//
//  TaskbarCollectionViewCell.swift
//  DemoApp
//
//  Created by Brian Elliott on 2/19/20.
//  Copyright © 2020 NeoTreks. All rights reserved.
//

import UIKit

class TaskbarCell: UICollectionViewCell {
    
    static let selectedBarHeight = 7.0
    
    var title: UILabel?
    var selectedBar: UILabel?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        title = UILabel(frame: CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height))
        title?.font = UIFont.systemFont(ofSize: 12.0)
        title?.textAlignment = .center
        title?.textColor = UIColor.TaskbarTextColor
        title?.translatesAutoresizingMaskIntoConstraints = false
        if let titleLabel = title {
            contentView.addSubview(titleLabel)
            let constraintStringWidth = "H:[v0(\(bounds.width))]"
            let constraintStringHeight = "V:[v0(\(bounds.height))]"
            addConstraintsWithFormat(constraintStringWidth, views: titleLabel)
            addConstraintsWithFormat(constraintStringHeight, views: titleLabel)
            addConstraint(NSLayoutConstraint(item: titleLabel, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0))
            addConstraint(NSLayoutConstraint(item: titleLabel, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
        }
        
        selectedBar = UILabel(frame: CGRect(x: 0, y: 0, width: bounds.width, height: CGFloat(TaskbarCell.selectedBarHeight)))
        selectedBar?.backgroundColor = UIColor.TaskbarBackgroundColor
        if let bar = selectedBar {
            contentView.addSubview(bar)
            let constraintStringWidth = "H:[v0(\(bounds.width))]"
            let constraintStringHeight = "V:[v0(\(TaskbarCell.selectedBarHeight))]"
            addConstraintsWithFormat(constraintStringWidth, views: bar)
            addConstraintsWithFormat(constraintStringHeight, views: bar)
            addConstraint(NSLayoutConstraint (item: bar,
                                              attribute: NSLayoutConstraint.Attribute.bottom,
                                              relatedBy: NSLayoutConstraint.Relation.equal,
                                              toItem: contentView,
                                              attribute: NSLayoutConstraint.Attribute.bottom,
                                              multiplier: 1,
                                              constant: 0))
            addConstraint(NSLayoutConstraint (item: bar,
                                              attribute: NSLayoutConstraint.Attribute.leading,
                                              relatedBy: NSLayoutConstraint.Relation.equal,
                                              toItem: contentView,
                                              attribute: NSLayoutConstraint.Attribute.leading,
                                              multiplier: 1,
                                              constant: 0))
            addConstraint(NSLayoutConstraint (item: bar,
                                              attribute: NSLayoutConstraint.Attribute.trailing,
                                              relatedBy: NSLayoutConstraint.Relation.equal,
                                              toItem: contentView,
                                              attribute: NSLayoutConstraint.Attribute.trailing,
                                              multiplier: 1,
                                              constant: 0))
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var isHighlighted: Bool {
        didSet {
            title?.textColor = isHighlighted ? UIColor.TaskbarActiveTextColor: UIColor.TaskbarTextColor
            selectedBar?.backgroundColor = isHighlighted ? UIColor.TaskbarActiveBarColor: UIColor.TaskbarBackgroundColor
        }
    }
    
    override var isSelected: Bool {
        didSet {
            title?.textColor = isSelected ? UIColor.TaskbarActiveTextColor : UIColor.TaskbarTextColor
            selectedBar?.backgroundColor = isSelected ? UIColor.TaskbarActiveBarColor: UIColor.TaskbarBackgroundColor
        }
    }
    
}

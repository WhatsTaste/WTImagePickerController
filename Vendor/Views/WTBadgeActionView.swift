//
//  WTBadgeActionView.swift
//  WTImagePickerController
//
//  Created by Jayce on 2017/2/17.
//  Copyright © 2017年 WhatsTaste. All rights reserved.
//

import UIKit

class WTBadgeActionView: UIControl {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // Initialization code
        self.addSubview(contentView)
        contentView.addSubview(badgeView)
        contentView.addSubview(contentButton)

        self.addConstraint(NSLayoutConstraint.init(item: contentView, attribute: .top, relatedBy: .greaterThanOrEqual, toItem: self, attribute: .top, multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint.init(item: self, attribute: .bottom, relatedBy: .greaterThanOrEqual, toItem: contentView, attribute: .bottom, multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint.init(item: contentView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
        
        contentView.addConstraint(NSLayoutConstraint.init(item: badgeView, attribute: .left, relatedBy: .equal, toItem: contentView, attribute: .left, multiplier: 1, constant: 0))
        contentView.addConstraint(NSLayoutConstraint.init(item: badgeView, attribute: .top, relatedBy: .greaterThanOrEqual, toItem: contentView, attribute: .top, multiplier: 1, constant: 0))
        contentView.addConstraint(NSLayoutConstraint.init(item: contentView, attribute: .bottom, relatedBy: .greaterThanOrEqual, toItem: badgeView, attribute: .bottom, multiplier: 1, constant: 0))
        contentView.addConstraint(NSLayoutConstraint.init(item: badgeView, attribute: .centerY, relatedBy: .equal, toItem: contentView, attribute: .centerY, multiplier: 1, constant: 0))
//        badgeView.addConstraint(NSLayoutConstraint.init(item: badgeView, attribute: .width, relatedBy: .equal, toItem: badgeView, attribute: .height, multiplier: 1, constant: 0))
//        badgeView.addConstraint(NSLayoutConstraint.init(item: badgeView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 20))
//        badgeView.addConstraint(NSLayoutConstraint.init(item: badgeView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 20))
        
        contentView.addConstraint(NSLayoutConstraint.init(item: contentButton, attribute: .left, relatedBy: .equal, toItem: badgeView, attribute: .right, multiplier: 1, constant: 4))
        contentView.addConstraint(NSLayoutConstraint.init(item: contentView, attribute: .right, relatedBy: .equal, toItem: contentButton, attribute: .right, multiplier: 1, constant: 0))
        contentView.addConstraint(NSLayoutConstraint.init(item: contentButton, attribute: .top, relatedBy: .equal, toItem: badgeView, attribute: .top, multiplier: 1, constant: 0))
        contentView.addConstraint(NSLayoutConstraint.init(item: badgeView, attribute: .bottom, relatedBy: .equal, toItem: contentButton, attribute: .bottom, multiplier: 1, constant: 0))
        
        badgeView.setContentHuggingPriority(contentButton.contentHuggingPriority(for: .horizontal) + 1, for: .horizontal)
        badgeView.setContentCompressionResistancePriority(contentButton.contentCompressionResistancePriority(for: .horizontal), for: .horizontal)
        
        defer {
            contentHorizontalAlignment = .center
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Properties
    
    override var contentHorizontalAlignment: UIControlContentHorizontalAlignment {
        didSet {
            switch contentHorizontalAlignment {
            case .center:
                self.removeConstraints(dynamicConstraints)
                dynamicConstraints.removeAll()
                let left = NSLayoutConstraint.init(item: contentView, attribute: .left, relatedBy: .greaterThanOrEqual, toItem: self, attribute: .left, multiplier: 1, constant: 0)
                let right = NSLayoutConstraint.init(item: self, attribute: .right, relatedBy: .greaterThanOrEqual, toItem: contentView, attribute: .right, multiplier: 1, constant: 0)
                let centerX = NSLayoutConstraint.init(item: contentView, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0)
                dynamicConstraints.append(left)
                dynamicConstraints.append(right)
                dynamicConstraints.append(centerX)
                self.addConstraints(dynamicConstraints)
            case .left:
                self.removeConstraints(dynamicConstraints)
                dynamicConstraints.removeAll()
                let left = NSLayoutConstraint.init(item: contentView, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1, constant: 0)
                let right = NSLayoutConstraint.init(item: self, attribute: .right, relatedBy: .greaterThanOrEqual, toItem: contentView, attribute: .right, multiplier: 1, constant: 0)
                dynamicConstraints.append(left)
                dynamicConstraints.append(right)
                self.addConstraints(dynamicConstraints)
            case .right:
                self.removeConstraints(dynamicConstraints)
                dynamicConstraints.removeAll()
                let left = NSLayoutConstraint.init(item: contentView, attribute: .left, relatedBy: .greaterThanOrEqual, toItem: self, attribute: .left, multiplier: 1, constant: 0)
                let right = NSLayoutConstraint.init(item: self, attribute: .right, relatedBy: .equal, toItem: contentView, attribute: .right, multiplier: 1, constant: 0)
                dynamicConstraints.append(left)
                dynamicConstraints.append(right)
                self.addConstraints(dynamicConstraints)
            case .fill:
                self.removeConstraints(dynamicConstraints)
                dynamicConstraints.removeAll()
                let left = NSLayoutConstraint.init(item: contentView, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1, constant: 0)
                let right = NSLayoutConstraint.init(item: self, attribute: .right, relatedBy: .equal, toItem: contentView, attribute: .right, multiplier: 1, constant: 0)
                dynamicConstraints.append(left)
                dynamicConstraints.append(right)
                self.addConstraints(dynamicConstraints)
//            default:
//                break
            }
        }
    }
    
    override var isEnabled: Bool {
        didSet {
            contentButton.isEnabled = isEnabled
            setNeedsDisplay()
        }
    }
    
    override var tintColor: UIColor! {
        didSet {
            badgeView.tintColor = tintColor
            
            contentButton.setTitleColor(tintColor, for: .normal)
            contentButton.setTitleColor(tintColor.withAlphaComponent(WTImagePickerControllerDisableAlphaComponent), for: .disabled)
        }
    }
        
    public var badge: Int = 0 {
        didSet {
            badgeView.badge = String(badge)
        }
    }
    
    lazy public private(set) var badgeView: WTBadgeView = {
        let view = WTBadgeView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.clear
//        view.tintColor = self.tintColor
        view.isUserInteractionEnabled = false
        return view
    }()
    
    lazy public private(set) var contentButton: UIButton = {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor.clear
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button.setTitleColor(self.tintColor, for: .normal)
        button.setTitleColor(self.tintColor.withAlphaComponent(WTImagePickerControllerDisableAlphaComponent), for: .disabled)
        return button
    }()
    
    lazy private var contentView: UIView = {
        let view = UIView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.clear
        view.isUserInteractionEnabled = false
        return view
    }()
    
    lazy private var dynamicConstraints: [NSLayoutConstraint] = {
        return [NSLayoutConstraint]()
    }()
}

//
//  WTBadgeActionView.swift
//  WTImagePickerController
//
//  Created by Jayce on 2017/2/17.
//  Copyright © 2017年 WhatsTaste. All rights reserved.
//

import UIKit

private let spacing: CGFloat = 4

class WTBadgeActionView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // Initialization code
        addSubview(badgeView)
        addSubview(contentButton)
        
        addConstraint(NSLayoutConstraint.init(item: badgeView, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint.init(item: badgeView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint.init(item: self, attribute: .bottom, relatedBy: .equal, toItem: badgeView, attribute: .bottom, multiplier: 1, constant: 0))
        
        addConstraint(NSLayoutConstraint.init(item: contentButton, attribute: .left, relatedBy: .equal, toItem: badgeView, attribute: .right, multiplier: 1, constant: spacing))
        addConstraint(NSLayoutConstraint.init(item: self, attribute: .right, relatedBy: .equal, toItem: contentButton, attribute: .right, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint.init(item: contentButton, attribute: .top, relatedBy: .equal, toItem: badgeView, attribute: .top, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint.init(item: badgeView, attribute: .bottom, relatedBy: .equal, toItem: contentButton, attribute: .bottom, multiplier: 1, constant: 0))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var tintColor: UIColor! {
        didSet {
            badgeView.tintColor = tintColor
            
            contentButton.setTitleColor(tintColor, for: .normal)
            contentButton.setTitleColor(tintColor.withAlphaComponent(WTImagePickerControllerDisableAlphaComponent), for: .disabled)
        }
    }
    
    // MARK: Properties
    
    public var badge: Int = 0 {
        didSet {
            badgeView.badge = String(badge)
        }
    }
    
    lazy public private(set) var badgeView: WTBadgeView = {
        let view = WTBadgeView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.clear
        view.isUserInteractionEnabled = false
        return view
    }()
    
    lazy public private(set) var contentButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor.clear
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button.setTitleColor(self.tintColor, for: .normal)
        button.setTitleColor(self.tintColor.withAlphaComponent(WTImagePickerControllerDisableAlphaComponent), for: .disabled)
        return button
    }()
}

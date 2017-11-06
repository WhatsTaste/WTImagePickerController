//
//  WTCheckboxActionView.swift
//  WTImagePickerController
//
//  Created by Jayce on 2017/2/17.
//  Copyright © 2017年 WhatsTaste. All rights reserved.
//

import UIKit

class WTCheckboxActionView: UIControl {

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // Initialization code
        
        self.addSubview(contentView)
        contentView.addSubview(indicatorView)
        contentView.addSubview(contentLabel)
        
        self.addConstraint(NSLayoutConstraint.init(item: contentView, attribute: .left, relatedBy: .greaterThanOrEqual, toItem: self, attribute: .left, multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint.init(item: self, attribute: .right, relatedBy: .greaterThanOrEqual, toItem: contentView, attribute: .right, multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint.init(item: contentView, attribute: .top, relatedBy: .greaterThanOrEqual, toItem: self, attribute: .top, multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint.init(item: self, attribute: .bottom, relatedBy: .greaterThanOrEqual, toItem: contentView, attribute: .bottom, multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint.init(item: contentView, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint.init(item: contentView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
        
        contentView.addConstraint(NSLayoutConstraint.init(item: indicatorView, attribute: .left, relatedBy: .equal, toItem: contentView, attribute: .left, multiplier: 1, constant: 0))
        contentView.addConstraint(NSLayoutConstraint.init(item: indicatorView, attribute: .top, relatedBy: .equal, toItem: contentView, attribute: .top, multiplier: 1, constant: 0))
        contentView.addConstraint(NSLayoutConstraint.init(item: contentView, attribute: .bottom, relatedBy: .equal, toItem: indicatorView, attribute: .bottom, multiplier: 1, constant: 0))
        indicatorView.addConstraint(NSLayoutConstraint.init(item: indicatorView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 20))
        indicatorView.addConstraint(NSLayoutConstraint.init(item: indicatorView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 20))
        
        contentView.addConstraint(NSLayoutConstraint.init(item: contentLabel, attribute: .left, relatedBy: .equal, toItem: indicatorView, attribute: .right, multiplier: 1, constant: 4))
        contentView.addConstraint(NSLayoutConstraint.init(item: contentView, attribute: .right, relatedBy: .equal, toItem: contentLabel, attribute: .right, multiplier: 1, constant: 0))
        contentView.addConstraint(NSLayoutConstraint.init(item: contentLabel, attribute: .top, relatedBy: .equal, toItem: indicatorView, attribute: .top, multiplier: 1, constant: 0))
        contentView.addConstraint(NSLayoutConstraint.init(item: indicatorView, attribute: .bottom, relatedBy: .equal, toItem: contentLabel, attribute: .bottom, multiplier: 1, constant: 0))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var tintColor: UIColor! {
        didSet {
           indicatorView.tintColor = tintColor
        }
    }
    
    // MARK: - Private

    override var isSelected: Bool {
        didSet {
            indicatorView.isSelected = isSelected
        }
    }
    
    public var textColor: UIColor = UIColor.white {
        didSet {
            contentLabel.textColor = textColor
        }
    }
    
    lazy public private(set) var indicatorView: WTSelectionIndicatorView = {
        let view = WTSelectionIndicatorView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.clear
        view.tintColor = self.tintColor
        view.isUserInteractionEnabled = false
        view.style = .checkmark
        return view
    }()
    
    lazy public private(set) var contentLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = UIColor.clear
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = self.textColor
        return label
    }()
    
    lazy private var contentView: UIView = {
        let view = UIView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.clear
        view.isUserInteractionEnabled = false
        return view
    }()
}

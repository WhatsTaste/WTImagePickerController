//
//  WTPreviewControlsView.swift
//  WTImagePickerController
//
//  Created by Jayce on 2017/2/17.
//  Copyright © 2017年 WhatsTaste. All rights reserved.
//

import UIKit

protocol WTPreviewControlsViewDelegate: class {
    func previewControlsViewDidEdit(_ view: WTPreviewControlsView)
    func previewControlsViewDidSelectOriginal(_ view: WTPreviewControlsView)
    func previewControlsViewDidFinish(_ view: WTPreviewControlsView)
}

private let horizontalMargin: CGFloat = 15
private let verticalMargin: CGFloat = 0
private let spacing: CGFloat = 15

class WTPreviewControlsView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // Initialization code
        self.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        addSubview(visualEffectView)
        addSubview(editButton)
        addSubview(originalActionView)
        addSubview(doneBadgeActionView)
        
        addConstraint(NSLayoutConstraint.init(item: visualEffectView, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint.init(item: self, attribute: .right, relatedBy: .equal, toItem: visualEffectView, attribute: .right, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint.init(item: visualEffectView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint.init(item: self, attribute: .bottom, relatedBy: .equal, toItem: visualEffectView, attribute: .bottom, multiplier: 1, constant: 0))
        
        addConstraint(NSLayoutConstraint.init(item: editButton, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1, constant: horizontalMargin))
        addConstraint(NSLayoutConstraint.init(item: editButton, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: verticalMargin))
        addConstraint(NSLayoutConstraint.init(item: self, attribute: .bottom, relatedBy: .equal, toItem: editButton, attribute: .bottom, multiplier: 1, constant: verticalMargin))
        
        addConstraint(NSLayoutConstraint.init(item: originalActionView, attribute: .left, relatedBy: .greaterThanOrEqual, toItem: editButton, attribute: .right, multiplier: 1, constant: spacing))
        addConstraint(NSLayoutConstraint.init(item: originalActionView, attribute: .top, relatedBy: .equal, toItem: editButton, attribute: .top, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint.init(item: originalActionView, attribute: .bottom, relatedBy: .equal, toItem: editButton, attribute: .bottom, multiplier: 1, constant: 0))
        let centerX = NSLayoutConstraint.init(item: originalActionView, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0)
        centerX.priority = UILayoutPriority.defaultLow
        addConstraint(centerX)
        
        addConstraint(NSLayoutConstraint.init(item: doneBadgeActionView, attribute: .left, relatedBy: .greaterThanOrEqual, toItem: originalActionView, attribute: .right, multiplier: 1, constant: spacing))
        addConstraint(NSLayoutConstraint.init(item: doneBadgeActionView, attribute: .top, relatedBy: .equal, toItem: originalActionView, attribute: .top, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint.init(item: doneBadgeActionView, attribute: .bottom, relatedBy: .equal, toItem: originalActionView, attribute: .bottom, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint.init(item: self, attribute: .right, relatedBy: .equal, toItem: doneBadgeActionView, attribute: .right, multiplier: 1, constant: horizontalMargin))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var tintColor: UIColor! {
        didSet {
            editButton.setTitleColor(tintColor, for: .normal)
            editButton.setTitleColor(editButton.titleColor(for: .normal)?.withAlphaComponent(WTImagePickerControllerDisableAlphaComponent), for: .disabled)
            
            originalActionView.tintColor = tintColor
            
            doneBadgeActionView.tintColor = tintColor
        }
    }
    
    // MARK: - Public
    
    func setHidden(_ hidden: Bool, animated: Bool) {
        let job = {
            var dy: CGFloat = 0
            if hidden {
                if #available(iOS 11.0, *) {
                    dy = (self.superview?.safeAreaInsets.bottom ?? 0) + self.bounds.height
                } else {
                    dy = self.bounds.height
                }
            }
            self.layer.transform = CATransform3DMakeTranslation(0, dy, 0)
        }
        if animated {
            UIView.animate(withDuration: TimeInterval(UINavigationControllerHideShowBarDuration), animations: job)
        } else {
            job()
        }
    }
    
    // MARK: - Private
    
    @objc private func edit() {
        delegate?.previewControlsViewDidEdit(self)
    }
    
    @objc private func selectOriginal(_ sender: WTCheckboxActionView) {
//        print(#function)
        sender.isSelected = !sender.isSelected
        delegate?.previewControlsViewDidSelectOriginal(self)
    }
    
    @objc private func done() {
        delegate?.previewControlsViewDidFinish(self)
    }
    
    // MARK: - Properties
    
    weak public var delegate: WTPreviewControlsViewDelegate?
    
    lazy private var visualEffectView: UIVisualEffectView = {
        let effectView = UIVisualEffectView(effect: UIBlurEffect(style: .extraLight))
        effectView.translatesAutoresizingMaskIntoConstraints = false
        effectView.backgroundColor = UIColor.clear
        effectView.isUserInteractionEnabled = false
        return effectView
    }()
    
    lazy public private(set) var editButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor.clear
        button.contentHorizontalAlignment = .left
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button.setTitle(self.WTIPLocalizedString("Edit"), for: .normal)
        button.setTitleColor(UIColor.black, for: .normal)
        button.addTarget(self, action: #selector(edit), for: .touchUpInside)
        return button
    }()
    
    lazy public private(set) var originalActionView: WTCheckboxActionView = {
        let view = WTCheckboxActionView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.clear
        view.isUserInteractionEnabled = true
        view.tintColor = self.tintColor
        view.textColor = UIColor.black
        view.indicatorView.style = .checkbox
        view.contentLabel.text = self.WTIPLocalizedString("Original")
        view.addTarget(self, action: #selector(selectOriginal(_:)), for: .touchUpInside)
        return view
    }()
    
    lazy public private(set) var doneBadgeActionView: WTBadgeActionView = {
        let view = WTBadgeActionView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.clear
        view.tintColor = self.tintColor
        view.contentButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        view.contentButton.setTitle(self.WTIPLocalizedString("Done"), for: .normal)
        view.contentButton.addTarget(self, action: #selector(done), for: .touchUpInside)
        return view
    }()
}

//
//  WTAlbumDetailsControlsView.swift
//  WTImagePickerController
//
//  Created by Jayce on 2017/3/21.
//  Copyright © 2017年 WhatsTaste. All rights reserved.
//

import UIKit

protocol WTAlbumDetailsControlsViewDelegate: class {
    func albumDetailsControlsViewDidEdit(_ view: WTAlbumDetailsControlsView)
    func albumDetailsControlsViewDidPreview(_ view: WTAlbumDetailsControlsView)
    func albumDetailsControlsViewDidFinish(_ view: WTAlbumDetailsControlsView)
}

private let horizontalMargin: CGFloat = 15
private let verticalMargin: CGFloat = 0
private let spacing: CGFloat = 15

class WTAlbumDetailsControlsView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // Initialization code
        self.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        addSubview(visualEffectView)
        addSubview(editButton)
        addSubview(previewButton)
        addSubview(doneBadgeActionView)
        
        addConstraint(NSLayoutConstraint.init(item: visualEffectView, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint.init(item: self, attribute: .right, relatedBy: .equal, toItem: visualEffectView, attribute: .right, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint.init(item: visualEffectView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint.init(item: self, attribute: .bottom, relatedBy: .equal, toItem: visualEffectView, attribute: .bottom, multiplier: 1, constant: 0))
        
        addConstraint(NSLayoutConstraint.init(item: editButton, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1, constant: horizontalMargin))
        addConstraint(NSLayoutConstraint.init(item: editButton, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: verticalMargin))
        addConstraint(NSLayoutConstraint.init(item: self, attribute: .bottom, relatedBy: .equal, toItem: editButton, attribute: .bottom, multiplier: 1, constant: verticalMargin))
        
        addConstraint(NSLayoutConstraint.init(item: previewButton, attribute: .left, relatedBy: .equal, toItem: editButton, attribute: .right, multiplier: 1, constant: spacing))
        addConstraint(NSLayoutConstraint.init(item: previewButton, attribute: .top, relatedBy: .equal, toItem: editButton, attribute: .top, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint.init(item: previewButton, attribute: .bottom, relatedBy: .equal, toItem: editButton, attribute: .bottom, multiplier: 1, constant: 0))
        
        addConstraint(NSLayoutConstraint.init(item: doneBadgeActionView, attribute: .left, relatedBy: .greaterThanOrEqual, toItem: previewButton, attribute: .right, multiplier: 1, constant: spacing))
        addConstraint(NSLayoutConstraint.init(item: doneBadgeActionView, attribute: .top, relatedBy: .equal, toItem: previewButton, attribute: .top, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint.init(item: doneBadgeActionView, attribute: .bottom, relatedBy: .equal, toItem: previewButton, attribute: .bottom, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint.init(item: self, attribute: .right, relatedBy: .equal, toItem: doneBadgeActionView, attribute: .right, multiplier: 1, constant: horizontalMargin))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var tintColor: UIColor! {
        didSet {
            editButton.setTitleColor(tintColor, for: .normal)
            editButton.setTitleColor(editButton.titleColor(for: .normal)?.withAlphaComponent(WTImagePickerControllerDisableAlphaComponent), for: .disabled)
            
            previewButton.setTitleColor(tintColor, for: .normal)
            previewButton.setTitleColor(editButton.titleColor(for: .normal)?.withAlphaComponent(WTImagePickerControllerDisableAlphaComponent), for: .disabled)
            
            doneBadgeActionView.tintColor = tintColor
        }
    }
    
    // MARK: - Public
    
    func setHidden(_ hidden: Bool, animated: Bool) {
        let job = {
            let dy = hidden ? self.bounds.height : 0
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
        delegate?.albumDetailsControlsViewDidEdit(self)
    }
    
    @objc private func preview() {
        delegate?.albumDetailsControlsViewDidPreview(self)
    }
    
    @objc private func done() {
        delegate?.albumDetailsControlsViewDidFinish(self)
    }
    
    // MARK: - Properties
    
    weak public var delegate: WTAlbumDetailsControlsViewDelegate?
    
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
        button.setTitle(self.localizedString("Edit"), for: .normal)
        button.setTitleColor(self.tintColor, for: .normal)
        button.setTitleColor(button.titleColor(for: .normal)?.withAlphaComponent(WTImagePickerControllerDisableAlphaComponent), for: .disabled)
        button.addTarget(self, action: #selector(edit), for: .touchUpInside)
        return button
    }()
    
    lazy public private(set) var previewButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor.clear
        button.contentHorizontalAlignment = .left
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button.setTitle(self.localizedString("Preview"), for: .normal)
        button.setTitleColor(self.tintColor, for: .normal)
        button.setTitleColor(button.titleColor(for: .normal)?.withAlphaComponent(WTImagePickerControllerDisableAlphaComponent), for: .disabled)
        button.addTarget(self, action: #selector(preview), for: .touchUpInside)
        return button
    }()
    
    lazy public private(set) var doneBadgeActionView: WTBadgeActionView = {
        let view = WTBadgeActionView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.clear
        view.tintColor = self.tintColor
        view.contentButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        view.contentButton.setTitle(self.localizedString("Done"), for: .normal)
        view.contentButton.addTarget(self, action: #selector(done), for: .touchUpInside)
        return view
    }()
}

//
//  WTEditingControlsView.swift
//  WTImagePickerController
//
//  Created by Jayce on 2017/2/10.
//  Copyright © 2017年 WhatsTaste. All rights reserved.
//

import UIKit

protocol WTEditingControlsViewDelegate: class {
    func editingControlsViewDidCancel(_ view: WTEditingControlsView)
    func editingControlsViewDidFinish(_ view: WTEditingControlsView)
    func editingControlsViewDidReset(_ view: WTEditingControlsView)
}

private let horizontalMargin: CGFloat = 15
private let verticalMargin: CGFloat = 10
private let spacing: CGFloat = 15

class WTEditingControlsView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // Initialization code
        addSubview(cancelButton)
        addSubview(doneButton)
        addSubview(resetButton)
        
        self.addConstraint(NSLayoutConstraint.init(item: cancelButton, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1, constant: horizontalMargin))
        self.addConstraint(NSLayoutConstraint.init(item: cancelButton, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: verticalMargin))
        self.addConstraint(NSLayoutConstraint.init(item: self, attribute: .bottom, relatedBy: .equal, toItem: cancelButton, attribute: .bottom, multiplier: 1, constant: verticalMargin))
        
        self.addConstraint(NSLayoutConstraint.init(item: resetButton, attribute: .left, relatedBy: .equal, toItem: cancelButton, attribute: .right, multiplier: 1, constant: spacing))
        self.addConstraint(NSLayoutConstraint.init(item: resetButton, attribute: .top, relatedBy: .equal, toItem: cancelButton, attribute: .top, multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint.init(item: resetButton, attribute: .bottom, relatedBy: .equal, toItem: cancelButton, attribute: .bottom, multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint.init(item: resetButton, attribute: .width, relatedBy: .equal, toItem: cancelButton, attribute: .width, multiplier: 1, constant: 0))
        
        self.addConstraint(NSLayoutConstraint.init(item: doneButton, attribute: .left, relatedBy: .equal, toItem: resetButton, attribute: .right, multiplier: 1, constant: spacing))
        self.addConstraint(NSLayoutConstraint.init(item: doneButton, attribute: .top, relatedBy: .equal, toItem: resetButton, attribute: .top, multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint.init(item: doneButton, attribute: .bottom, relatedBy: .equal, toItem: resetButton, attribute: .bottom, multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint.init(item: self, attribute: .right, relatedBy: .equal, toItem: doneButton, attribute: .right, multiplier: 1, constant: horizontalMargin))
        self.addConstraint(NSLayoutConstraint.init(item: doneButton, attribute: .width, relatedBy: .equal, toItem: resetButton, attribute: .width, multiplier: 1, constant: 0))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Private
    
    @objc private func cancel() {
        delegate?.editingControlsViewDidCancel(self)
    }
    
    @objc private func done() {
        delegate?.editingControlsViewDidFinish(self)
    }
    
    @objc private func reset() {
        delegate?.editingControlsViewDidReset(self)
    }
    
    // MARK: Properties
    
    weak public var delegate: WTEditingControlsViewDelegate?
    public var resetButtonEnabled: Bool {
        get {
            return resetButton.isEnabled
        }
        set {
            resetButton.isEnabled = newValue
        }
    }
    
    lazy private var cancelButton: UIButton = {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor.clear
        button.setImage(UIImage.cancelImage(), for: .normal)
        button.addTarget(self, action: #selector(cancel), for: .touchUpInside)
        button.contentHorizontalAlignment = .left
        return button
    }()
    
    lazy private var doneButton: UIButton = {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor.clear
        button.setImage(UIImage.doneImage(), for: .normal)
        button.addTarget(self, action: #selector(done), for: .touchUpInside)
        button.contentHorizontalAlignment = .right
        return button
    }()
    
    lazy private var resetButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor.clear
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button.setTitleColor(UIColor.white, for: .normal)
        button.setTitleColor(UIColor.lightGray, for: .disabled)
        button.setTitle(self.localizedString("Reset"), for: .normal)
        button.addTarget(self, action: #selector(reset), for: .touchUpInside)
        button.isEnabled = false
        return button
    }()
}

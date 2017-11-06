//
//  WTEditingView.swift
//  WTImagePickerController
//
//  Created by Jayce on 2017/2/9.
//  Copyright © 2017年 WhatsTaste. All rights reserved.
//

import UIKit

protocol WTEditingViewDelegate: class {
    func editingViewDidCancel(_ view: WTEditingView)
    func editingView(_ view: WTEditingView, didFinishWithResult result: WTEditingResult)
}

private let controlsViewHeight:CGFloat = 44

class WTEditingView: UIView, WTEditingControlsViewDelegate, WTEditingCropViewDelegate {

    init(frame: CGRect, image: UIImage, originalResult: WTEditingResult? = nil) {
        super.init(frame: frame)
        
        // Initialization code
        self.image = image
        self.originalResult = originalResult
        
        self.addSubview(cropView)
        self.addSubview(controlsView)
        
        self.addConstraint(NSLayoutConstraint.init(item: cropView, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint.init(item: self, attribute: .right, relatedBy: .equal, toItem: cropView, attribute: .right, multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint.init(item: cropView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0))
        
        self.addConstraint(NSLayoutConstraint.init(item: controlsView, attribute: .left, relatedBy: .equal, toItem: cropView, attribute: .left, multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint.init(item: controlsView, attribute: .right, relatedBy: .equal, toItem: cropView, attribute: .right, multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint.init(item: controlsView, attribute: .top, relatedBy: .equal, toItem: cropView, attribute: .bottom, multiplier: 1, constant: 0))
        if #available(iOS 11.0, *) {
            self.addConstraint(NSLayoutConstraint.init(item: self.safeAreaLayoutGuide, attribute: .bottom, relatedBy: .equal, toItem: controlsView, attribute: .bottom, multiplier: 1, constant: 0))
        } else {
            self.addConstraint(NSLayoutConstraint.init(item: self, attribute: .bottom, relatedBy: .equal, toItem: controlsView, attribute: .bottom, multiplier: 1, constant: 0))
        }
        controlsView.addConstraint(NSLayoutConstraint.init(item: controlsView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: controlsViewHeight))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - WTEditingControlsViewDelegate
    
    func editingControlsViewDidCancel(_ view: WTEditingControlsView) {
        delegate?.editingViewDidCancel(self)
    }
    
    func editingControlsViewDidFinish(_ view: WTEditingControlsView) {
        let result = cropView.currentResult()
//        print(#function + "\(result.frame)")
        delegate?.editingView(self, didFinishWithResult: result)
    }
    
    func editingControlsViewDidReset(_ view: WTEditingControlsView) {
        cropView.resetAnimated(true)
    }
    
    //MARK: WTEditingCropViewDelegate
    
    func editingCropViewDidBecomeResettable(_ view: WTEditingCropView) {
        controlsView.resetButtonEnabled = true
    }
    
    func editingCropViewDidBecomeNonResettable(_ view: WTEditingCropView) {
        controlsView.resetButtonEnabled = false
    }
    
    // MARK: - Properties
    
    weak public var delegate: WTEditingViewDelegate?
    lazy public private(set) var cropView: WTEditingCropView = {
        let view = WTEditingCropView(frame: CGRect(x: 0, y: 0, width: self.bounds.width, height: self.bounds.height - controlsViewHeight), image: self.image, originalResult: self.originalResult)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.clear
        view.delegate = self
        return view
    }()
    
    private var image: UIImage!
    private var originalResult: WTEditingResult?
    
    lazy public private(set) var controlsView: WTEditingControlsView = {
        let view = WTEditingControlsView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.clear
        view.delegate = self
        return view
    }()
}

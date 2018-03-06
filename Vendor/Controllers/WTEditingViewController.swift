//
//  WTEditingViewController.swift
//  WTImagePickerController
//
//  Created by Jayce on 2017/2/8.
//  Copyright © 2017年 WhatsTaste. All rights reserved.
//

import UIKit
import Photos

protocol WTEditingViewControllerDelegate: class {
    func editingViewController(_ controller: WTEditingViewController, didFinishWithResult result: WTEditingResult, forAsset asset: PHAsset)
}

class WTEditingViewController: UIViewController, WTEditingViewDelegate {

    convenience init(image: UIImage, asset: PHAsset? = nil, originalResult: WTEditingResult? = nil) {
        self.init(nibName: nil, bundle: nil)
        self.image = image
        self.asset = asset
        self.originalResult = originalResult
    }
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        edgesForExtendedLayout = .all
        
        view.backgroundColor = UIColor.black
        
        view.addSubview(editingView)
        view.addConstraint(NSLayoutConstraint.init(item: editingView, attribute: .left, relatedBy: .equal, toItem: view, attribute: .left, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint.init(item: view, attribute: .right, relatedBy: .equal, toItem: editingView, attribute: .right, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint.init(item: editingView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint.init(item: view, attribute: .bottom, relatedBy: .equal, toItem: editingView, attribute: .bottom, multiplier: 1, constant: 0))
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        editingView.cropView.layout()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - WTEditingViewDelegate
    
    func editingViewDidCancel(_ view: WTEditingView) {
        _ = navigationController?.popViewController(animated: true)
    }
    
    func editingView(_ view: WTEditingView, didFinishWithResult result: WTEditingResult) {
        guard asset != nil else {
            return
        }
        delegate?.editingViewController(self, didFinishWithResult: result, forAsset: asset!)
        _ = navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Private
    
    // MARK: - Properties
    
    weak public var delegate: WTEditingViewControllerDelegate?
    
    lazy public private(set) var editingView: WTEditingView = {
        let view = WTEditingView(frame: self.view.bounds, image: self.image, originalResult: self.originalResult)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.delegate = self
        return view
    }()
    
    private var image: UIImage!
    private var originalResult: WTEditingResult?
    private var asset: PHAsset?
}

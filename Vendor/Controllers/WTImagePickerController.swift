//
//  WTImagePickerController.swift
//  WTImagePickerController
//
//  Created by Jayce on 2017/2/8.
//  Copyright © 2017年 WhatsTaste. All rights reserved.
//

import UIKit

public typealias WTImagePickerControllerDidFinishHandler = (_ picker: WTImagePickerController, _ images: [UIImage]) -> Void
public typealias WTImagePickerControllerDidCancelHandler = (_ picker: WTImagePickerController) -> Void

public let WTImagePickerControllerDisableAlphaComponent: CGFloat = 0.3
private let WTImagePickerControllerPickLimitDefault: Int = 0

@objc public protocol WTImagePickerControllerDelegate: NSObjectProtocol {
    @objc optional func imagePickerController(_ picker: WTImagePickerController, didFinishWithImages images: [UIImage])
    @objc optional func imagePickerControllerDidCancel(_ picker: WTImagePickerController)
}

open class WTImagePickerController: UIViewController, WTAlbumViewControllerDelegate {    
    // MARK: - Life cycle
    
    override open func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.addChildViewController(contentViewController)
        self.view.addSubview(contentViewController.view)
        contentViewController.view.frame = self.view.bounds
        contentViewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
    override open var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    open override var childViewControllerForStatusBarHidden: UIViewController? {
        let topViewController = contentViewController.topViewController
        return topViewController
    }
    
    open override var childViewControllerForStatusBarStyle: UIViewController? {
        let topViewController = contentViewController.topViewController
        return topViewController
    }
    
    // MARK: - WTAlbumViewControllerDelegate
    
    func albumViewController(_ controller: WTAlbumViewController, didFinishWithImages images: [UIImage]) {
        delegate?.imagePickerController?(self, didFinishWithImages: images)
        didFinishHandler?(self, images)
    }
    
    func albumViewControllerDidCancel(_ controller: WTAlbumViewController) {
        delegate?.imagePickerControllerDidCancel?(self)
        didCancelHandler?(self)
    }
    
    // MARK: - Properties
    
    @objc weak public var delegate: WTImagePickerControllerDelegate?
    @objc public var didFinishHandler: WTImagePickerControllerDidFinishHandler?
    @objc public var didCancelHandler: WTImagePickerControllerDidCancelHandler?
    @objc public var tintColor: UIColor?
    @objc public var pickLimit: Int = WTImagePickerControllerPickLimitDefault //Default is 0, which means no limit
    
    lazy private var contentViewController: UINavigationController = {
        let tintColor = self.tintColor ?? self.view.tintColor
        let rootViewController = WTAlbumViewController(style: .plain)
        rootViewController.delegate = self
        rootViewController.tintColor = tintColor
        rootViewController.pickLimit = self.pickLimit
        let navigationController = UINavigationController(rootViewController: rootViewController)
        navigationController.isToolbarHidden = true
        navigationController.navigationBar.isTranslucent = false
//        navigationController.navigationBar.tintColor = tintColor
        return navigationController
    }()
}

// MARK: - Localization

public extension NSObject {
    func localizedString(_ key: String) -> String {
        return NSLocalizedString(key, tableName: "WTImagePickerController", bundle: Bundle(path: Bundle.main.path(forResource: "WTImagePickerController", ofType: "bundle")!)!, value: "", comment: "")
    }
}

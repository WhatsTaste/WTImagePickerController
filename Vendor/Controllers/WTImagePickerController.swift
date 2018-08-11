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
private let pickLimitDefault: Int = 0

@objc public protocol WTImagePickerControllerDelegate: NSObjectProtocol {
    @objc optional func imagePickerController(_ picker: WTImagePickerController, didFinishWithImages images: [UIImage])
    @objc optional func imagePickerControllerDidCancel(_ picker: WTImagePickerController)
}

open class WTImagePickerController: UIViewController, WTAlbumViewControllerDelegate {
    
    convenience init() {
        self.init(nibName: nil, bundle: nil)
    }
    
    // MARK: - Life cycle
    
    override open func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.addChildViewController(contentViewController)
        self.view.addSubview(contentViewController.view)
        contentViewController.view.frame = self.view.bounds
        contentViewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        contentViewController.didMove(toParentViewController: self)
    }
    
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return contentViewController.preferredStatusBarStyle
    }
    
    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
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
    @objc public var tintColor: UIColor = .init(red: 0, green: 122 / 255, blue: 255 / 255, alpha: 1)
    @objc public var pickLimit: Int = pickLimitDefault //Default is 0, which means no limit
    
    lazy private var contentViewController: UINavigationController = {
        let rootViewController = WTAlbumViewController(style: .plain)
        rootViewController.delegate = self
        rootViewController.tintColor = tintColor
        rootViewController.pickLimit = self.pickLimit
        let navigationController = UINavigationController(rootViewController: rootViewController)
        navigationController.isToolbarHidden = true
        navigationController.navigationBar.isTranslucent = false
        return navigationController
    }()
}

// MARK: - Localization

public extension NSObject {
    func WTIPLocalizedString(_ key: String) -> String {
        return NSLocalizedString(key, tableName: "WTImagePickerController", bundle: Bundle(path: Bundle.main.path(forResource: "WTImagePickerController", ofType: "bundle")!)!, value: "", comment: "")
    }
}

public extension UIView {
    func WTIPLayoutGuide() -> Any {
        if #available(iOS 11.0, *) {
            return safeAreaLayoutGuide
        } else {
            return self
        }
    }
}

public extension UIColor {
    func WTIPReverse(alpha: CGFloat?) -> UIColor {
        var localAlpha: CGFloat = 0
        
        var white: CGFloat = 0
        if getWhite(&white, alpha: &localAlpha) {
            return UIColor(white: 1 - white, alpha: alpha ?? localAlpha)
        }
        
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        if getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &localAlpha) {
            return UIColor(hue: 1 - hue, saturation: 1 - saturation, brightness: 1 - brightness, alpha: alpha ?? localAlpha)
        }
        
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        if getRed(&red, green: &green, blue: &blue, alpha: &localAlpha) {
            return UIColor(red: 1 - red, green: 1 - green, blue: 1 - blue, alpha: alpha ?? localAlpha)
        }
        
        return UIColor.clear
    }
}

//
//  WTPreviewViewController.swift
//  WTImagePickerController
//
//  Created by Jayce on 2017/2/8.
//  Copyright © 2017年 WhatsTaste. All rights reserved.
//

import UIKit
import Photos

protocol WTPreviewViewControllerDelegate: class {
    func previewViewControllerDidFinish(_ controller: WTPreviewViewController)//, didFinishWithIdentifiers identifiers: [String])
    func previewViewController(_ controller: WTPreviewViewController, canSelectAsset asset: PHAsset) -> Bool
    func previewViewController(_ controller: WTPreviewViewController, didSelectAsset asset: PHAsset)
    func previewViewController(_ controller: WTPreviewViewController, didDeselectAsset asset: PHAsset)
    func previewViewController(_ controller: WTPreviewViewController, didChangeOriginal original: Bool)
    func previewViewController(_ controller: WTPreviewViewController, didEditWithResult result: WTEditingResult, forAsset asset: PHAsset)
}

public let previewViewControllerMargin: CGFloat = 10
private let reuseIdentifier = "Cell"
private let controlsViewHeight:CGFloat = 44

class WTPreviewViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate, WTEditingViewControllerDelegate, WTPreviewControlsViewDelegate {
    
    convenience init(assets: [PHAsset], editedResults: [String: WTEditingResult]? = nil) {
        self.init(nibName: nil, bundle: nil)
        self.assets = assets
        if let results = editedResults {
            self.editedResults = results
        }
    }
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        edgesForExtendedLayout = .all
        automaticallyAdjustsScrollViewInsets = false
        
        navigationItem.title = localizedString("Preiview")
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: navigationIndicatorView)
        
        view.backgroundColor = UIColor.white
        view.addSubview(collectionView)
        view.addSubview(controlsView)
        
        view.addConstraint(NSLayoutConstraint.init(item: collectionView, attribute: .left, relatedBy: .equal, toItem: view, attribute: .left, multiplier: 1, constant: -previewViewControllerMargin))
        view.addConstraint(NSLayoutConstraint.init(item: view, attribute: .right, relatedBy: .equal, toItem: collectionView, attribute: .right, multiplier: 1, constant: -previewViewControllerMargin))
        view.addConstraint(NSLayoutConstraint.init(item: collectionView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint.init(item: view, attribute: .bottom, relatedBy: .equal, toItem: collectionView, attribute: .bottom, multiplier: 1, constant: 0))
        
        view.addConstraint(NSLayoutConstraint.init(item: controlsView, attribute: .left, relatedBy: .equal, toItem: view, attribute: .left, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint.init(item: view, attribute: .right, relatedBy: .equal, toItem: controlsView, attribute: .right, multiplier: 1, constant: 0))
//        view.addConstraint(NSLayoutConstraint.init(item: controlsView, attribute: .top, relatedBy: .equal, toItem: collectionView, attribute: .bottom, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint.init(item: view, attribute: .bottom, relatedBy: .equal, toItem: controlsView, attribute: .bottom, multiplier: 1, constant: 0))
        controlsView.addConstraint(NSLayoutConstraint.init(item: controlsView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: controlsViewHeight))
        
        updateSelections(atIndex: index)
        controlsView.originalActionView.isSelected = original
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        guard assets.count > 0 else {
            return
        }
        collectionView.collectionViewLayout.invalidateLayout()
        
        if shouldScrollToCurrentIndex {
            shouldScrollToCurrentIndex = false
        } else {
            return
        }
        if let index = index {
            collectionView.scrollToItem(at: IndexPath.init(item: index, section: 0), at: .left, animated: false)
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return statusBarHidden
    }
    
    // MARK: UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return assets.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: WTPreviewCell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! WTPreviewCell
        
        // Configure the cell
        let asset = assets[indexPath.item]
//        print(#function + "\(indexPath.item):" + asset.localIdentifier)
        cell.representedAssetIdentifier = asset.localIdentifier
        cell.singleTapHandler = { [weak self] in
            if self == nil {
                return
            }
            self?.toggleHidden()
        }
        var requestID = self.requestIDs[indexPath.item] ?? 0
        let progress = progresses[indexPath.item] ?? 0
//        print(#function + ":\(indexPath.item) Using:" + "\(progress)")
        cell.contentButton.isHidden = !(failedFlags[indexPath.item] ?? false)
        cell.progressView.isHidden = !(requestID != 0)
        cell.progressView.progress = progress
        if let image = editedImages[asset.localIdentifier] {
            cell.contentImageView.image = image
        } else {
            cell.contentImageView.image = degradedImages[indexPath.item] ?? nil
            if requestID == 0 {
//                print(#function + ":\(indexPath.item) Downloading begins")
                let request = {
                    requestID = PHImageManager.default().requestFullScreenImage(for: asset, allowsDegraded: true, resultHandler: { [weak self, weak cell, weak asset] (image, info) in
                        guard self != nil else {
                            return
                        }
                        guard image != nil else {
                            cell?.contentButton.isHidden = false
                            self?.failedFlags[indexPath.item] = true
                            self?.progresses[indexPath.item] = nil
                            return
                        }
//                        print(#function + ":\(indexPath.item) Downloading ends with image size" + "\(image!.size)")
                        self?.requestIDs[indexPath.item] = 0
                        if cell?.representedAssetIdentifier == asset?.localIdentifier {
                            cell?.progressView.isHidden = true
                            if (info?[PHImageResultIsDegradedKey] as? NSNumber)?.boolValue ?? false {
                                let size = CGSize(width: self!.view.bounds.width, height: self!.view.bounds.width)
                                cell?.contentImageView.image = image!.fitSize(size)
                                self?.degradedImages[indexPath.item] = cell?.contentImageView.image
                            } else {
                                cell?.contentImageView.image = image
                                self?.degradedImages[indexPath.item] = nil
                                self?.failedFlags[indexPath.item] = nil
                                self?.progresses[indexPath.item] = nil
                            }
                        }
                        }, progressHandler: { [weak self, weak cell, weak asset] progress in
                            guard self != nil else {
                                return
                            }
                            if cell?.representedAssetIdentifier == asset?.localIdentifier {
                                let progressValue = CGFloat(max(progress, 0))
//                                print(#function + ":\(indexPath.item) Downloading:" + "\(progressValue)")
                                cell?.progressView.isHidden = false
                                cell?.progressView.progress = progressValue
                                self?.progresses[indexPath.item] = progressValue
                            }
                    })
                    self.requestIDs[indexPath.item] = requestID
                }
                
                cell.contentButtonHandler = { (_) in
                    request()
                }
                
                request()
            }
        }
        
        return cell
    }
    
    // MARK: UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let someCell = cell as? WTPreviewCell {
            someCell.contentScrollView.zoomScale = someCell.contentScrollView.minimumZoomScale
        }
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = floor(collectionView.bounds.width)
        let height = floor(collectionView.bounds.height)
        let size = CGSize(width: width, height: height)
//        print(size)
       return size
    }
    
    // MARK: UIScrollViewDelegate
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        updateSelections()
    }
    
    // MARK: WTEditingViewControllerDelegate
    
    func editingViewController(_ controller: WTEditingViewController, didFinishWithResult result: WTEditingResult, forAsset asset: PHAsset) {
        editedResults[asset.localIdentifier] = result
//        print(#function + "\(editedResult!.frame)")
        
        if selectedIdentifiers.index(of: asset.localIdentifier) == nil {
            selectedIdentifiers.append(asset.localIdentifier)
        }
        editedImages[asset.localIdentifier] = result.image
        if let indexPath = currentIndexPath() {
            updateSelections(atIndex: indexPath.item)
            collectionView.reloadItems(at: [indexPath])
        }
        delegate?.previewViewController(self, didEditWithResult: result, forAsset: asset)
    }
    
    // MARK: WTPreviewControlsViewDelegate
    
    func previewControlsViewDidEdit(_ view: WTPreviewControlsView) {
        if let indexPath = currentIndexPath() {
            guard indexPath.item < assets.count else {
                return
            }
            let asset = assets[indexPath.item]
            let transition:((UIImage) -> Void) = { (image) in
                let destinationViewController = WTEditingViewController(image: image, asset: asset, originalResult: self.editedResults[asset.localIdentifier])
                destinationViewController.delegate = self
                self.navigationController?.pushViewController(destinationViewController, animated: true)
            }
            PHImageManager.default().requestFullScreenImage(for: asset, allowsDegraded: false, resultHandler: { (image, _) in
                guard image != nil else {
                    return
                }
                transition(image!)
            })
        }
    }
    
    func previewControlsViewDidSelectOriginal(_ view: WTPreviewControlsView) {
        original = !original
        delegate?.previewViewController(self, didChangeOriginal: original)
        updateSelections()
    }
    
    func previewControlsViewDidFinish(_ view: WTPreviewControlsView) {
        if selectedIdentifiers.count < pickLimit {
            if let indexPath = currentIndexPath() {
                guard indexPath.item < self.assets.count else {
                    return
                }
                let asset = self.assets[indexPath.item]
                if selectedIdentifiers.index(of: asset.localIdentifier) == nil {
                    selectedIdentifiers.append(asset.localIdentifier)
                    delegate?.previewViewController(self, didSelectAsset: asset)
                    updateSelections(atIndex: indexPath.item)
                    collectionView.reloadItems(at: [indexPath])
                }
            }
        }
        
        delegate?.previewViewControllerDidFinish(self)
    }
    
    // MARK: Private
    
    @objc private func navigationSelectAction(_ sender: WTSelectionIndicatorView) {
        if let indexPath = currentIndexPath() {
            let asset = assets[indexPath.item]
            if let index = selectedIdentifiers.index(of: asset.localIdentifier) {
//                print(#function + "\(index)")
                selectedIdentifiers.remove(at: index)
                navigationIndicatorView.isSelected = false
                delegate?.previewViewController(self, didDeselectAsset: asset)
            } else {
                if delegate?.previewViewController(self, canSelectAsset: asset) ?? false {
                    selectedIdentifiers.append(asset.localIdentifier)
                    navigationIndicatorView.isSelected = true
                    delegate?.previewViewController(self, didSelectAsset: asset)
                }
            }
        }
    }
    
    func updateSelections(atIndex currentIndex: Int? = nil) {
        var asset: PHAsset?
        if let index = currentIndex {
            guard index < assets.count else {
                return
            }
            asset = assets[index]
        } else if let indexPath = currentIndexPath() {
            guard indexPath.item < assets.count else {
                return
            }
            asset = assets[indexPath.item]
        }
        if let someAsset = asset {
//            navigationItem.title = someAsset.localIdentifier
            if selectedIdentifiers.index(of: someAsset.localIdentifier) != nil {
                navigationIndicatorView.isSelected = true
            } else {
                navigationIndicatorView.isSelected = false
            }
            
            if !original {
                controlsView.originalActionView.contentLabel.text = localizedString("Original")
            } else {
                controlsView.originalActionView.contentLabel.text = localizedString("Original") + "--"
                PHImageManager.default().requestOriginalImage(for: someAsset, resultHandler: { [weak self] (image, _) in
                    DispatchQueue.global().async {
                        guard self != nil else {
                            return
                        }
                        guard image != nil else {
                            return
                        }
                        if let data = UIImagePNGRepresentation(image!) {
                            var result = ""
                            let step: Double = pow(2, 10)
                            let count = Double(data.count)
                            if count < step {
                                result = String(format: "(%.0fB)", count)
                            } else if count < pow(step, 2) {
                                result = String(format: "(%.0fK)", count / step)
                            } else {
                                result = String(format: "(%.2fM)", count / pow(step, 2))
                            }
//                            print(#function + result)
                            guard result.lengthOfBytes(using: .utf8) > 0 else {
                                return
                            }
                            DispatchQueue.main.async {
                                guard self != nil else {
                                    return
                                }
                                self!.controlsView.originalActionView.contentLabel.text = self!.localizedString("Original") + result
                            }
                        }
                    }
                })
            }
        }
    }
    
    func currentIndexPath() -> IndexPath? {
        let visibleRect = CGRect(origin: collectionView.contentOffset, size: collectionView.bounds.size)
        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
        let visibleIndexPath = collectionView.indexPathForItem(at: visiblePoint)
        return visibleIndexPath
    }
    
    func toggleHidden() {
        statusBarHidden = !statusBarHidden
        setNeedsStatusBarAppearanceUpdate()
        navigationController?.setNavigationBarHidden(statusBarHidden, animated: true)
        controlsView.setHidden(statusBarHidden, animated: true)
    }
    
    // MARK: Properties
    
    weak public var delegate: WTPreviewViewControllerDelegate?
    public var tintColor: UIColor? {
        didSet {
            navigationIndicatorView.tintColor = tintColor
            controlsView.tintColor = tintColor
        }
    }
    public var index: Int?
    public var pickLimit: Int!
    public var original = false {
        didSet {
            self.controlsView.originalActionView.isSelected = original
        }
    }
    public var selectedIdentifiers = [String]() {
        didSet {
            self.controlsView.doneBadgeActionView.badge = selectedIdentifiers.count
        }
    }
    public var editedImages = [String: UIImage]()
    public var editedResults = [String: WTEditingResult]()
    
    private var assets: [PHAsset]!
    lazy private var requestIDs: [Int: PHImageRequestID] = {
        let dictionry = [Int: PHImageRequestID]()
        return dictionry
    }()
    lazy private var degradedImages: [Int: UIImage] = {
        let dictionry = [Int: UIImage]()
        return dictionry
    }()
    lazy private var failedFlags: [Int: Bool] = {
        let dictionry = [Int: Bool]()
        return dictionry
    }()
    private var progresses = [Int: CGFloat]()
    private var shouldScrollToCurrentIndex = true
    private var statusBarHidden = false
    
    lazy private var navigationIndicatorView: WTSelectionIndicatorView = {
        let view = WTSelectionIndicatorView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        view.translatesAutoresizingMaskIntoConstraints = true
        view.backgroundColor = UIColor.clear
        view.tintColor = self.tintColor
        view.isUserInteractionEnabled = true
        view.style = .checkmark
        view.insets = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
        view.addTarget(self, action: #selector(navigationSelectAction(_:)), for: .touchUpInside)
        return view
    }()
    
    lazy private var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.sectionInset = .zero
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = UIColor.white
        collectionView.alwaysBounceHorizontal = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.isPagingEnabled = true
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(WTPreviewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        return collectionView
    }()
    
    lazy private var controlsView: WTPreviewControlsView = {
        let view = WTPreviewControlsView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.delegate = self
        view.tintColor = self.tintColor
        view.doneBadgeActionView.badge = self.selectedIdentifiers.count
        return view
    }()
}

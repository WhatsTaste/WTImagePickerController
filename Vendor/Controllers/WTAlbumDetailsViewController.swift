//
//  WTPreviewViewController.swift
//  WTImagePickerController
//
//  Created by Jayce on 2017/2/8.
//  Copyright © 2017年 WhatsTaste. All rights reserved.
//

import UIKit
import Photos

protocol WTAlbumDetailsViewControllerDelegate: class {
    func albumDetailsViewController(_ controller: WTAlbumDetailsViewController, didFinishWithImages images: [UIImage])
    func albumDetailsViewControllerDidCancel(_ controller: WTAlbumDetailsViewController)
}

private let reuseIdentifier = "Cell"
private let columnNumber = 4
private let margin: CGFloat = 2
private let controlsViewHeight: CGFloat = 44

class WTAlbumDetailsViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, PHPhotoLibraryChangeObserver, WTAlbumDetailsControlsViewDelegate, WTPreviewViewControllerDelegate, WTEditingViewControllerDelegate {

    convenience init(collection: PHAssetCollection) {
        self.init(nibName: nil, bundle: nil)
        self.collection = collection
        self.fetchResult = PHAsset.fetchAssets(in: collection, options: nil)
    }
    
    deinit {
//        print(#file + #function)
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        edgesForExtendedLayout = .all
        navigationItem.title = collection.localizedTitle
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: WTIPLocalizedString("Cancel"), style: .plain, target: self, action: #selector(cancel))
        
        view.backgroundColor = UIColor.white
        view.addSubview(collectionView)
        view.addSubview(controlsView)
        view.addSubview(visualEffectView)
        visualEffectView.contentView.addSubview(activityIndicatorView)
        
        view.addConstraint(NSLayoutConstraint.init(item: collectionView, attribute: .left, relatedBy: .equal, toItem: view, attribute: .left, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint.init(item: view, attribute: .right, relatedBy: .equal, toItem: collectionView, attribute: .right, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint.init(item: collectionView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 0))
        
        view.addConstraint(NSLayoutConstraint.init(item: controlsView, attribute: .left, relatedBy: .equal, toItem: collectionView, attribute: .left, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint.init(item: collectionView, attribute: .right, relatedBy: .equal, toItem: controlsView, attribute: .right, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint.init(item: controlsView, attribute: .top, relatedBy: .equal, toItem: collectionView, attribute: .bottom, multiplier: 1, constant: 0))
        if #available(iOS 11.0, *) {
            view.addConstraint(NSLayoutConstraint.init(item: view.safeAreaLayoutGuide, attribute: .bottom, relatedBy: .equal, toItem: controlsView, attribute: .bottom, multiplier: 1, constant: 0))
        } else {
            view.addConstraint(NSLayoutConstraint.init(item: view, attribute: .bottom, relatedBy: .equal, toItem: controlsView, attribute: .bottom, multiplier: 1, constant: 0))
        }
        controlsView.addConstraint(NSLayoutConstraint.init(item: controlsView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: controlsViewHeight))
        
        view.addConstraint(NSLayoutConstraint.init(item: visualEffectView, attribute: .centerX, relatedBy: .equal, toItem: collectionView, attribute: .centerX, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint.init(item: visualEffectView, attribute: .centerY, relatedBy: .equal, toItem: collectionView, attribute: .centerY, multiplier: 1, constant: 0))
        visualEffectView.addConstraint(NSLayoutConstraint.init(item: visualEffectView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 80))
        visualEffectView.addConstraint(NSLayoutConstraint.init(item: visualEffectView, attribute: .height, relatedBy: .equal, toItem: visualEffectView, attribute: .width, multiplier: 1, constant: 0))
        
        visualEffectView.contentView.addConstraint(NSLayoutConstraint.init(item: activityIndicatorView, attribute: .centerX, relatedBy: .equal, toItem: visualEffectView.contentView, attribute: .centerX, multiplier: 1, constant: 0))
        visualEffectView.contentView.addConstraint(NSLayoutConstraint.init(item: activityIndicatorView, attribute: .centerY, relatedBy: .equal, toItem: visualEffectView.contentView, attribute: .centerY, multiplier: 1, constant: 0))
        
        resetCachedAssets()
        PHPhotoLibrary.shared().register(self)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Determine the size of the thumbnails to request from the PHCachingImageManager
        let scale = UIScreen.main.scale
        let cellSize = (collectionView.collectionViewLayout as! UICollectionViewFlowLayout).itemSize
        thumbnailSize = CGSize(width: cellSize.width * scale, height: cellSize.height * scale)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
       updateCachedAssets()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if shouldScrollToBottom {
            shouldScrollToBottom = false
        } else {
            return
        }
        if fetchResult.count > 0 {
//            print("Fetched \(fetchResult.count) images")
            collectionView.scrollToItem(at: IndexPath.init(item: fetchResult.count - 1, section: 0), at: .bottom, animated: false)
        }
    }

    // MARK: - UICollectionViewDataSource

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return fetchResult.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: WTAlbumDetailsCell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! WTAlbumDetailsCell
    
        // Configure the cell
        cell.tintColor = tintColor
        let asset = fetchResult.object(at: indexPath.item)
//        print(#function + "\(indexPath.item):" + asset.localIdentifier)
        cell.representedAssetIdentifier = asset.localIdentifier
        if let image = editedImages[asset.localIdentifier] {
            cell.thumbnailImage = image
        } else {
            imageManager.requestImage(for: asset, targetSize: thumbnailSize, contentMode: .aspectFill, resultHandler: { [weak cell, weak asset] (image, _) in
                if cell?.representedAssetIdentifier == asset?.localIdentifier {
                    cell?.thumbnailImage = image
                }
            })
        }
        let flag = selectedIdentifiers.contains(asset.localIdentifier)
        cell.checked = flag
        cell.selectHandler = { [weak self] in
            if let index = self?.selectedIdentifiers.index(of: asset.localIdentifier) {
//                print(#function + "\(index)")
                self?.selectedIdentifiers.remove(at: index)
            } else {
                self?.selectedIdentifiers.append(asset.localIdentifier)
            }
            self?.collectionView.reloadItems(at: [indexPath])
        }
        return cell
    }

    // MARK: - UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        var assets = [PHAsset]()
        for i in 0 ..< fetchResult.count {
            let asset = fetchResult.object(at: i)
//            print(#function + "\(i):" + asset.localIdentifier)
            assets.append(asset)
        }
        guard assets.count > 0 else {
            return
        }
        let destinationViewController = WTPreviewViewController(assets: assets, editedResults: editedResults)
        destinationViewController.delegate = self
        destinationViewController.tintColor = tintColor
        destinationViewController.index = indexPath.item
        destinationViewController.pickLimit = pickLimit
        destinationViewController.original = original
        destinationViewController.selectedIdentifiers = selectedIdentifiers
        destinationViewController.editedImages = editedImages
        navigationController?.pushViewController(destinationViewController, animated: true)
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size: CGFloat = floor((collectionView.bounds.width - margin * CGFloat((columnNumber - 1))) / CGFloat(columnNumber))
        return CGSize(width: size, height: size)
    }
    
    // MARK: - PHPhotoLibraryChangeObserver
    
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        
        guard let changes = changeInstance.changeDetails(for: fetchResult)
            else { return }
        
        // Change notifications may be made on a background queue. Re-dispatch to the
        // main queue before acting on the change as we'll be updating the UI.
        DispatchQueue.main.sync {
            // Hang on to the new fetch result.
            fetchResult = changes.fetchResultAfterChanges
            if changes.hasIncrementalChanges {
                // If we have incremental diffs, animate them in the collection view.
                collectionView.performBatchUpdates({
                    // For indexes to make sense, updates must be in this order:
                    // delete, insert, reload, move
                    if let removed = changes.removedIndexes, removed.count > 0 {
                        self.collectionView.deleteItems(at: removed.map({ IndexPath(item: $0, section: 0) }))
                    }
                    if let inserted = changes.insertedIndexes, inserted.count > 0 {
                        self.collectionView.insertItems(at: inserted.map({ IndexPath(item: $0, section: 0) }))
                    }
                    if let changed = changes.changedIndexes, changed.count > 0 {
                        self.collectionView.reloadItems(at: changed.map({ IndexPath(item: $0, section: 0) }))
                    }
                    changes.enumerateMoves { fromIndex, toIndex in
                        self.collectionView.moveItem(at: IndexPath(item: fromIndex, section: 0), to: IndexPath(item: toIndex, section: 0))
                    }
                })
            } else {
                // Reload the collection view if incremental diffs are not available.
                collectionView.reloadData()
            }
            resetCachedAssets()
        }
    }
    
    // MARK: - UIScrollViewDelegate
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateCachedAssets()
    }
    
    // MARK: - WTAlbumDetailsControlsViewDelegate
    
    func albumDetailsControlsViewDidEdit(_ view: WTAlbumDetailsControlsView) {
        guard selectedIdentifiers.count > 0 else {
            return
        }
        let identifier = selectedIdentifiers[0]
        let asset = PHAsset.fetchAssets(withLocalIdentifiers: [identifier], options: nil).firstObject
        guard asset != nil else {
            return
        }
        let transition:((UIImage) -> Void) = { (image) in
            let destinationViewController = WTEditingViewController(image: image, asset: asset!, originalResult: self.editedResults[asset!.localIdentifier])
            destinationViewController.delegate = self
            self.navigationController?.pushViewController(destinationViewController, animated: true)
        }
        controlsView.editButton.isEnabled = false
        imageManager.requestFullScreenImage(for: asset!, allowsDegraded: false, resultHandler: { [weak self] (image, _) in
            guard image != nil else {
                return
            }
            self?.controlsView.editButton.isEnabled = true
            transition(image!)
        })
    }
    
    func albumDetailsControlsViewDidPreview(_ view: WTAlbumDetailsControlsView) {
        guard selectedIdentifiers.count > 0 else {
            return
        }
        var assets = [PHAsset]()
        for i in 0 ..< selectedIdentifiers.count {
            let identifier = selectedIdentifiers[i]
            if let asset = PHAsset.fetchAssets(withLocalIdentifiers: [identifier], options: nil).firstObject {
                assets.append(asset)
            }
        }
        guard assets.count > 0 else {
            return
        }
        let destinationViewController = WTPreviewViewController(assets: assets, editedResults: editedResults)
        destinationViewController.delegate = self
        destinationViewController.tintColor = tintColor
        destinationViewController.index = 0
        destinationViewController.pickLimit = pickLimit
        destinationViewController.original = original
        destinationViewController.selectedIdentifiers = selectedIdentifiers
        destinationViewController.editedImages = editedImages
        self.navigationController?.pushViewController(destinationViewController, animated: true)
    }
    
    func albumDetailsControlsViewDidFinish(_ view: WTAlbumDetailsControlsView) {
        done()
    }
    
    // MARK: - WTPreviewViewControllerDelegate
    
    func previewViewControllerDidFinish(_ controller: WTPreviewViewController) {
        done()
    }
    
    func previewViewController(_ controller: WTPreviewViewController, canSelectAsset asset: PHAsset) -> Bool {
        let result = pickLimit == 0 || selectedIdentifiers.count < pickLimit
        if !result {
            alertForPickLimit()
        }
        return result
    }
    
    func previewViewController(_ controller: WTPreviewViewController, didSelectAsset asset: PHAsset) {
//        print(#function + asset.localIdentifier)
        selectedIdentifiers.append(asset.localIdentifier)
        collectionView.reloadData()
    }
    
    func previewViewController(_ controller: WTPreviewViewController, didDeselectAsset asset: PHAsset) {
        if let index = selectedIdentifiers.index(of: asset.localIdentifier) {
//            print(#function + "\(index)")
            selectedIdentifiers.remove(at: index)
        }
        collectionView.reloadData()
    }
    
    func previewViewController(_ controller: WTPreviewViewController, didChangeOriginal original: Bool) {
        self.original = original
    }
    
    func previewViewController(_ controller: WTPreviewViewController, didEditWithResult result: WTEditingResult, forAsset asset: PHAsset) {
        appleResult(result, asset: asset)
    }
    
    // MARK: - WTEditingViewControllerDelegate
    
    func editingViewController(_ controller: WTEditingViewController, didFinishWithResult result: WTEditingResult, forAsset asset: PHAsset?) {
        guard let someAsset = asset else { return }
        appleResult(result, asset: someAsset)
    }
    
    // MARK: - Private
    
    @objc private func cancel() {
        self.delegate?.albumDetailsViewControllerDidCancel(self)
    }
    
    @objc private func done() {
        guard selectedIdentifiers.count > 0 else {
            delegate?.albumDetailsViewController(self, didFinishWithImages: [])
            return
        }
        view.isUserInteractionEnabled = false
        activityIndicatorView.startAnimating()
        visualEffectView.isHidden = false
        var assets = [PHAsset]()
        for i in 0 ..< selectedIdentifiers.count {
            let identifier = selectedIdentifiers[i]
            if let asset = PHAsset.fetchAssets(withLocalIdentifiers: [identifier], options: nil).firstObject {
                assets.append(asset)
            }
        }
        
        // Use a serial queue
        DispatchQueue(label: String(describing: self)).async { [weak self] in
            guard self != nil else {
                print("Self got nil when it's our turn to do something")
                return
            }
            
            var images = [UIImage]()
            var counter: Int = 0
            for i in 0 ..< assets.count {
                guard self != nil else {
                    print("Self got nil at the \(i) request, so we'll drop the remaining \(assets.count - i) requests")
                    return
                }
                let asset = assets[i]
                let resultHandler: ((_ image: UIImage?, _ info: [AnyHashable : Any]?) -> Void) = { [weak self] (image, _) in
//                    print("Response \(i):" + asset.localIdentifier + "\(image?.size)")
                    counter = counter + 1
                    guard self != nil else {
                        print("Self got nil at the \(i) response")
                        return
                    }
                    if image != nil {
                        images.append(image!)
                        
                        // Callback when finished
                        if counter == assets.count {
                            DispatchQueue.main.async {
                                self!.view.isUserInteractionEnabled = true
                                self!.visualEffectView.isHidden = true
                                self!.activityIndicatorView.stopAnimating()
                                self!.delegate?.albumDetailsViewController(self!, didFinishWithImages: images)
                            }
                        }
                    }
                }
                if let image = self!.editedImages[asset.localIdentifier] {
                    resultHandler(image, nil)
                } else {
//                    print("Starts \(i):" + asset.localIdentifier)
                    if self!.original {
                        self!.imageManager.requestOriginalImage(for: asset, isSynchronous: true, resultHandler: resultHandler)
                    } else {
                        self!.imageManager.requestFullScreenImage(for: asset, isSynchronous: true, resultHandler: resultHandler)
                    }
//                    print("Ends \(i):" + asset.localIdentifier)
                }
            }
        }
    }
    
    func appleResult(_ result: WTEditingResult, asset: PHAsset) {
        editedResults[asset.localIdentifier] = result
        editedImages[asset.localIdentifier] = result.image
        
        if selectedIdentifiers.index(of: asset.localIdentifier) == nil {
            selectedIdentifiers.append(asset.localIdentifier)
        }
        collectionView.reloadData()
    }
    
    func alertForPickLimit() {
        let title = String(format: WTIPLocalizedString("Select a maximum of %ld photos"), pickLimit)
        let controller = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        controller.addAction(UIAlertAction(title: WTIPLocalizedString("OK"), style: .default, handler: nil))
        present(controller, animated: true, completion: nil)
    }
    
    fileprivate func resetCachedAssets() {
        imageManager.stopCachingImagesForAllAssets()
        previousPreheatRect = .zero
    }
    
    fileprivate func updateCachedAssets() {
        // Update only if the view is visible.
        guard isViewLoaded && view.window != nil else {
            return
        }
        
        // The preheat window is twice the height of the visible rect.
        let preheatRect = view!.bounds.insetBy(dx: 0, dy: -0.5 * view!.bounds.height)
        
        // Update only if the visible area is significantly different from the last preheated area.
        let delta = abs(preheatRect.midY - previousPreheatRect.midY)
        guard delta > view.bounds.height / 3 else {
            return
        }
        
        // Compute the assets to start caching and to stop caching.
        let (addedRects, removedRects) = differencesBetweenRects(previousPreheatRect, preheatRect)
        let addedAssets = addedRects.flatMap { rect in
            collectionView.indexPathsForElements(in: rect)
            }.map { indexPath in
                fetchResult.object(at: indexPath.item)
        }
        let removedAssets = removedRects.flatMap { rect in
            collectionView.indexPathsForElements(in: rect)
            }.map { indexPath in
                fetchResult.object(at: indexPath.item)
        }
        
        // Update the assets the PHCachingImageManager is caching.
        imageManager.startCachingImages(for: addedAssets, targetSize: thumbnailSize, contentMode: .aspectFill, options: nil)
        imageManager.stopCachingImages(for: removedAssets, targetSize: thumbnailSize, contentMode: .aspectFill, options: nil)
        
        // Store the preheat rect to compare against in the future.
        previousPreheatRect = preheatRect
    }
    
    fileprivate func differencesBetweenRects(_ old: CGRect, _ new: CGRect) -> (added: [CGRect], removed: [CGRect]) {
        if old.intersects(new) {
            var added = [CGRect]()
            if new.maxY > old.maxY {
                added += [CGRect(x: new.origin.x, y: old.maxY, width: new.width, height: new.maxY - old.maxY)]
            }
            if old.minY > new.minY {
                added += [CGRect(x: new.origin.x, y: new.minY, width: new.width, height: old.minY - new.minY)]
            }
            var removed = [CGRect]()
            if new.maxY < old.maxY {
                removed += [CGRect(x: new.origin.x, y: new.maxY, width: new.width, height: old.maxY - new.maxY)]
            }
            if old.minY < new.minY {
                removed += [CGRect(x: new.origin.x, y: old.minY, width: new.width, height: new.minY - old.minY)]
            }
            return (added, removed)
        } else {
            return ([new], [old])
        }
    }
    
    // MARK: - Properties
    
    weak public var delegate: WTAlbumDetailsViewControllerDelegate?
    public var tintColor: UIColor? {
        didSet {
            controlsView.tintColor = tintColor
        }
    }
    public var pickLimit: Int!
    
    lazy private var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = margin
        layout.minimumInteritemSpacing = margin
        layout.sectionInset = .zero
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = UIColor.white
        collectionView.alwaysBounceVertical = true
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(WTAlbumDetailsCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        return collectionView
    }()
    
    lazy private var controlsView: WTAlbumDetailsControlsView = {
        let view = WTAlbumDetailsControlsView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.delegate = self
        view.editButton.isEnabled = false
        view.previewButton.isEnabled = false
        view.doneBadgeActionView.contentButton.isEnabled = false
        view.tintColor = self.tintColor
        return view
    }()
    
    lazy private var visualEffectView: UIVisualEffectView = {
        let effectView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        effectView.translatesAutoresizingMaskIntoConstraints = false
        effectView.backgroundColor = UIColor.clear
        effectView.isUserInteractionEnabled = false
        effectView.isHidden = true
        effectView.layer.masksToBounds = true
        effectView.layer.cornerRadius = 10
        return effectView
    }()
    
    lazy private var activityIndicatorView: UIActivityIndicatorView = {
        let activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .white)
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicatorView.hidesWhenStopped = true
        activityIndicatorView.tintColor = self.tintColor
        return activityIndicatorView
    }()
    
    private var collection: PHAssetCollection!
    private var fetchResult: PHFetchResult<PHAsset>!
    
    private let imageManager = PHCachingImageManager()
    private var thumbnailSize: CGSize!
    private var previousPreheatRect = CGRect.zero
    private var shouldScrollToBottom = true
    private var original = false
    private var selectedIdentifiers = [String]() {
        didSet {
//            print(selectedIdentifiers)
            if pickLimit > 0 {
                if selectedIdentifiers.count > pickLimit {
                    selectedIdentifiers.removeLast()
                    alertForPickLimit()
                }
            }
            
            controlsView.editButton.isEnabled = selectedIdentifiers.count == 1
            controlsView.previewButton.isEnabled = selectedIdentifiers.count > 0
            controlsView.doneBadgeActionView.contentButton.isEnabled = selectedIdentifiers.count > 0
            controlsView.doneBadgeActionView.badge = selectedIdentifiers.count
        }
    }
    private var editedImages = [String: UIImage]()
    private var editedResults = [String: WTEditingResult]()
}

private extension UICollectionView {
    func indexPathsForElements(in rect: CGRect) -> [IndexPath] {
        let allLayoutAttributes = collectionViewLayout.layoutAttributesForElements(in: rect)!
        return allLayoutAttributes.map { $0.indexPath }
    }
}

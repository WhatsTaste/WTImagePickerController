//
//  WTAlbumViewController.swift
//  WTImagePickerController
//
//  Created by Jayce on 2017/2/8.
//  Copyright © 2017年 WhatsTaste. All rights reserved.
//

import UIKit
import Photos

protocol WTAlbumViewControllerDelegate: class {
    func albumViewController(_ controller: WTAlbumViewController, didFinishWithImages images: [UIImage])
    func albumViewControllerDidCancel(_ controller: WTAlbumViewController)
}

private let reuseIdentifier = "Cell"
private let preferredCollectionIdentifierKey = "preferredCollectionIdentifierKey"

class WTAlbumViewController: UITableViewController, PHPhotoLibraryChangeObserver, WTAlbumDetailsViewControllerDelegate {

    deinit {
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
        
        navigationItem.title = WTIPLocalizedString("Photos")
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: WTIPLocalizedString("Cancel"), style: .plain, target: self, action: #selector(cancel))
        smartAlbums = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .albumRegular, options: nil)
        userCollections = PHCollectionList.fetchTopLevelUserCollections(with: nil)
        
        PHPhotoLibrary.shared().register(self)
        
        tableView.rowHeight = 60
        tableView.separatorInset = .zero
        tableView.register(WTAlbumCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.tableFooterView = UIView(frame: .zero)
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return collections.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: WTAlbumCell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! WTAlbumCell

        // Configure the cell...
        cell.accessoryType = .disclosureIndicator
        cell.contentImageView.image = nil
        let collection = collections[indexPath.row]
        let assets = PHAsset.fetchAssets(in: collection, options: nil)
        if let asset = assets.lastObject {
            cell.representedAssetIdentifier = asset.localIdentifier
            
            let scale = UIScreen.main.scale
            let realHeight = tableView.rowHeight * scale
            let targetSize = CGSize(width:realHeight, height: realHeight)
            
            let imageOptions = PHImageRequestOptions()
            imageOptions.resizeMode = .exact
            
            PHImageManager.default().requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFill, resultHandler: { [weak cell, weak asset] (image, _) in
                if cell?.representedAssetIdentifier == asset?.localIdentifier {
                    cell?.contentImageView.image = image
                }
            })
        }
        cell.titleLabel.text = collection.localizedTitle
        cell.subtitleLabel.text = "(\(assets.count))"
        return cell
    }
    
    // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let collection = collections[indexPath.row]
//        print("\(collection) \(PHAsset.fetchAssets(in: collection, options: nil))")
        let destinationViewController = WTAlbumDetailsViewController(collection: collection)
        destinationViewController.delegate = self
        destinationViewController.tintColor = tintColor
        destinationViewController.pickLimit = pickLimit
        navigationController?.pushViewController(destinationViewController, animated: true)
        
        UserDefaults.standard.set(collection.localIdentifier, forKey: preferredCollectionIdentifierKey)
        UserDefaults.standard.synchronize()
    }

    // MARK: - PHPhotoLibraryChangeObserver
    
    public func photoLibraryDidChange(_ changeInstance: PHChange) {
        // Change notifications may be made on a background queue. Re-dispatch to the
        // main queue before acting on the change as we'll be updating the UI.
        DispatchQueue.main.sync {
            // Update the cached fetch results, and reload the table sections to match.
            if let changeDetails = changeInstance.changeDetails(for: smartAlbums) {
                smartAlbums = changeDetails.fetchResultAfterChanges
                tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
            }
            if let changeDetails = changeInstance.changeDetails(for: userCollections) {
                userCollections = changeDetails.fetchResultAfterChanges
                tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
            }
            
        }
    }
    
    // MARK: - WTAlbumDetailsViewControllerDelegate
    
    func albumDetailsViewController(_ controller: WTAlbumDetailsViewController, didFinishWithImages images: [UIImage]) {
        delegate?.albumViewController(self, didFinishWithImages: images)
    }
    
    func albumDetailsViewControllerDidCancel(_ controller: WTAlbumDetailsViewController) {
        delegate?.albumViewControllerDidCancel(self)
    }

    // MARK: - Private
    
    @objc private func cancel() {
        self.delegate?.albumViewControllerDidCancel(self)
    }
    
    // MARK: - Properties
    
    weak public var delegate: WTAlbumViewControllerDelegate?
    public var tintColor: UIColor?
    public var pickLimit: Int!
    
    private var smartAlbums: PHFetchResult<PHAssetCollection>! {
        didSet {
            var preferredCollection: PHAssetCollection?
            let preferredCollectionIdentifier = UserDefaults.standard.string(forKey: preferredCollectionIdentifierKey)
            for i in 0 ..< smartAlbums.count {
                let collection = smartAlbums.object(at: i)
                if collection.localIdentifier == preferredCollectionIdentifier {
                    preferredCollection = collection
                }
//                print("\(i) \(collection)")
                guard collection.assetCollectionSubtype != .smartAlbumAllHidden else {
                    continue
                }
                let assets = PHAsset.fetchAssets(in: collection, options: nil)
                if assets.count == 0 {
                    continue
                }
                if collection.assetCollectionSubtype == .smartAlbumUserLibrary {
                    collections.insert(collection, at: 0)
                } else {
                    collections.append(collection)
                }
            }
            
            guard preferredCollection != nil else {
                return
            }
            let destinationViewController = WTAlbumDetailsViewController(collection: preferredCollection!)
            destinationViewController.delegate = self
            destinationViewController.tintColor = tintColor
            destinationViewController.pickLimit = pickLimit
            navigationController?.pushViewController(destinationViewController, animated: false)
        }
    }
    
    private var userCollections: PHFetchResult<PHCollection>! {
        didSet {
            for i in 0 ..< userCollections.count {
                let collection = userCollections.object(at: i)
                if let someCollection = collection as? PHCollectionList {
                    let result = PHCollection.fetchCollections(in: someCollection, options: nil)
                    for j in 0 ..< result.count {
                        let innerCollection = result.object(at: j)
                        if let someInnerCollection = innerCollection as? PHAssetCollection {
                            let assets = PHAsset.fetchAssets(in: someInnerCollection, options: nil)
                            if assets.count == 0 {
                                continue
                            }
                            collections.append(someInnerCollection)
                        }
                    }
                } else if let someCollection = collection as? PHAssetCollection {
                    let assets = PHAsset.fetchAssets(in: someCollection, options: nil)
                    if assets.count == 0 {
                        continue
                    }
                    collections.append(someCollection)
                }
            }
        }
    }
    lazy private var collections: [PHAssetCollection] = {
        return [PHAssetCollection]()
    }()
}

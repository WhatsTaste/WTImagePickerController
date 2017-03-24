//
//  PHImageManager+WhatsTaste.swift
//  WTImagePickerController
//
//  Created by Jayce on 2017/2/20.
//  Copyright © 2017年 WhatsTaste. All rights reserved.
//

import Photos

public extension PHImageManager {
    @discardableResult
    public func requestImage(for asset: PHAsset, targetSize: CGSize, contentMode: PHImageContentMode = .aspectFit, allowsDegraded: Bool = false, isSynchronous: Bool = false, resultHandler: @escaping (_ image: UIImage?, [AnyHashable : Any]?) -> Void, progressHandler: ((_ progress: Double) -> Void)? = nil) -> PHImageRequestID {
//        print(#function + asset.localIdentifier)
        let options = PHImageRequestOptions()
        options.deliveryMode = .opportunistic
        options.resizeMode = .fast
        options.isNetworkAccessAllowed = true
        options.isSynchronous = isSynchronous
        
        options.progressHandler = { (progress, error, _, _) in
            Thread.executeOnMainThread {
//                print(#function + ":\(error)" + ":\(progress)")
                progressHandler?(progress)
            }
        }
        
        let requestID  = PHImageManager.default().requestImage(for: asset, targetSize: targetSize, contentMode: contentMode, options: options, resultHandler: { image, info in
//            print(#function + asset.localIdentifier + "\(info)")
            // Cancel
            if let cancelled = info?[PHImageCancelledKey] as? NSNumber {
                if cancelled.boolValue {
                    return
                }
            }
            
            // Error
            if info?[PHImageErrorKey] == nil {
                if let someImage = image {
                    // Degraded
                    if allowsDegraded {
                        Thread.executeOnMainThread {
                            resultHandler(someImage, info)
                        }
                    } else {
                        if let degraded = info?[PHImageResultIsDegradedKey] as? NSNumber {
                            if degraded.boolValue {
//                                print(#function + " Drop degraded image")
                                return
                            }
                        }
                        Thread.executeOnMainThread {
                            resultHandler(someImage, info)
                        }
                    }
                } else {
                    if let isInCloud = info?[PHImageResultIsInCloudKey] as? NSNumber {
                        // If result is in the cloud, return and  submit another request
                        if isInCloud.boolValue {
                            print(#function + "Starts request from iCloud")
                            PHImageManager.default().requestImage(for: asset, targetSize: targetSize, contentMode: contentMode, options: options, resultHandler: { (image, info) in
                                print(#function + "Ends request from iCloud" + ", info is: \(info)")
                                // Error
                                if image != nil && info?[PHImageErrorKey] == nil {
                                    // Degraded
                                    if allowsDegraded {
                                        Thread.executeOnMainThread {
                                            resultHandler(image, info)
                                        }
                                    } else {
                                        if let degraded = info?[PHImageResultIsDegradedKey] as? NSNumber {
                                            if degraded.boolValue {
                                                return
                                            }
                                        }
                                        Thread.executeOnMainThread {
                                            resultHandler(image, info)
                                        }
                                    }
                                } else {
                                    Thread.executeOnMainThread {
                                        resultHandler(nil, info)
                                    }
                                }
                            })
                            return
                        }
                    }
                    Thread.executeOnMainThread {
                        resultHandler(nil, info)
                    }
                }
            } else {
                Thread.executeOnMainThread {
                    print(#function + "\(info?[PHImageErrorKey]!)")
                    resultHandler(nil, info)
                }
            }
        })
//        requestID.timer(options.progressHandler).resume()
        return requestID
    }
    
    @discardableResult
    public func requestFullScreenImage(for asset: PHAsset, allowsDegraded: Bool = false, isSynchronous: Bool = false, resultHandler: @escaping (_ image: UIImage?, [AnyHashable : Any]?) -> Void, progressHandler: ((_ progress: Double) -> Void)? = nil) -> PHImageRequestID {
        let screen = UIScreen.main
        let scale = screen.scale
        let targetSize = CGSize(width: screen.bounds.width * scale, height: screen.bounds.height * scale)
        return requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFit, allowsDegraded: allowsDegraded, isSynchronous: isSynchronous, resultHandler: resultHandler, progressHandler: progressHandler)
    }
    
    @discardableResult
    public func requestOriginalImage(for asset: PHAsset, isSynchronous: Bool = false, resultHandler: @escaping (_ image: UIImage?, [AnyHashable : Any]?) -> Void) -> PHImageRequestID {
        return requestImage(for: asset, targetSize: PHImageManagerMaximumSize, isSynchronous: isSynchronous, resultHandler: resultHandler)
    }
}

public extension Thread {
    class func executeOnMainThread(_ work: @escaping @convention(block) () -> Void) {
        if Thread.isMainThread {
            work()
        } else {
            DispatchQueue.main.async(execute: work)
        }
    }
}


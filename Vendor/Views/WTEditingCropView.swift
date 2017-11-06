//
//  WTEditingCropView.swift
//  WTImagePickerController
//
//  Created by Jayce on 2017/2/9.
//  Copyright © 2017年 WhatsTaste. All rights reserved.
//

import UIKit

protocol WTEditingCropViewDelegate: class {
    func editingCropViewDidBecomeResettable(_ view: WTEditingCropView)
    func editingCropViewDidBecomeNonResettable(_ view: WTEditingCropView)
}

private enum WTEditingCropViewOverlayEdge : Int {
    case none
    case topLeft
    case top
    case topRight
    case right
    case bottomRight
    case bottom
    case bottomLeft
    case left
}

private let padding: CGFloat = 14
private let timerDuration: TimeInterval = 0.8
private let minimumBoxSize: CGFloat = 42
private let rotateButtonTop: CGFloat = 0
private let rotateButtonBottom: CGFloat = 10
private let rotateButtonWidth: CGFloat = 44
private let rotateButtonHeight: CGFloat = 44

class WTEditingCropView: UIView, UIScrollViewDelegate, UIGestureRecognizerDelegate {

    init(frame: CGRect, image: UIImage, originalResult: WTEditingResult? = nil) {
        super.init(frame: frame)
        
        // Initialization code
        self.image = image
        self.originalResult = originalResult
        if let result = originalResult {
            imageCropframe = result.frame
            applyAngle(result.angle)
        }
        
//        self.backgroundColor = UIColor(white: 0.12, alpha: 1)
        
        addSubview(scrollView)
        scrollView.addSubview(backgroundContainerView)
        backgroundContainerView.addSubview(backgroundImageView)
        addSubview(backgroundImageOverlayView)
        addSubview(visualEffectView)
        addSubview(foregroundContainerView)
        foregroundContainerView.addSubview(foregroundImageView)
        addSubview(overlayView)
        addSubview(rotateButton)
        
        //scrollView
//        self.addConstraint(NSLayoutConstraint.init(item: scrollView, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1, constant: 0))
//        self.addConstraint(NSLayoutConstraint.init(item: self, attribute: .right, relatedBy: .equal, toItem: scrollView, attribute: .right, multiplier: 1, constant: 0))
//        self.addConstraint(NSLayoutConstraint.init(item: scrollView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0))
//        self.addConstraint(NSLayoutConstraint.init(item: self, attribute: .bottom, relatedBy: .equal, toItem: scrollView, attribute: .bottom, multiplier: 1, constant: 0))

        //backgroundContainerView
//        backgroundContainerLeftConstraint = (NSLayoutConstraint.init(item: backgroundContainerView, attribute: .left, relatedBy: .equal, toItem: scrollView, attribute: .left, multiplier: 1, constant: 0))
//        backgroundContainerRightConstraint = (NSLayoutConstraint.init(item: scrollView, attribute: .right, relatedBy: .equal, toItem: backgroundContainerView, attribute: .right, multiplier: 1, constant: 0))
//        backgroundContainerTopConstraint = (NSLayoutConstraint.init(item: backgroundContainerView, attribute: .top, relatedBy: .equal, toItem: scrollView, attribute: .top, multiplier: 1, constant: 0))
//        backgroundContainerBottomConstraint = (NSLayoutConstraint.init(item: scrollView, attribute: .bottom, relatedBy: .equal, toItem: backgroundContainerView, attribute: .bottom, multiplier: 1, constant: 0))
//        scrollView.addConstraints([backgroundContainerLeftConstraint, backgroundContainerRightConstraint, backgroundContainerTopConstraint, backgroundContainerBottomConstraint])
        
        //backgroundImageView
//        backgroundContainerView.addConstraint(NSLayoutConstraint.init(item: backgroundImageView, attribute: .left, relatedBy: .equal, toItem: backgroundContainerView, attribute: .left, multiplier: 1, constant: 0))
//        backgroundContainerView.addConstraint(NSLayoutConstraint.init(item: backgroundContainerView, attribute: .right, relatedBy: .equal, toItem: backgroundImageView, attribute: .right, multiplier: 1, constant: 0))
//        backgroundContainerView.addConstraint(NSLayoutConstraint.init(item: backgroundImageView, attribute: .top, relatedBy: .equal, toItem: backgroundContainerView, attribute: .top, multiplier: 1, constant: 0))
//        backgroundContainerView.addConstraint(NSLayoutConstraint.init(item: backgroundContainerView, attribute: .bottom, relatedBy: .equal, toItem: backgroundImageView, attribute: .bottom, multiplier: 1, constant: 0))
        
        //backgroundImageOverlayView
        self.addConstraint(NSLayoutConstraint.init(item: backgroundImageOverlayView, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint.init(item: self, attribute: .right, relatedBy: .equal, toItem: backgroundImageOverlayView, attribute: .right, multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint.init(item: backgroundImageOverlayView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint.init(item: self, attribute: .bottom, relatedBy: .equal, toItem: backgroundImageOverlayView, attribute: .bottom, multiplier: 1, constant: 0))
        
        //visualEffectView
        self.addConstraint(NSLayoutConstraint.init(item: visualEffectView, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint.init(item: self, attribute: .right, relatedBy: .equal, toItem: visualEffectView, attribute: .right, multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint.init(item: visualEffectView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint.init(item: self, attribute: .bottom, relatedBy: .equal, toItem: visualEffectView, attribute: .bottom, multiplier: 1, constant: 0))
        
        //foregroundContainerView
//        foregroundContainerLeftConstraint = NSLayoutConstraint.init(item: foregroundContainerView, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1, constant: 0)
//        foregroundContainerRightConstraint = NSLayoutConstraint.init(item: self, attribute: .right, relatedBy: .equal, toItem: foregroundContainerView, attribute: .right, multiplier: 1, constant: 0)
//        foregroundContainerTopConstraint = NSLayoutConstraint.init(item: foregroundContainerView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0)
//        foregroundContainerBottomConstraint = NSLayoutConstraint.init(item: self, attribute: .bottom, relatedBy: .equal, toItem: foregroundContainerView, attribute: .bottom, multiplier: 1, constant: 0)
//        self.addConstraints([foregroundContainerLeftConstraint, foregroundContainerRightConstraint, foregroundContainerTopConstraint, foregroundContainerBottomConstraint])
        
        //foregroundImageView
//        foregroundLeftConstraint = NSLayoutConstraint.init(item: foregroundImageView, attribute: .left, relatedBy: .equal, toItem: foregroundContainerView, attribute: .left, multiplier: 1, constant: 0)
//        foregroundRightConstraint = NSLayoutConstraint.init(item: foregroundContainerView, attribute: .right, relatedBy: .equal, toItem: foregroundImageView, attribute: .right, multiplier: 1, constant: 0)
//        foregroundTopConstraint = NSLayoutConstraint.init(item: foregroundImageView, attribute: .top, relatedBy: .equal, toItem: foregroundContainerView, attribute: .top, multiplier: 1, constant: 0)
//        foregroundBottomConstraint = NSLayoutConstraint.init(item: foregroundContainerView, attribute: .bottom, relatedBy: .equal, toItem: foregroundImageView, attribute: .bottom, multiplier: 1, constant: 0)
//        foregroundContainerView.addConstraints([foregroundLeftConstraint, foregroundRightConstraint, foregroundTopConstraint, foregroundBottomConstraint])
        
        //overlayView
        self.addConstraint(NSLayoutConstraint.init(item: overlayView, attribute: .left, relatedBy: .equal, toItem: foregroundContainerView, attribute: .left, multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint.init(item: foregroundContainerView, attribute: .right, relatedBy: .equal, toItem: overlayView, attribute: .right, multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint.init(item: overlayView, attribute: .top, relatedBy: .equal, toItem: foregroundContainerView, attribute: .top, multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint.init(item: foregroundContainerView, attribute: .bottom, relatedBy: .equal, toItem: overlayView, attribute: .bottom, multiplier: 1, constant: 0))
        
        self.addConstraint(NSLayoutConstraint.init(item: rotateButton, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: rotateButtonTop))
        self.addConstraint(NSLayoutConstraint.init(item: self, attribute: .bottom, relatedBy: .equal, toItem: rotateButton, attribute: .bottom, multiplier: 1, constant: rotateButtonBottom))
        rotateButton.addConstraint(NSLayoutConstraint.init(item: rotateButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: rotateButtonWidth))
        rotateButton.addConstraint(NSLayoutConstraint.init(item: rotateButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: rotateButtonHeight))
        
        scrollView.panGestureRecognizer.require(toFail: panGestureRecognizer)
        self.addGestureRecognizer(panGestureRecognizer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
//        print(self.frame)
        if superview == nil {
            return
        }
        layoutInitialImage()
        
        if restoreAngle != 0 {
            applyAngle(restoreAngle)
            angle = restoreAngle
            restoreAngle = 0
            cropBoxLastEditedAngle = angle
        }
        
        if !restoreImageCropFrame.isEmpty {
            imageCropframe = restoreImageCropFrame
            restoreImageCropFrame = .zero
            captureStateForImageRotation()
        }
        
        checkForCanReset()
    }
    
    // MARK: - UIScrollViewDelegate
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return backgroundContainerView
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        matchForegroundToBackground()
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
//        print(#function + "\(scrollView.contentOffset)")
        startEditing()
    }
    
    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        startEditing()
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
//        print(#function + "\(scrollView.contentOffset)")
        startResetTimer()
        checkForCanReset()
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        startResetTimer()
        checkForCanReset()
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        if scrollView.isTracking {
            cropBoxLastEditedZoomScale = scrollView.zoomScale
            cropBoxLastEditedMinZoomScale = scrollView.minimumZoomScale
        }
        
        matchForegroundToBackground()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            startResetTimer()
        }
    }
    
    // MARK: - UIGestureRecognizerDelegate
    
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer != panGestureRecognizer {
            return true
        }
        
        let location = gestureRecognizer.location(in: self)
        let frame = overlayView.frame
        let threshold: CGFloat = 22
        let innerFrame = frame.insetBy(dx: threshold, dy: threshold)
        let outerFrame = frame.insetBy(dx: -threshold, dy: -threshold)
        if innerFrame.contains(location) || !outerFrame.contains(location) {
            return false
        }
        return true
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if panGestureRecognizer.state == .changed {
            return false
        }
        return true
    }
    
    // MARK: - Private
    
    private func matchForegroundToBackground() {
        if disableForgroundMatching || backgroundContainerView.superview == nil {
            return
        }
        let frame = backgroundContainerView.superview!.convert(backgroundContainerView.frame, to: foregroundContainerView)
        foregroundImageView.frame = frame
    }
    
    @objc private func panAction(fromSender sender: UIPanGestureRecognizer) {
        var location = sender.location(in: self)
        if sender.state == .began {
            startEditing()
            panOriginPoint = location
            cropOriginFrame = cropBoxFrame
            tappedEdge = cropEdgeForPoint(location)
        }
        
        if sender.state == .ended {
            startResetTimer()
        }
        
        var frame = cropBoxFrame
        let originFrame = cropOriginFrame
        let contentFrame = contentBounds
        location.x = max(contentBounds.minX, location.x)
        location.y = max(contentBounds.minY, location.y)
        let dx = ceil(location.x - panOriginPoint.x)
        let dy = ceil(location.y - panOriginPoint.y)
        
        switch tappedEdge {
        case .left:
            frame.origin.x = originFrame.minX + dx
            frame.size.width = originFrame.width - dx
        case .right:
            frame.size.width = originFrame.width + dx
        case .bottom:
            frame.size.height = originFrame.height + dy
        case .top:
            frame.origin.y = originFrame.minY + dy
            frame.size.height = originFrame.height - dy
        case .topLeft:
            frame.origin.x = originFrame.minX + dx
            frame.size.width = originFrame.width - dx
            frame.origin.y = originFrame.minY + dy
            frame.size.height = originFrame.height - dy
        case .topRight:
            frame.size.width = originFrame.width + dx
            frame.origin.y = originFrame.minY + dy
            frame.size.height = originFrame.height - dy
        case .bottomLeft:
            frame.origin.x = originFrame.minX + dx
            frame.size.width = originFrame.width - dx
            frame.size.height = originFrame.height + dy
        case .bottomRight:
            frame.size.width = originFrame.width + dx
            frame.size.height = originFrame.height + dy
        default:
            break
        }
        
        let minSize = CGSize(width: minimumBoxSize, height: minimumBoxSize)
        let maxSize = CGSize(width: contentFrame.width, height: contentFrame.height)
        frame.size.width = max(frame.width, minSize.width)
        frame.size.height = max(frame.height, minSize.height)
        frame.size.width = min(frame.width, maxSize.width)
        frame.size.height = min(frame.height, maxSize.height)
        frame.origin.x = max(frame.minX, contentFrame.minX)
        frame.origin.x = min(frame.minX, contentFrame.maxX - minSize.width)
        frame.origin.y = max(frame.minY, contentFrame.minY)
        frame.origin.y = min(frame.minY, contentFrame.maxY - minSize.height)
        
        cropBoxFrame = frame
        
        checkForCanReset()
    }
    
    public func moveCroppedContentToCenterAnimated(_ animated: Bool) {
        let contentRect = contentBounds
        var cropFrame = cropBoxFrame
        
        if cropFrame.width < CGFloat(Float.ulpOfOne) || cropFrame.height < CGFloat(Float.ulpOfOne) {
            return
        }
        
        let scale = min(contentRect.width / cropFrame.width, contentRect.height / cropFrame.height)
        let focusPoint = CGPoint(x: cropFrame.midX, y: cropFrame.midY)
        let midPoint = CGPoint(x: contentRect.midX, y: contentRect.midY)
        cropFrame.size.width = ceil(cropFrame.width * scale)
        cropFrame.size.height = ceil(cropFrame.height * scale)
        cropFrame.origin.x = contentRect.minX + ceil((contentRect.width - cropFrame.width) * 0.5)
        cropFrame.origin.y = contentRect.minY + ceil((contentRect.height - cropFrame.height) * 0.5)
        
        var contentTargetPoint = CGPoint.zero
        contentTargetPoint.x = (focusPoint.x + scrollView.contentOffset.x) * scale
        contentTargetPoint.y = (focusPoint.y + scrollView.contentOffset.y) * scale
        
        var offset = CGPoint.zero
        offset.x = -midPoint.x + contentTargetPoint.x
        offset.y = -midPoint.y + contentTargetPoint.y
        
        offset.x = max(-cropFrame.minX, offset.x)
        offset.y = max(-cropFrame.minY, offset.y)
        
        let translateBlock = { [weak self] in
            guard self != nil else {
                return
            }
            self!.disableForgroundMatching = true
            if scale < 1 - CGFloat(Float.ulpOfOne) || scale > 1 + CGFloat(Float.ulpOfOne) {
                self!.scrollView.zoomScale *= scale
                self!.scrollView.zoomScale = min(self!.scrollView.maximumZoomScale, self!.scrollView.zoomScale)
            }
            
            if self!.scrollView.zoomScale < self!.scrollView.maximumZoomScale - CGFloat(Float.ulpOfOne) {
                offset.x = min(-cropFrame.maxX + self!.scrollView.contentSize.width, offset.x)
                offset.y = min(-cropFrame.maxY + self!.scrollView.contentSize.height, offset.y)
                self!.scrollView.contentOffset = offset
//                print(#function + "\(offset)")
            }
            
            self!.cropBoxFrame = cropFrame
            
            self!.disableForgroundMatching = false
            
            self!.matchForegroundToBackground()
        }
        
        if !animated {
            translateBlock()
            return
        }
        
        matchForegroundToBackground()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) { 
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .beginFromCurrentState, animations: translateBlock, completion: nil)
        }
    }
    
    private func layoutInitialImage(_ reset: Bool = false) {
        if reset {
            originalResult = nil
        }
        
        let imageSize = self.imageSize
//        scrollView.contentSize = imageSize
        
        let bounds = self.contentBounds
        let scale: CGFloat = min(bounds.width / imageSize.width, bounds.height / imageSize.height)
        let scaledImageSize = CGSize(width: floor(imageSize.width * scale), height: floor(imageSize.height * scale))
        
        scrollView.minimumZoomScale = scale
        
        var frame = CGRect.zero
        frame.size = scaledImageSize
        frame.origin.x = bounds.minX + floor((bounds.width - frame.width) * 0.5)
        frame.origin.y = bounds.minY + floor((bounds.height - frame.height) * 0.5)
        cropBoxFrame = frame
        
        scrollView.zoomScale = scrollView.minimumZoomScale
        scrollView.contentSize = scaledImageSize
        if frame.width < scaledImageSize.width - CGFloat(Float.ulpOfOne) || frame.height < scaledImageSize.height - CGFloat(Float.ulpOfOne) {
            var offset = CGPoint.zero
            offset.x = -floor((scrollView.frame.width - scaledImageSize.width) * 0.5)
            offset.y = -floor((scrollView.frame.height - scaledImageSize.height) * 0.5)
            scrollView.contentOffset = offset
        }

        captureStateForImageRotation()
        
        originalCropBoxSize = scaledImageSize
        originalContentOffset = scrollView.contentOffset
        
        checkForCanReset()
        matchForegroundToBackground()
    }
    
    private func rotateImageNinetyDegreesAnimated(_ animated: Bool, clockwise: Bool) {
        if rotateAnimationInProgress {
            return
        }
        
        if resetTimer != nil {
            cancelResetTimer()
            setEditing(false, animated: false)
            
            cropBoxLastEditedAngle = angle
            captureStateForImageRotation()
        }
        
        var newAngle = angle
        newAngle = clockwise ? newAngle + 90 : newAngle - 90
        if newAngle <= -360 || newAngle >= 360 {
            newAngle = 0
        }
        
        angle = newAngle
        
        var angleInRadians: CGFloat = 0
        switch angle {
        case 90:
            angleInRadians = CGFloat(Double.pi / 2)
        case -90:
            angleInRadians = -CGFloat(Double.pi / 2)
        case 180:
            angleInRadians = CGFloat(Double.pi)
        case -180:
            angleInRadians = -CGFloat(Double.pi)
        case 270:
            angleInRadians = CGFloat(Double.pi + Double.pi / 2)
        case -270:
            angleInRadians = -CGFloat(Double.pi + Double.pi / 2)
        default:
            break
        }
        
        let rotation = CGAffineTransform.identity.rotated(by: angleInRadians)
        let contentBounds = self.contentBounds
        let cropBoxFrame = self.cropBoxFrame
        let scale = min(contentBounds.width / cropBoxFrame.height, contentBounds.height / cropBoxFrame.width)
        
        let cropMidPoint = CGPoint(x: cropBoxFrame.midX, y: cropBoxFrame.midY)
        var cropTargetPoint = CGPoint(x: cropMidPoint.x + scrollView.contentOffset.x, y: cropMidPoint.y + scrollView.contentOffset.y)
        
        var newCropFrame = CGRect.zero
        if labs(angle) == labs(cropBoxLastEditedAngle) || (labs(angle) * -1) == ((labs(cropBoxLastEditedAngle) - 180) % 360) {
            newCropFrame.size = cropBoxLastEditedSize
//            print(#function + "if" + "\(newCropFrame.size)")
            scrollView.minimumZoomScale = cropBoxLastEditedMinZoomScale
            scrollView.zoomScale = cropBoxLastEditedZoomScale
        } else {
            newCropFrame.size = CGSize(width: floor(self.cropBoxFrame.height * scale), height: floor(self.cropBoxFrame.width * scale))
//            print(#function + "else" + "\(newCropFrame.size)")
            scrollView.minimumZoomScale *= scale
            scrollView.zoomScale *= scale
        }
        
        newCropFrame.origin.x = floor(bounds.width - newCropFrame.width) * 0.5
        newCropFrame.origin.y = floor(bounds.height - newCropFrame.height) * 0.5
        
        var snapshotView: UIView?
        if animated {
            snapshotView = foregroundContainerView.snapshotView(afterScreenUpdates: false)
            rotateAnimationInProgress = true
        }
        
        backgroundImageView.transform = rotation
        
        let containerSize = backgroundContainerView.frame.size
        backgroundContainerView.frame = CGRect(origin: .zero, size: .init(width: containerSize.height, height: containerSize.width))
        backgroundImageView.frame = CGRect(origin: .zero, size: backgroundImageView.frame.size)
        
        foregroundContainerView.transform = .identity
        foregroundImageView.transform = rotation
        
        scrollView.contentSize = backgroundContainerView.frame.size
        
        self.cropBoxFrame = newCropFrame
        moveCroppedContentToCenterAnimated(false)
        newCropFrame = self.cropBoxFrame
        
        cropTargetPoint.x *= scale
        cropTargetPoint.y *= scale
        
        let swap = cropTargetPoint.x
        if clockwise {
            cropTargetPoint.x = scrollView.contentSize.width - cropTargetPoint.y
            cropTargetPoint.y = swap
        } else {
            cropTargetPoint.x = cropTargetPoint.y
            cropTargetPoint.y = scrollView.contentSize.height - swap
        }
        
        let midPoint = CGPoint(x: newCropFrame.midX, y: newCropFrame.midY)
        var offset = CGPoint.zero
        offset.x = floor(-midPoint.x + cropTargetPoint.x)
        offset.y = floor(-midPoint.y + cropTargetPoint.y)
        offset.x = max(-scrollView.contentInset.left, offset.x)
        offset.y = max(-scrollView.contentInset.top, offset.y)
        
        if offset.x == scrollView.contentOffset.x && offset.y == scrollView.contentOffset.y && scale == 1 {
            matchForegroundToBackground()
        }
        scrollView.contentOffset = offset
        
        if animated {
            guard snapshotView != nil else {
                return
            }
            snapshotView!.center = CGPoint(x: scrollView.center.x - (-insets.left + insets.right) / 2, y: scrollView.center.y - (-insets.top + insets.bottom) / 2)// scrollView.center
            self.addSubview(snapshotView!)
            
            backgroundContainerView.isHidden = true
            foregroundContainerView.isHidden = true
            visualEffectView.isHidden = true
            overlayView.isHidden = true
            
            UIView.animate(withDuration: 0.45, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0.8, options: .beginFromCurrentState, animations: { 
                var transform = CGAffineTransform(rotationAngle: CGFloat(clockwise ? Double.pi / 2 : -Double.pi / 2))
                transform = transform.scaledBy(x: scale, y: scale)
                snapshotView!.transform = transform
            }, completion: { (completed) in
                self.backgroundContainerView.isHidden = false
                self.foregroundContainerView.isHidden = false
                self.visualEffectView.isHidden = false
                self.overlayView.isHidden = false
                
                self.backgroundContainerView.alpha = 0
                self.overlayView.alpha = 0
                self.visualEffectView.alpha = 1
                
                UIView.animate(withDuration: 0.45, animations: {
                    snapshotView!.alpha = 0
                    self.backgroundContainerView.alpha = 1
                    self.overlayView.alpha = 1
                }, completion: { (completed) in
                    self.rotateAnimationInProgress = false
                    snapshotView!.removeFromSuperview()
                })
            })
        }
        
        checkForCanReset()
    }
    
    public func resetAnimated(_ animated: Bool) {
        if !animated || angle != 0 {
            angle = 0
            
            scrollView.zoomScale = 1
            
            let imageRect = CGRect(origin: .zero, size: image.size)
            
            backgroundImageView.transform = .identity
            backgroundContainerView.transform = .identity
            backgroundImageView.frame = imageRect
            backgroundContainerView.frame = imageRect
            
            foregroundImageView.transform = .identity
            foregroundImageView.frame = imageRect
            
            layoutInitialImage(true)
            
            moveCroppedContentToCenterAnimated(false)
            
            return
        }
        
        if resetTimer != nil {
            cancelResetTimer()
            setEditing(false, animated: false)
        }
        
        setSimpleRenderMode(true, animated: false)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) { 
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .beginFromCurrentState, animations: { 
                self.layoutInitialImage(true)
                self.moveCroppedContentToCenterAnimated(false)
            }, completion: { (completed) in
                self.setSimpleRenderMode(false, animated: true)
            })
        }
    }
    
    public func currentResult() -> WTEditingResult {
        if canBeReset {
            // Refresh when changed
            if result.image == nil || !result.frame.equalTo(imageCropframe) || result.angle != angle {
                result.frame = imageCropframe
                result.angle = angle
                result.zoomScale = scrollView.zoomScale
                result.contentOffset = scrollView.contentOffset
                result.image = image.croppingWithFrame(result.frame, angle: result.angle)
//                print(#function + " frame:\(result.frame)")
            }
        } else {
            result.image = image
        }
        return result
    }
    
    private func startEditing() {
        cancelResetTimer()
        setEditing(true, animated: true)
    }
    
    private func startResetTimer() {
        if resetTimer != nil {
            return
        }
        
        resetTimer = Timer.scheduledTimer(timeInterval: timerDuration, target: self, selector: #selector(timerTriggered), userInfo: nil, repeats: false)
    }
    
    @objc private func timerTriggered() {
        setEditing(false, animated: true)
        resetTimer?.invalidate()
        resetTimer = nil
    }
    
    private func cancelResetTimer() {
        resetTimer?.invalidate()
        resetTimer = nil
    }
    
    private func checkForCanReset() {
        var canReset = false
        if angle != 0 {
            canReset = true
//            print(#function + "rotated")
        } else if scrollView.zoomScale > scrollView.minimumZoomScale + CGFloat(Float.ulpOfOne)  {
            canReset = true
//            print(#function + "zoomed")
        } else if Int(floor(cropBoxFrame.width)) != Int(floor(originalCropBoxSize.width)) || Int(floor(cropBoxFrame.height)) != Int(floor(originalCropBoxSize.height)) {
            canReset = true
//            print(#function + "scaled")
        } else if originalResult != nil {
            canReset = true
//            print(#function + "edited")
        }
//        print(#function + "\(canReset)")
        self.canBeReset = canReset
    }
    
    private func captureStateForImageRotation() {
        cropBoxLastEditedSize = cropBoxFrame.size
        cropBoxLastEditedZoomScale = scrollView.zoomScale
        cropBoxLastEditedMinZoomScale = scrollView.minimumZoomScale
    }
    
    private func cropEdgeForPoint(_ point: CGPoint) -> WTEditingCropViewOverlayEdge {
        var frame = cropBoxFrame
        //account for padding around the box
        frame = frame.insetBy(dx: -32, dy: -32)
        
        let size: CGFloat = 64
        
        //make sure the corners take priority
        
        let topLeftRect = CGRect(origin: frame.origin, size: CGSize(width: size, height: size))
        if topLeftRect.contains(point) {
            return .topLeft
        }
        
        var topRightRect = topLeftRect
        topRightRect.origin.x = frame.maxX - size
        if topRightRect.contains(point) {
            return .topRight
        }
        
        var bottomLeftRect = topLeftRect
        bottomLeftRect.origin.y = frame.maxY - size
        if bottomLeftRect.contains(point) {
            return .bottomLeft
        }
        
        var bottomRightRect = topRightRect
        bottomRightRect.origin.y = bottomLeftRect.minY
        if bottomRightRect.contains(point) {
            return .bottomRight
        }
        
        //check for edges
        
        let topRect = CGRect(origin: frame.origin, size: CGSize(width: frame.width, height: size))
        if topRect.contains(point) {
            return .top
        }
        
        var bottomRect = topRect
        bottomRect.origin.y = frame.maxY - size
        if bottomRect.contains(point) {
            return .bottom
        }
        
        let leftRect = CGRect(origin: frame.origin, size: CGSize(width: size, height: frame.height))
        if leftRect.contains(point) {
            return .left
        }
        
        var rightRect = leftRect
        rightRect.origin.x = frame.maxX - size
        if rightRect.contains(point) {
            return .right
        }
        
        return .none
    }
    
    private func setEditing(_ editing: Bool, animated: Bool) {
        if editing == self.editing {
            return
        }
        
        self.editing = editing
        
        overlayView.setGridHidden(!editing, animated: animated)
        
        if !editing {
            moveCroppedContentToCenterAnimated(animated)
            captureStateForImageRotation()
            cropBoxLastEditedAngle = angle
        }
        
        if !animated {
            toggleVisualEffectViewVisible(!editing)
            return
        }
        
        let duration: TimeInterval = editing ? 0.05 : 0.35
        let delay: TimeInterval = editing ? 0 : 0.35
        UIView.animateKeyframes(withDuration: duration, delay: delay, options: UIViewKeyframeAnimationOptions(rawValue: 0), animations: { 
            self.toggleVisualEffectViewVisible(!editing)
        }, completion: nil)
    }
    
    private func toggleVisualEffectViewVisible(_ visible: Bool) {
        visualEffectView.effect = visible ? blurEffect : nil
    }
    
    private func updateToImageCropFrame(_ imageCropframe: CGRect) {
//        print(#function + " frame:\(imageCropframe)")
        let minimumSize = scrollView.minimumZoomScale
        let scaledOffset = CGPoint(x: imageCropframe.minX * minimumSize, y: imageCropframe.minY * minimumSize)
        let scaledCropSize = CGSize(width: imageCropframe.width * minimumSize, height: imageCropframe.height * minimumSize)
        
        let bounds = contentBounds
        let scale = min(bounds.width / scaledCropSize.width, bounds.height / scaledCropSize.height)
        
        scrollView.zoomScale = scrollView.minimumZoomScale * scale
        
        var frame = CGRect.zero
        frame.size = CGSize(width: scaledCropSize.width * scale, height: scaledCropSize.height * scale)
        
        var cropBoxFrame = CGRect.zero
        cropBoxFrame.size = frame.size
        cropBoxFrame.origin.x = (self.bounds.width - frame.width) * 0.5
        cropBoxFrame.origin.y = (self.bounds.height - frame.height) * 0.5
        self.cropBoxFrame = cropBoxFrame
        
        frame.origin.x = scaledOffset.x * scale - scrollView.contentInset.left
        frame.origin.y = scaledOffset.y * scale - scrollView.contentInset.top
        scrollView.contentOffset = frame.origin
    }
    
    private func setSimpleRenderMode(_ simpleMode: Bool, animated: Bool) {
        if simpleMode == simpleRenderMode {
            return
        }
        
        simpleRenderMode = simpleMode
        
        editing = false
        
        if !animated {
            toggleVisualEffectViewVisible(!simpleMode)
            return
        }
        
        UIView.animate(withDuration: 0.25) { 
            self.toggleVisualEffectViewVisible(!simpleMode)
        }
    }
    
    // MARK: - Properties
    
    weak public var delegate: WTEditingCropViewDelegate?
    public var insets: UIEdgeInsets = UIEdgeInsetsMake(0, 0, rotateButtonHeight + rotateButtonTop + rotateButtonBottom, 0)
    
    lazy private var scrollView: WTEditingCropScrollView = {
        let scrollView = WTEditingCropScrollView(frame: self.bounds)
        scrollView.translatesAutoresizingMaskIntoConstraints = true
        scrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        scrollView.backgroundColor = UIColor.clear
        scrollView.alwaysBounceHorizontal = true
        scrollView.alwaysBounceVertical = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.maximumZoomScale = 4
        scrollView.delegate = self
        scrollView.touchesBeganHandler = { [weak self] in
            self?.startEditing()
        }
        scrollView.touchesEndedHandler = { [weak self] in
            self?.startResetTimer()
        }
        return scrollView
    }()
    lazy private var backgroundContainerView: UIView = {
        let view = UIView(frame: self.backgroundImageView.frame)
        view.translatesAutoresizingMaskIntoConstraints = true
        view.backgroundColor = UIColor.clear
        return view
    }()
    lazy private var backgroundImageView: UIImageView = {
        let imageView = UIImageView(image: self.image)
        imageView.translatesAutoresizingMaskIntoConstraints = true
        imageView.backgroundColor = UIColor.clear
        imageView.layer.minificationFilter = kCAFilterTrilinear
        return imageView
    }()
    lazy private var backgroundImageOverlayView: UIView = {
        let view = UIView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = self.backgroundColor?.withAlphaComponent(0.35)
        view.isHidden = false
        view.isUserInteractionEnabled = false
        return view
    }()
    lazy private var visualEffectView: UIVisualEffectView = {
        let effectView = UIVisualEffectView(effect: self.blurEffect)
        effectView.translatesAutoresizingMaskIntoConstraints = false
        effectView.backgroundColor = UIColor.clear
        effectView.isUserInteractionEnabled = false
//        effectView.isHidden = true
        return effectView
    }()
    lazy private var foregroundContainerView: UIView = {
        let view = UIView(frame: self.foregroundImageView.frame)
        view.translatesAutoresizingMaskIntoConstraints = true
        view.backgroundColor = UIColor.clear
        view.clipsToBounds = true
        view.isUserInteractionEnabled = false
//        view.isHidden = true
        return view
    }()
    lazy private var foregroundImageView: UIImageView = {
        let imageView = UIImageView(image: self.image)
        imageView.translatesAutoresizingMaskIntoConstraints = true
        imageView.backgroundColor = UIColor.clear
        imageView.layer.minificationFilter = kCAFilterTrilinear
        return imageView
    }()
    lazy private var overlayView: WTEditingCropOverlayView = {
        let view = WTEditingCropOverlayView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.clear
        view.isUserInteractionEnabled = false
        return view
    }()
    
    lazy private var rotateButton: UIButton = {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor.clear
        button.setImage(UIImage.rotateImage(), for: .normal)
        button.addTarget(self, action: #selector(rotate), for: .touchUpInside)
        return button
    }()
    
    lazy private var panGestureRecognizer: UIPanGestureRecognizer = {
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panAction(fromSender:)))
        panGestureRecognizer.delegate = self
        return panGestureRecognizer
    }()
    
    lazy private var blurEffect: UIBlurEffect = {
        return UIBlurEffect(style: .dark)
    }()
    
    //    weak var backgroundContainerLeftConstraint: NSLayoutConstraint!
    //    weak var backgroundContainerRightConstraint: NSLayoutConstraint!
    //    weak var backgroundContainerTopConstraint: NSLayoutConstraint!
    //    weak var backgroundContainerBottomConstraint: NSLayoutConstraint!
    
    //    weak var foregroundContainerLeftConstraint: NSLayoutConstraint!
    //    weak var foregroundContainerRightConstraint: NSLayoutConstraint!
    //    weak var foregroundContainerTopConstraint: NSLayoutConstraint!
    //    weak var foregroundContainerBottomConstraint: NSLayoutConstraint!
    //
    //    weak var foregroundLeftConstraint: NSLayoutConstraint!
    //    weak var foregroundRightConstraint: NSLayoutConstraint!
    //    weak var foregroundTopConstraint: NSLayoutConstraint!
    //    weak var foregroundBottomConstraint: NSLayoutConstraint!
    
    //    weak var overlayLeftConstraint: NSLayoutConstraint!
    //    weak var overlayRightConstraint: NSLayoutConstraint!
    //    weak var overlayTopConstraint: NSLayoutConstraint!
    //    weak var overlayBottomConstraint: NSLayoutConstraint!
    
    private var image: UIImage!
    private var originalResult: WTEditingResult?
    lazy private var result: WTEditingResult = {
        let result = WTEditingResult()
        return result
    }()
    
    private var resetTimer: Timer?
    private var tappedEdge: WTEditingCropViewOverlayEdge = .none
    private var cropOriginFrame: CGRect = .zero
    private var panOriginPoint: CGPoint = .zero
    private var cropBoxFrame: CGRect = .zero {
        didSet(newValue) {
//            print("didSet 1:\(cropBoxFrame)")
            if newValue.equalTo(cropBoxFrame) {
                return
            }
            
            if cropBoxFrame.width < CGFloat(Float.ulpOfOne) || cropBoxFrame.height < CGFloat(Float.ulpOfOne) {
                return
            }
            self.foregroundContainerView.frame = cropBoxFrame
//            print("didSet 2: + \(cropBoxFrame)")
//            print("scrollView: + \(scrollView.frame)")
//            print("backgroundContainerView: + \(backgroundContainerView.frame)")
//            print("backgroundImageView: + \(backgroundImageView.frame)")
//            print("foregroundContainerView: + \(foregroundContainerView.frame)")
//            print("foregroundImageView: + \(foregroundImageView.frame)")

            self.scrollView.contentInset = UIEdgeInsetsMake(cropBoxFrame.minY, cropBoxFrame.minX, self.bounds.maxY - cropBoxFrame.maxY, self.bounds.maxX - cropBoxFrame.maxX)
            let imageSize = self.backgroundContainerView.bounds.size
            let scale = max(cropBoxFrame.height / imageSize.height, cropBoxFrame.width / imageSize.width)
            self.scrollView.minimumZoomScale = scale
            
            var size = self.scrollView.contentSize
            size.width = floor(size.width)
            size.height = floor(size.height)
            self.scrollView.contentSize = size
            
            self.scrollView.zoomScale = self.scrollView.zoomScale
            
            matchForegroundToBackground()
        }
    }
    
    @objc private func rotate() {
        rotateImageNinetyDegreesAnimated(true, clockwise: false)
    }
    
    private func applyAngle(_ angle: Int) {
//        print(#function + ":\(angle)")
        var newAngle = angle
        if newAngle % 90 != 0 {
            newAngle = 0
        }
        
        if superview == nil {
            restoreAngle = angle
            return
        }
        
        while labs(self.angle) != labs(newAngle) {
            rotateImageNinetyDegreesAnimated(false, clockwise: false)
        }
    }
    
    private var angle: Int = 0
    private var imageCropframe: CGRect {
        get {
            let imageSize = self.imageSize
            let cropBoxFrame = self.cropBoxFrame
            let contentSize = scrollView.contentSize
            let contentOffset = scrollView.contentOffset
            let contentInset = scrollView.contentInset
            
            var frame = CGRect.zero
            frame.origin.x = floor((contentOffset.x + contentInset.left) * (imageSize.width / contentSize.width))
            frame.origin.x = max(0, frame.minX)
            
            frame.origin.y = floor((contentOffset.y + contentInset.top) * (imageSize.height / contentSize.height))
            frame.origin.y = max(0, frame.minY)
            
            frame.size.width = ceil(cropBoxFrame.width * (imageSize.width / contentSize.width))
            frame.size.width = min(imageSize.width, frame.width)
            
            frame.size.height = ceil(cropBoxFrame.height * (imageSize.height / contentSize.height))
            frame.size.height = min(imageSize.height, frame.height)
            
            return frame
        }
        set {
            if superview == nil {
                restoreImageCropFrame = newValue
                return
            }
            updateToImageCropFrame(newValue)
        }
    }
    private var editing: Bool = false
    private var disableForgroundMatching: Bool = false
    private var rotationContentOffset: CGPoint?
    private var rotationContentSize: CGSize?
    private var rotationBoundSize: CGSize?
    private var applyInitialRotatedAngle: Bool = false
    private var cropBoxLastEditedSize: CGSize = .zero
    private var cropBoxLastEditedAngle: Int = 0
    private var cropBoxLastEditedZoomScale: CGFloat = 0
    private var cropBoxLastEditedMinZoomScale: CGFloat = 0
    private var rotateAnimationInProgress: Bool = false
    private var originalCropBoxSize: CGSize = .zero
    private var originalContentOffset: CGPoint = .zero
    private var canBeReset: Bool = false {
        didSet {
            if canBeReset {
                self.delegate?.editingCropViewDidBecomeResettable(self)
            } else {
                self.delegate?.editingCropViewDidBecomeNonResettable(self)
            }
        }
    }
    private var restoreAngle: Int = 0
    private var restoreImageCropFrame: CGRect = .zero
    private var simpleRenderMode: Bool = false
    
    private var contentBounds: CGRect {
        var rect = CGRect.zero
        rect.origin.x = insets.left + padding
        rect.origin.y = insets.top + padding
        rect.size.width = self.bounds.width - (padding * 2 + insets.left + insets.right)
        rect.size.height = self.bounds.height - (padding * 2 + insets.top + insets.bottom)
        return rect
    }
    private var imageSize: CGSize {
        if angle == -90 || angle == -270 || angle == 90 || angle == 270 {
            return CGSize(width: image.size.height, height: image.size.width)
        }
        return CGSize(width: image.size.width, height: image.size.height)
    }
}

typealias WTEditingCropScrollViewHandler = () -> Void

class WTEditingCropScrollView: UIScrollView {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        touchesBeganHandler?()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        touchesEndedHandler?()
    }
    
    // MARK: - Properties
    
    var touchesBeganHandler: WTEditingCropScrollViewHandler?
    var touchesEndedHandler: WTEditingCropScrollViewHandler?
}

//
//  UIImage+WhatsTaste.swift
//  WTImagePickerController
//
//  Created by Jayce on 2017/3/11.
//  Copyright © 2017年 WhatsTaste. All rights reserved.
//

import UIKit

public extension UIImage {
    func fitSize(_ size: CGSize) -> UIImage {
        guard self.cgImage != nil else {
            return self
        }
        let scale = UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        let context = UIGraphicsGetCurrentContext()
        context?.scaleBy(x: 1, y: -1)
        context?.interpolationQuality = .high
        let rect = CGRect(origin: .zero, size: size)
        context?.draw(self.cgImage!, in: rect, byTiling: true)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        guard image != nil else {
            return self
        }
        UIGraphicsEndImageContext()
        return image!
    }
    
    func hasAlpha() -> Bool {
        if let alphaInfo = self.cgImage?.alphaInfo {
            return alphaInfo == .first || alphaInfo == .last || alphaInfo == .premultipliedFirst || alphaInfo == .premultipliedLast
        }
        return false
    }
    
    func applyingColor(_ color: UIColor) -> UIImage? {
        guard self.cgImage != nil else {
            return nil
        }
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        let context = UIGraphicsGetCurrentContext()
        let bounds = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        context?.scaleBy(x: 1, y: -1)
        context?.translateBy(x: 0, y: -bounds.height)
        context?.saveGState()
        context?.clip(to: bounds, mask: self.cgImage!)
        color.set()
        context?.fill(bounds)
        context?.restoreGState()
        context?.setBlendMode(.multiply)
        context?.draw(self.cgImage!, in: bounds)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    func applyingAlpha(_ alpha: CGFloat) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        draw(at: CGPoint.zero, blendMode: .normal, alpha: alpha)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    func croppingWithFrame(_ frame: CGRect, angle: Int) -> UIImage? {
        var image: UIImage?
        UIGraphicsBeginImageContextWithOptions(frame.size, !self.hasAlpha(), self.scale)
        let context = UIGraphicsGetCurrentContext()
        guard context != nil else {
            return nil
        }
        if angle != 0 {
            let imageView = UIImageView(image: self)
            imageView.layer.minificationFilter = kCAFilterNearest
            imageView.layer.magnificationFilter = kCAFilterNearest
            imageView.transform = CGAffineTransform.identity.rotated(by: CGFloat(Double(angle) * (Double.pi / 180.0)))
            let rect = imageView.bounds.applying(imageView.transform)
            let containerView = UIView(frame: CGRect(origin: .zero, size: rect.size))
            containerView.addSubview(imageView)
            imageView.center = containerView.center
            context!.translateBy(x: -frame.minX, y: -frame.minY)
            containerView.layer.render(in: context!)
        } else {
            context!.translateBy(x: -frame.minX, y: -frame.minY)
            draw(at: .zero)
        }
        image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        guard image != nil && image?.cgImage != nil else {
            return nil
        }
        return UIImage(cgImage: image!.cgImage!, scale: UIScreen.main.scale, orientation: .up)
    }
    
    class func cancelImage() -> UIImage? {
        var image: UIImage?
        
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 16, height: 16), false, 0)
        var path = UIBezierPath()
        path.move(to: CGPoint(x: 15, y: 15))
        path.addLine(to: CGPoint(x: 1, y: 1))
        path.lineWidth = 2
        UIColor.white.setStroke()
        path.stroke()
        
        path = UIBezierPath()
        path.move(to: CGPoint(x: 1, y: 15))
        path.addLine(to: CGPoint(x: 15, y: 1))
        path.lineWidth = 2
        UIColor.white.setStroke()
        path.stroke()
        
        image = UIGraphicsGetImageFromCurrentImageContext()
        return image
    }
    
    class func doneImage() -> UIImage? {
        var image: UIImage?
        
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 17, height: 14), false, 0)
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 1, y: 7))
        path.addLine(to: CGPoint(x: 6, y: 12))
        path.addLine(to: CGPoint(x: 16, y: 1))
        path.lineWidth = 2
        UIColor.white.setStroke()
        path.stroke()
        
        image = UIGraphicsGetImageFromCurrentImageContext()
        return image
    }
    
    class func rotateImage() -> UIImage? {
        var image: UIImage?
        
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 18, height: 21), false, 0)
        var path = UIBezierPath(rect: CGRect(x: 0, y: 9, width: 12, height: 12))
        UIColor.white.setFill()
        path.fill()
        
        path = UIBezierPath()
        path.move(to: CGPoint(x: 5, y: 3))
        path.addLine(to: CGPoint(x: 10, y: 6))
        path.addLine(to: CGPoint(x: 10, y: 0))
        path.addLine(to: CGPoint(x: 5, y: 3))
        path.close()
        UIColor.white.setFill()
        path.fill()
        
        path = UIBezierPath()
        path.move(to: CGPoint(x: 10, y: 3))
        path.addCurve(to: CGPoint(x: 17.5, y: 11), controlPoint1: CGPoint(x: 15, y: 3), controlPoint2: CGPoint(x: 17.5, y: 5.91))
        path.lineWidth = 1
        UIColor.white.setStroke()
        path.stroke()
        
        image = UIGraphicsGetImageFromCurrentImageContext()
        return image
    }
    
    class func resetImage() -> UIImage? {
        var image: UIImage?
        
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 22, height: 18), false, 0)
        
        var path = UIBezierPath()
        path.move(to: CGPoint(x: 22, y: 9))
        path.addCurve(to: CGPoint(x: 13, y: 18), controlPoint1: CGPoint(x: 22, y: 13.97), controlPoint2: CGPoint(x: 17.97, y: 18))
        path.addCurve(to: CGPoint(x: 13, y: 16), controlPoint1: CGPoint(x: 13, y: 17.35), controlPoint2: CGPoint(x: 13, y: 16.68))
        path.addCurve(to: CGPoint(x: 20, y: 9), controlPoint1: CGPoint(x: 16.87, y: 16), controlPoint2: CGPoint(x: 20, y: 12.87))
        path.addCurve(to: CGPoint(x: 13, y: 2), controlPoint1: CGPoint(x: 20, y: 5.13), controlPoint2: CGPoint(x: 16.87, y: 2))
        path.addCurve(to: CGPoint(x: 6.55, y: 6.27), controlPoint1: CGPoint(x: 10.1, y: 2), controlPoint2: CGPoint(x: 7.62, y: 3.76))
        path.addCurve(to: CGPoint(x: 6, y: 9), controlPoint1: CGPoint(x: 6.2, y: 7.11), controlPoint2: CGPoint(x: 6, y: 8.03))
        path.addLine(to: CGPoint(x: 4, y: 9))
        path.addCurve(to: CGPoint(x: 4.65, y: 5.63), controlPoint1: CGPoint(x: 4, y: 7.81), controlPoint2: CGPoint(x: 4.23, y: 6.67))
        path.addCurve(to: CGPoint(x: 7.65, y: 1.76), controlPoint1: CGPoint(x: 5.28, y: 4.08), controlPoint2: CGPoint(x: 6.32, y: 2.74))
        path.addCurve(to: CGPoint(x: 13, y: 0), controlPoint1: CGPoint(x: 9.15, y: 0.65), controlPoint2: CGPoint(x: 11, y: 0))
        path.addCurve(to: CGPoint(x: 22, y: 9), controlPoint1: CGPoint(x: 17.97, y: 0), controlPoint2: CGPoint(x: 22, y: 4.03))
        path.close()
        UIColor.white.setFill()
        path.fill()
        
        path = UIBezierPath()
        path.move(to: CGPoint(x: 5, y: 15))
        path.addLine(to: CGPoint(x: 10, y: 9))
        path.addLine(to: CGPoint(x: 0, y: 9))
        path.addLine(to: CGPoint(x: 5, y: 15))
        path.close()
        UIColor.white.setFill()
        path.fill()
        
        image = UIGraphicsGetImageFromCurrentImageContext()
        return image
    }
}

//
//  WTBadgeView.swift
//  WTImagePickerController
//
//  Created by Jayce on 2017/2/17.
//  Copyright © 2017年 WhatsTaste. All rights reserved.
//

import UIKit

private let badgeNumberMaximum: Int = 99
private let badgeSizeMinimum: CGFloat = 20

class WTBadgeView: UIView {

    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
//        print(#function + "\(rect)")
        super.draw(rect)
        
        if badge.lengthOfBytes(using: .utf8) <= 0 {
            return
        }
        
        let context = UIGraphicsGetCurrentContext()
        let frame = rect
        let arcCenter = CGPoint.init(x: frame.midX, y: frame.midY)
        let radius = frame.width / 2
        let startAngle = -CGFloat(Double.pi / 4)
        let endAngle = CGFloat(2 * Double.pi - Double.pi / 4)
        let clockwise = true
        
        let path = UIBezierPath(arcCenter: arcCenter, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: clockwise)
        context?.saveGState()
        let fillColor = self.tintColor!
        fillColor.setFill()
        path.fill()
        context?.restoreGState()
        
        let attributes = self.attributes ?? defaultAttributes()
        let font: UIFont = attributes[NSAttributedStringKey.font] as! UIFont
//        print(#function + ":\(badge)")
        badge.draw(in: CGRect(origin: CGPoint(x: rect.minX, y: rect.minY + (rect.height - font.pointSize + font.descender) * 0.5), size: rect.size), withAttributes: attributes)
    }
    
    override var intrinsicContentSize: CGSize {
//        print(#function + "\(badge)")
        let attributes = self.attributes ?? defaultAttributes()
        var size = badge.size(withAttributes: attributes)
//        print(#function + "Before:\(size)")
        size.width += insets.left + insets.right
        size.height += insets.top + insets.bottom
        size.width = max(size.width, badgeSizeMinimum)
        size.height = max(size.height, badgeSizeMinimum)
//        size.height = size.width
//        print(#function + "After:\(size)")
        return size
    }
    
    override var tintColor: UIColor! {
        didSet {
            setNeedsDisplay()
        }
    }
    
    // MARK: - Private

    func defaultAttributes() -> [NSAttributedStringKey: Any] {
        return [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 12), NSAttributedStringKey.foregroundColor: UIColor.white, NSAttributedStringKey.paragraphStyle: self.style]
    }
    
    // MARK: - Properties
    
    public var badge: String = String() {
        didSet {
//            print(#function + "Before:\(badge)")
            let badge = Int(self.badge) ?? 0
            if badge == 0 {
                self.badge = String()
            } else if badge > badgeNumberMaximum {
                self.badge = String(badgeNumberMaximum)
//                print(#function + "After:\(badge)")
            }
            invalidateIntrinsicContentSize()
            setNeedsDisplay()
        }
    }
    
    public var attributes: [NSAttributedStringKey : Any]? {
        didSet {
            invalidateIntrinsicContentSize()
            setNeedsDisplay()
        }
    }
    
    public var insets: UIEdgeInsets = UIEdgeInsetsMake(2, 2, 2, 2) {
        didSet {
            invalidateIntrinsicContentSize()
            setNeedsDisplay()
        }
    }
    
    lazy private var style: NSMutableParagraphStyle = {
        let style = NSMutableParagraphStyle()
        style.alignment = .center
        return style
    }()
}

//
//  WTSelectionIndicatorView.swift
//  WTImagePickerController
//
//  Created by Jayce on 2017/2/17.
//  Copyright © 2017年 WhatsTaste. All rights reserved.
//

import UIKit

enum WTSelectionIndicatorViewStyle : Int {
    case none
    case checkmark
    case checkbox
}

class WTSelectionIndicatorView: UIControl {

    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
        super.draw(rect)
        
        switch style {
        case .checkmark:
            let context = UIGraphicsGetCurrentContext()
            
            let bounds = self.bounds.insetBy(dx: insets.left + insets.right, dy: insets.top + insets.bottom)
            let size = bounds.width
            
            var path = UIBezierPath(arcCenter: .init(x: bounds.midX, y: bounds.midY), radius: bounds.width / 2, startAngle: -CGFloat(M_PI / 4), endAngle: CGFloat(2 * M_PI - M_PI / 4), clockwise: true)
            context?.saveGState()
            let tintColor = self.tintColor!
            let fillColor = isSelected ? tintColor : UIColor.clear
            let strokeColor = isSelected ? UIColor.clear : UIColor.white
            fillColor.setFill()
            path.fill()
            context?.restoreGState()
            path.lineWidth = 1
            strokeColor.setStroke()
            path.stroke()
            
            let offsetX = bounds.minX
            let offsetY = bounds.minY
            path = UIBezierPath()
            path.move(to: .init(x: offsetX + size * 0.27083, y: offsetY + size * 0.54167))
            path.addLine(to: .init(x: offsetX + size * 0.41667, y: offsetY + size * 0.68750))
            path.addLine(to: .init(x: offsetX + size * 0.75000, y: offsetY + size * 0.35417))
            path.lineCapStyle = .square
            path.lineWidth = 1.3
            UIColor.white.setStroke()
            path.stroke()
        case .checkbox:
            let context = UIGraphicsGetCurrentContext()
//            context?.saveGState()
//            context?.setFillColor(UIColor.red.cgColor)
//            context?.fill(rect)
//            context?.restoreGState()
            
            let bounds = self.bounds.insetBy(dx: insets.left + insets.right, dy: insets.top + insets.bottom)
            let arcCenter = CGPoint.init(x: bounds.midX, y: bounds.midY)
            let radius = bounds.width / 2
            let startAngle = -CGFloat(M_PI / 4)
            let endAngle = CGFloat(2 * M_PI - M_PI / 4)
            let clockwise = true
            
            var path = UIBezierPath(arcCenter: arcCenter, radius: radius - 2, startAngle: startAngle, endAngle: endAngle, clockwise: clockwise)
            context?.saveGState()
            let tintColor = self.tintColor!
            let fillColor = isSelected ? tintColor : UIColor.clear
            fillColor.setFill()
            path.fill()
            context?.restoreGState()
            
            let strokeColor = UIColor.white
            path = UIBezierPath(arcCenter: arcCenter, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: clockwise)
            path.lineWidth = 1
            strokeColor.setStroke()
            path.stroke()
        default:
            break
        }
        
    }
    
    // MARK: Properties
    
    override var tintColor: UIColor! {
        didSet {
//            print(#file + " [\(#line)]" + " \(#function): " + "\(tintColor)")
            setNeedsDisplay()
        }
    }
    
    override var isSelected: Bool {
        didSet {
            setNeedsDisplay()
        }
    }
    
    public var style: WTSelectionIndicatorViewStyle = .none {
        didSet {
            setNeedsDisplay()
        }
    }
    
    public var insets: UIEdgeInsets = UIEdgeInsetsMake(1, 1, 1, 1) {
        didSet {
            setNeedsDisplay()
        }
    }
}

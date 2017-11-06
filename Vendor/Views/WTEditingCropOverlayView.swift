//
//  WTEditingCropOverlayView.swift
//  WTImagePickerController
//
//  Created by Jayce on 2017/2/9.
//  Copyright © 2017年 WhatsTaste. All rights reserved.
//

import UIKit

private enum WTEditingCropOverlayViewPosition : Int {
    case none
    case top
    case left
    case bottom
    case right
}

private enum WTEditingCropOverlayViewDirection : Int {
    case none
    case horizontal
    case vertical
}

private enum WTEditingCropOverlayViewCornerPosition : Int {
    case none
    case topLeft
    case bottomLeft
    case bottomRight
    case topRight
}

private let outerLineWidth: CGFloat = 1
private let cornerLineWidth: CGFloat = 2
private let cornerLineLength: CGFloat = 20

class WTEditingCropOverlayView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // Initialization code
        self.clipsToBounds = false
        
        for i in 0 ..< outerLineViews.count {
            let view = outerLineViews[i]
            let position = WTEditingCropOverlayViewPosition(rawValue: (i + 1))!
            var insets = UIEdgeInsets.zero
            switch position {
            case .top:
                insets = UIEdgeInsetsMake(-outerLineWidth, -outerLineWidth, 0, -outerLineWidth)
            case .left:
                insets = UIEdgeInsetsMake(0, -outerLineWidth, 0, 0)
            case .bottom:
                insets = UIEdgeInsetsMake(0, -outerLineWidth, -outerLineWidth, -outerLineWidth)
            case .right:
                insets = UIEdgeInsetsMake(0, 0, 0, -outerLineWidth)
            default:
                break
            }
            self.layoutOuterLineView(view, atPosition: position, insets: insets, lineWidth: outerLineWidth)
        }
        
        let cornerLinesViews = [topLeftCornerLineViews, bottomLeftCornerLineViews, bottomRightCornerLineViews, topRightCornerLineViews]
        for i in 0 ..< cornerLinesViews.count {
            let horizontalView = cornerLinesViews[i][0]
            let verticalView = cornerLinesViews[i][1]
            let position = WTEditingCropOverlayViewCornerPosition(rawValue: (i + 1))!
            var horizontalInsets = UIEdgeInsets.zero
            var verticalInsets = UIEdgeInsets.zero
            switch position {
            case .topLeft:
                horizontalInsets = UIEdgeInsetsMake(-(outerLineWidth + cornerLineWidth), -(outerLineWidth + cornerLineWidth), 0, 0)
                verticalInsets = UIEdgeInsetsMake(-outerLineWidth, -(outerLineWidth + cornerLineWidth), 0, 0)
            case .bottomLeft:
                horizontalInsets = UIEdgeInsetsMake(0, -(outerLineWidth + cornerLineWidth), -(outerLineWidth + cornerLineWidth), 0)
                verticalInsets = UIEdgeInsetsMake(0, -(outerLineWidth + cornerLineWidth), -outerLineWidth, 0)
            case .bottomRight:
                horizontalInsets = UIEdgeInsetsMake(0, 0, -(outerLineWidth + cornerLineWidth), -(outerLineWidth + cornerLineWidth))
                verticalInsets = UIEdgeInsetsMake(0, 0, -outerLineWidth, -(outerLineWidth + cornerLineWidth))
            case .topRight:
                horizontalInsets = UIEdgeInsetsMake(-(outerLineWidth + cornerLineWidth), 0, 0, -(outerLineWidth + cornerLineWidth))
                verticalInsets = UIEdgeInsetsMake(-outerLineWidth, 0, 0, -(outerLineWidth + cornerLineWidth))
            default:
                break
            }
            self.layoutCornerLineView(horizontalView, atPosition: position, direction: .horizontal, insets: horizontalInsets)
            self.layoutCornerLineView(verticalView, atPosition: position, direction: .vertical, insets: verticalInsets)
        }
        
        let gridLinesViews = [horizontalGridLines, verticalGridLines]
        for i in 0 ..< gridLinesViews.count {
            let view1 = gridLinesViews[i][0]
            let view2 = gridLinesViews[i][1]
            let direction = WTEditingCropOverlayViewDirection(rawValue: (i + 1))!
            var multiplier1: CGFloat = 1
            var multiplier2: CGFloat = 1
            switch direction {
            case .horizontal:
                multiplier1 = 2 / 3
                multiplier2 = 4 / 3
            case .vertical:
                multiplier1 = 2 / 3
                multiplier2 = 4 / 3
            default:
                break
            }
            self.layoutGridLineView(view1, atDirection: direction, multiplier: multiplier1)
            self.layoutGridLineView(view2, atDirection: direction, multiplier: multiplier2)
        }
        
        defer {
            gridHidden = true
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public
    
    public func setGridHidden(_ hidden: Bool, animated: Bool) {
        gridHidden = hidden
        
        let job = {
            for view in self.horizontalGridLines {
                view.alpha = hidden ? 0 : 1
            }
            for view in self.verticalGridLines {
                view.alpha = hidden ? 0 : 1
            }
        }
        
        if animated {
            UIView.animate(withDuration: 0.3, animations: job)
        } else {
            job()
        }
    }
    
    // MARK: - Private
    
    private func addLineView() -> UIView {
        let view = UIView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.white
        self.addSubview(view)
        return view
    }
    
    private func layoutOuterLineView(_ view: UIView, atPosition position: WTEditingCropOverlayViewPosition, insets: UIEdgeInsets, lineWidth: CGFloat = 1 / UIScreen.main.scale, multiplier: CGFloat = 1) {
        switch position {
        case .top:
            self.addConstraint(NSLayoutConstraint.init(item: view, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1, constant: insets.left))
            self.addConstraint(NSLayoutConstraint.init(item: self, attribute: .right, relatedBy: .equal, toItem: view, attribute: .right, multiplier: 1, constant: insets.right))
            self.addConstraint(NSLayoutConstraint.init(item: view, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: insets.top))
            view.addConstraint(NSLayoutConstraint.init(item: view, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: lineWidth))
        case .left:
            self.addConstraint(NSLayoutConstraint.init(item: view, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1, constant: insets.left))
            self.addConstraint(NSLayoutConstraint.init(item: view, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: insets.top))
            self.addConstraint(NSLayoutConstraint.init(item: self, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: insets.bottom))
            view.addConstraint(NSLayoutConstraint.init(item: view, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: lineWidth))
        case .bottom:
            self.addConstraint(NSLayoutConstraint.init(item: view, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1, constant: insets.left))
            self.addConstraint(NSLayoutConstraint.init(item: self, attribute: .right, relatedBy: .equal, toItem: view, attribute: .right, multiplier: 1, constant: insets.right))
            self.addConstraint(NSLayoutConstraint.init(item: self, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: insets.bottom))
            view.addConstraint(NSLayoutConstraint.init(item: view, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: lineWidth))
        case .right:
            self.addConstraint(NSLayoutConstraint.init(item: self, attribute: .right, relatedBy: .equal, toItem: view, attribute: .right, multiplier: 1, constant: insets.right))
            self.addConstraint(NSLayoutConstraint.init(item: view, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: insets.top))
            self.addConstraint(NSLayoutConstraint.init(item: self, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: insets.bottom))
            view.addConstraint(NSLayoutConstraint.init(item: view, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: lineWidth))
        default:
            break
        }
    }
    
    private func layoutCornerLineView(_ view: UIView, atPosition position: WTEditingCropOverlayViewCornerPosition, direction: WTEditingCropOverlayViewDirection, insets: UIEdgeInsets) {
        switch position {
        case .topLeft:
            switch direction {
            case .horizontal:
                self.addConstraint(NSLayoutConstraint.init(item: view, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1, constant: insets.left))
                self.addConstraint(NSLayoutConstraint.init(item: view, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: insets.top))
                view.addConstraint(NSLayoutConstraint.init(item: view, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: cornerLineLength))
                view.addConstraint(NSLayoutConstraint.init(item: view, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: cornerLineWidth))
            case .vertical:
                self.addConstraint(NSLayoutConstraint.init(item: view, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1, constant: insets.left))
                self.addConstraint(NSLayoutConstraint.init(item: view, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: insets.top))
                view.addConstraint(NSLayoutConstraint.init(item: view, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: cornerLineWidth))
                view.addConstraint(NSLayoutConstraint.init(item: view, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: cornerLineLength))
            default:
                break
            }
        case .bottomLeft:
            switch direction {
            case .horizontal:
                self.addConstraint(NSLayoutConstraint.init(item: view, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1, constant: insets.left))
                self.addConstraint(NSLayoutConstraint.init(item: self, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: insets.bottom))
                view.addConstraint(NSLayoutConstraint.init(item: view, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: cornerLineLength))
                view.addConstraint(NSLayoutConstraint.init(item: view, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: cornerLineWidth))
            case .vertical:
                self.addConstraint(NSLayoutConstraint.init(item: view, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1, constant: insets.left))
                view.addConstraint(NSLayoutConstraint.init(item: view, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: cornerLineWidth))
                self.addConstraint(NSLayoutConstraint.init(item: self, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: insets.bottom))
                view.addConstraint(NSLayoutConstraint.init(item: view, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: cornerLineLength))
            default:
                break
            }
        case .bottomRight:
            switch direction {
            case .horizontal:
                self.addConstraint(NSLayoutConstraint.init(item: self, attribute: .right, relatedBy: .equal, toItem: view, attribute: .right, multiplier: 1, constant: insets.right))
                self.addConstraint(NSLayoutConstraint.init(item: self, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: insets.bottom))
                view.addConstraint(NSLayoutConstraint.init(item: view, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: cornerLineLength))
                view.addConstraint(NSLayoutConstraint.init(item: view, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: cornerLineWidth))
            case .vertical:
                self.addConstraint(NSLayoutConstraint.init(item: self, attribute: .right, relatedBy: .equal, toItem: view, attribute: .right, multiplier: 1, constant: insets.right))
                self.addConstraint(NSLayoutConstraint.init(item: self, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: insets.bottom))
                view.addConstraint(NSLayoutConstraint.init(item: view, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: cornerLineWidth))
                view.addConstraint(NSLayoutConstraint.init(item: view, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: cornerLineLength))
            default:
                break
            }
        case .topRight:
            switch direction {
            case .horizontal:
                self.addConstraint(NSLayoutConstraint.init(item: self, attribute: .right, relatedBy: .equal, toItem: view, attribute: .right, multiplier: 1, constant: insets.right))
                self.addConstraint(NSLayoutConstraint.init(item: view, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: insets.top))
                view.addConstraint(NSLayoutConstraint.init(item: view, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: cornerLineLength))
                view.addConstraint(NSLayoutConstraint.init(item: view, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: cornerLineWidth))
            case .vertical:
                self.addConstraint(NSLayoutConstraint.init(item: self, attribute: .right, relatedBy: .equal, toItem: view, attribute: .right, multiplier: 1, constant: insets.right))
                self.addConstraint(NSLayoutConstraint.init(item: view, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: insets.top))
                view.addConstraint(NSLayoutConstraint.init(item: view, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: cornerLineWidth))
                view.addConstraint(NSLayoutConstraint.init(item: view, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: cornerLineLength))
            default:
                break
            }
        default:
            break
        }
    }
    
    private func layoutGridLineView(_ view: UIView, atDirection direction: WTEditingCropOverlayViewDirection, lineWidth: CGFloat = 1 / UIScreen.main.scale, multiplier: CGFloat) {
        switch direction {
        case .horizontal:
            self.addConstraint(NSLayoutConstraint.init(item: view, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1, constant: 0))
            self.addConstraint(NSLayoutConstraint.init(item: self, attribute: .right, relatedBy: .equal, toItem: view, attribute: .right, multiplier: 1, constant: 0))
            self.addConstraint(NSLayoutConstraint.init(item: view, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: multiplier, constant: 0))
            view.addConstraint(NSLayoutConstraint.init(item: view, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: lineWidth))
        case .vertical:
            self.addConstraint(NSLayoutConstraint.init(item: view, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0))
            self.addConstraint(NSLayoutConstraint.init(item: self, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0))
            self.addConstraint(NSLayoutConstraint.init(item: view, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: multiplier, constant: 0))
            view.addConstraint(NSLayoutConstraint.init(item: view, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: lineWidth))
        default:
            break
        }
    }
    
    // MARK: - Properties
    
    public var gridHidden: Bool = false {
        didSet {
            for view in horizontalGridLines {
                view.alpha = gridHidden ? 0 : 1
            }
            for view in verticalGridLines {
                view.alpha = gridHidden ? 0 : 1
            }
        }
    }
    
    lazy private var outerLineViews: [UIView] = {
        return [self.addLineView(), self.addLineView(), self.addLineView(), self.addLineView()]
    }()
    
    lazy private var topLeftCornerLineViews: [UIView] = {
        return [self.addLineView(), self.addLineView()]
    }()
    lazy private var bottomLeftCornerLineViews: [UIView] = {
        return [self.addLineView(), self.addLineView()]
    }()
    lazy private var bottomRightCornerLineViews: [UIView] = {
        return [self.addLineView(), self.addLineView()]
    }()
    lazy private var topRightCornerLineViews: [UIView] = {
        return [self.addLineView(), self.addLineView()]
    }()
    
    lazy private var horizontalGridLines: [UIView] = {
        return [self.addLineView(), self.addLineView()]
    }()
    lazy private var verticalGridLines: [UIView] = {
        return [self.addLineView(), self.addLineView()]
    }()
}

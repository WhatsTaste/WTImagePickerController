//
//  WTAlbumDetailsCell.swift
//  WTImagePickerController
//
//  Created by Jayce on 2017/2/8.
//  Copyright © 2017年 WhatsTaste. All rights reserved.
//

import UIKit

class WTAlbumDetailsCell: UICollectionViewCell, UIGestureRecognizerDelegate {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // Initialization code
        
        contentView.clipsToBounds = true
        contentView.addSubview(contentImageView)
        contentView.addSubview(indicatorView)
        
        contentView.addConstraint(NSLayoutConstraint.init(item: contentImageView, attribute: .left, relatedBy: .equal, toItem: contentView, attribute: .left, multiplier: 1, constant: 0))
        contentView.addConstraint(NSLayoutConstraint.init(item: contentView, attribute: .right, relatedBy: .equal, toItem: contentImageView, attribute: .right, multiplier: 1, constant: 0))
        contentView.addConstraint(NSLayoutConstraint.init(item: contentImageView, attribute: .top, relatedBy: .equal, toItem: contentView, attribute: .top, multiplier: 1, constant: 0))
        contentView.addConstraint(NSLayoutConstraint.init(item: contentView, attribute: .bottom, relatedBy: .equal, toItem: contentImageView, attribute: .bottom, multiplier: 1, constant: 0))

        contentView.addConstraint(NSLayoutConstraint.init(item: contentImageView, attribute: .right, relatedBy: .equal, toItem: indicatorView, attribute: .right, multiplier: 1, constant: 0))
        contentView.addConstraint(NSLayoutConstraint.init(item: contentImageView, attribute: .bottom, relatedBy: .equal, toItem: indicatorView, attribute: .bottom, multiplier: 1, constant: 0))
        indicatorView.addConstraint(NSLayoutConstraint.init(item: indicatorView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 40))
        indicatorView.addConstraint(NSLayoutConstraint.init(item: indicatorView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 40))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        contentImageView.image = nil
        indicatorView.isSelected = false
    }
    
    override var tintColor: UIColor! {
        didSet {
            indicatorView.tintColor = tintColor
        }
    }
    
    // MARK: - UIGestureRecognizerDelegate
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        let location = touch.location(in: gestureRecognizer.view!)
        return indicatorView.frame.contains(location)
    }
    
    // MARK: - Private
    
    @objc private func selectAction(_ sender: UITapGestureRecognizer) {
        selectHandler?()
    }
    
    // MARK: - Properties
    
    public var representedAssetIdentifier: String!
    
    public var thumbnailImage: UIImage! {
        didSet {
            contentImageView.image = thumbnailImage
            contentImageView.highlightedImage = contentImageView.image?.applyingColor(UIColor.black.withAlphaComponent(0.5))
        }
    }
    
    var selectHandler: (() -> Void)?
    var checked = false {
        didSet {
            self.indicatorView.isSelected = checked
        }
    }
    lazy public private(set) var contentImageView: UIImageView = {
        let imageView = UIImageView(frame: .zero)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = UIColor(white: 0, alpha: 0.05)
        imageView.contentMode = .scaleAspectFill
        imageView.isUserInteractionEnabled = true
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(selectAction(_:)))
        gestureRecognizer.delegate = self
        imageView.addGestureRecognizer(gestureRecognizer)
        
        return imageView
    }()
    
    lazy private var indicatorView: WTSelectionIndicatorView = {
        let view = WTSelectionIndicatorView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.clear
        view.tintColor = self.tintColor
        view.isUserInteractionEnabled = false
        view.style = .checkmark
        view.insets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        return view
    }()
}

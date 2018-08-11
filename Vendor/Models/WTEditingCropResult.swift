//
//  WTEditingResult.swift
//  WTImagePickerController
//
//  Created by Jayce on 2017/3/11.
//  Copyright © 2017年 WhatsTaste. All rights reserved.
//

import UIKit

class WTEditingResult: NSObject {
    var image: UIImage!
    var frame: CGRect = .zero
    var angle: Int = 0
    var zoomScale: CGFloat = 1
    var contentOffset: CGPoint = .zero
}

//
//  ViewController.swift
//  WTImagePickerController
//
//  Created by Jayce on 2017/2/8.
//  Copyright © 2017年 WhatsTaste. All rights reserved.
//

import UIKit

class ViewController: UIViewController, WTImagePickerControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        imageView.contentMode = .scaleAspectFit
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: WTImagePickerControllerDelegate
    
    func imagePickerController(_ picker: WTImagePickerController, didFinishWithImages images: [UIImage]) {
        print(#function + "\(picker)")
//        for image in images {
//            let data = UIImagePNGRepresentation(image)
//            print("\(image.size)" + ": \(Double(data!.count) / 1024 / 1024)")
//        }
        imageView.image = images.last
        picker.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: WTImagePickerController) {
        print(#function + "\(picker)")
        picker.presentingViewController?.dismiss(animated: true, completion: nil)
    }

    // MARK: Private
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBAction func add(_ sender: Any) {
        let destinationViewController = WTImagePickerController(nibName: nil, bundle: nil)
        destinationViewController.delegate = self
//        destinationViewController.tintColor = UIColor.red
        destinationViewController.pickLimit = 9
        self.present(destinationViewController, animated: true, completion: nil)
    }
}


//
//  ViewController.m
//  WTImagePickerController
//
//  Created by Jayce on 2017/3/20.
//  Copyright © 2017年 WhatsTaste. All rights reserved.
//

#import "ViewController.h"

#import "WTImagePickerController-Swift.h"

@interface ViewController () <WTImagePickerControllerDelegate>
    
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
    
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
    
#pragma mark - WTImagePickerControllerDelegate
    
- (void)imagePickerController:(WTImagePickerController * _Nonnull)picker didFinishWithImages:(NSArray<UIImage *> * _Nonnull)images {
    NSLog(@"%s%@", __PRETTY_FUNCTION__, picker);
    self.imageView.image = images.lastObject;
    [picker.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}
    
- (void)imagePickerControllerDidCancel:(WTImagePickerController * _Nonnull)picker {
    NSLog(@"%s%@", __PRETTY_FUNCTION__, picker);
    [picker.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}
    
- (IBAction)add:(id)sender {
    WTImagePickerController *destinationViewController = [[WTImagePickerController alloc] initWithNibName:nil bundle:nil];
    destinationViewController.delegate = self;
    destinationViewController.pickLimit = 9;
    [self presentViewController:destinationViewController animated:YES completion:nil];
}

@end

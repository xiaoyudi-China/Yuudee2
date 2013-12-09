//
//  HAMImageCropperViewController.h
//  iosapp
//
//  Created by 张 磊 on 13-11-28.
//  Copyright (c) 2013年 Droplings. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HAMImageCropperViewController;

@protocol HAMImageCropperViewControllerDelegate <NSObject>

- (void)imageCropper:(HAMImageCropperViewController*)imageCropper didFinishCroppingWithImage:(UIImage*)croppedImage;

@end


@interface HAMImageCropperViewController : UIViewController <UIScrollViewDelegate>

@property UIImage *image;
@property (weak, nonatomic) id<HAMImageCropperViewControllerDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIView *topCoverView;

- (IBAction)cancelButtonPressed:(id)sender;
- (IBAction)confirmButtonPressed:(id)sender;

@end

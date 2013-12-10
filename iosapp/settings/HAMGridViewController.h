//
//  HAMGridViewController.h
//  iosapp
//
//  Created by 张 磊 on 13-12-3.
//  Copyright (c) 2013年 Droplings. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HAMGridViewController : UIViewController 

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIButton *rightTopButton;
@property (weak, nonatomic) IBOutlet UIButton *bottomButton;

- (IBAction)leftTopButtonPressed:(id)sender;
- (IBAction)rightTopButtonPressed:(id)sender;
- (IBAction)bottomButtonPressed:(id)sender;

@end

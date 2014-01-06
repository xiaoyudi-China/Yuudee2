//
//  HAMCoverPickerViewController.h
//  iosapp
//
//  Created by 张 磊 on 14-1-6.
//  Copyright (c) 2014年 Droplings. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HAMConfig.h"

@class HAMCoverPickerViewController;
@protocol HAMCoverPickerDelegate <NSObject>

- (void)coverPickerDidPickImage:(UIImage*)image;

@end

@interface HAMCoverPickerViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate>

@property (weak, nonatomic) HAMConfig *config;
@property (weak, nonatomic) NSString *categoryID;
@property (strong, nonatomic) NSMutableArray *images;
@property (weak, nonatomic) id<HAMCoverPickerDelegate> delegate;

@end

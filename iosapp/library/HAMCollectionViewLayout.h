//
//  HAMCollectionViewLayout.h
//  iosapp
//
//  Created by 张 磊 on 14-3-5.
//  Copyright (c) 2014年 Droplings. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HAMCollectionViewLayout : UICollectionViewFlowLayout

@property (strong, nonatomic) NSMutableArray *attributes;
@property NSInteger numItems;

@end

//
//  HAMSharedData.h
//  iosapp
//
//  Created by 张 磊 on 14-1-3.
//  Copyright (c) 2014年 Droplings. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HAMFileTools.h"

@interface HAMSharedData : NSObject

@property (strong, nonatomic) NSCache *imageCache;

+ (id)sharedData;
+ (UIImage*)imageNamed:(NSString*)imageName;
+ (void)updateImageNamed:(NSString*)imageName withImage:(UIImage*)image;

@end

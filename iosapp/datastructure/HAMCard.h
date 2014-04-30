//
//  HAMCard.h
//  iosapp
//
//  Created by daiyue on 13-7-29.
//  Copyright (c) 2013年 Droplings. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
	HAMCardTypeCategory = 0,
	HAMCardTypeCard = 1
} HAMCardType;

@interface HAMCard : NSObject

@property (nonatomic) NSString* ID;
@property (nonatomic) NSString *imagePath;
@property (nonatomic) NSString *audioPath;
@property (nonatomic) HAMCardType type;
@property (nonatomic) NSString *name;
@property (nonatomic) int numImages;
@property (nonatomic) BOOL removable;

- (id)initCard;
- (id)initCategory;

@end

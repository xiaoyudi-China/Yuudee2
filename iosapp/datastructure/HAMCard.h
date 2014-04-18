//
//  HAMCard.h
//  iosapp
//
//  Created by daiyue on 13-7-29.
//  Copyright (c) 2013年 Droplings. All rights reserved.
//

#import <Foundation/Foundation.h>

#define CARD_TYPE_CATEGORY 0
#define CARD_TYPE_CARD 1

typedef enum {
	HAMCardTypeCategory = 0,
	HAMCardTypeCard = 1
} HAMCardType;

@interface HAMCard : NSObject
{}

@property NSString* cardID;
@property HAMCardType type;
@property NSString *name;
@property (nonatomic) NSString *imagePath;
@property (nonatomic) NSString *audioPath;
@property int numImages;
@property BOOL removable;

- (id)initCard;
- (id)initCategory;

@end

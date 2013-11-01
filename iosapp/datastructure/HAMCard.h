//
//  HAMCard.h
//  iosapp
//
//  Created by daiyue on 13-7-29.
//  Copyright (c) 2013年 Droplings. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HAMResource.h"

#define CARD_TYPE_CATEGORY 0
#define CARD_TYPE_CARD 1

@interface HAMCard : NSObject
{
}

@property NSString* UUID;
// 0 - cat 1 - card
@property int type;
@property NSString* name;
@property HAMResource* image;
@property HAMResource* audio;

-(id)initWithID:(NSString*)_UUID;
-(id)initNewCard;

@end

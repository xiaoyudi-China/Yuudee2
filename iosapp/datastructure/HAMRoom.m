//
//  HAMCardContainer.m
//  iosapp
//
//  Created by Dai Yue on 13-11-9.
//  Copyright (c) 2013年 Droplings. All rights reserved.
//

#import "HAMRoom.h"

@implementation HAMRoom
{
}

@synthesize cardID_;
@synthesize animation_;

-(HAMRoom*)initWithCardID:(NSString*)cardID animation:(int)animation{
    if (self = [super init]) {
        cardID_ = cardID;
        animation_ = animation;
    }
    return self;
}

@end

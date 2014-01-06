//
//  HAMCard.m
//  iosapp
//
//  Created by daiyue on 13-7-29.
//  Copyright (c) 2013年 Droplings. All rights reserved.
//

#import "HAMCard.h"

@implementation HAMCard

@synthesize UUID;
@synthesize type;
@synthesize name;
@synthesize image;
@synthesize audio;
@synthesize imageNum_;
@synthesize isRemovable_;

-(id)initWithID:(NSString *)_UUID
{
    if (self=[super init])
        UUID=_UUID;
    return self;
}

-(id)initNewCard
{
    if (self=[super  init])
    {
        CFUUIDRef uuidRef = CFUUIDCreate(kCFAllocatorDefault);
        UUID = CFBridgingRelease(CFUUIDCreateString (kCFAllocatorDefault,uuidRef));
    }
    return self;
}

@end

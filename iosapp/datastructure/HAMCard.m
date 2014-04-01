//
//  HAMCard.m
//  iosapp
//
//  Created by daiyue on 13-7-29.
//  Copyright (c) 2013年 Droplings. All rights reserved.
//

#import "HAMCard.h"

@implementation HAMCard

-(id)initWithID:(NSString *)UUID
{
    if (self=[super init])
        self.UUID = UUID;
    return self;
}

-(id)initNewCard
{
    if (self=[super  init])
    {
        CFUUIDRef uuidRef = CFUUIDCreate(kCFAllocatorDefault);
        self.UUID = CFBridgingRelease(CFUUIDCreateString (kCFAllocatorDefault,uuidRef));
		CFRelease(uuidRef);
    }
    return self;
}

@end

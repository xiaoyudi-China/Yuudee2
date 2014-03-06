//
//  HAMUser.m
//  iosapp
//
//  Created by daiyue on 13-8-12.
//  Copyright (c) 2013年 Droplings. All rights reserved.
//

#import "HAMUser.h"

@implementation HAMUser

-(id)initWithName:(NSString *)name
{
    if (self =[super init])
    {
        self.name = [[NSString alloc] initWithString:name];
        CFUUIDRef uuidRef = CFUUIDCreate(kCFAllocatorDefault);
        self.UUID = CFBridgingRelease(CFUUIDCreateString (kCFAllocatorDefault,uuidRef));
		CFRelease(uuidRef);
        
		uuidRef = CFUUIDCreate(kCFAllocatorDefault);
        self.rootID = CFBridgingRelease(CFUUIDCreateString (kCFAllocatorDefault,uuidRef));
		CFRelease(uuidRef);
        
        self.layoutx = USER_DEFAULT_LAYOUTX;
        self.layouty = USER_DEFAULT_LAYOUTY;
		
		self.mute = NO;
    }
    return self;
}

@end

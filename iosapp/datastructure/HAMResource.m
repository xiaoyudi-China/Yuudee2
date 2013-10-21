//
//  HAMResource.m
//  iosapp
//
//  Created by daiyue on 13-7-29.
//  Copyright (c) 2013年 Droplings. All rights reserved.
//

#import "HAMResource.h"

@implementation HAMResource

@synthesize UUID;
@synthesize localPath;

-(id)initWithPath:(NSString*)path
{
    if (self=[super init])
    {
        localPath=path;
        CFUUIDRef uuidRef = CFUUIDCreate(kCFAllocatorDefault);
        UUID = CFBridgingRelease(CFUUIDCreateString (kCFAllocatorDefault,uuidRef));
    }
    return self;
}

@end

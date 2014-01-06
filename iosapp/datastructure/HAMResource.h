//
//  HAMResource.h
//  iosapp
//
//  Created by daiyue on 13-7-29.
//  Copyright (c) 2013年 Droplings. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HAMSharedData.h"

@interface HAMResource : NSObject
{}

@property NSString* UUID;
@property NSString* localPath;

-(id)initWithPath:(NSString*)path;
@end

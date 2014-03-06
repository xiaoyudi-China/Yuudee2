//
//  HAMUser.h
//  iosapp
//
//  Created by daiyue on 13-8-12.
//  Copyright (c) 2013年 Droplings. All rights reserved.
//

#import <Foundation/Foundation.h>

#define USER_DEFAULT_LAYOUTX 2
#define USER_DEFAULT_LAYOUTY 2

@interface HAMUser : NSObject
{
}

@property NSString* UUID;
@property NSString* name;
@property NSString* rootID;
@property BOOL mute;

@property int layoutx;
@property int layouty;

-(id)initWithName:(NSString*)_name;

@end
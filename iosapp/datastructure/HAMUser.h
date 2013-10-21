//
//  HAMUser.h
//  iosapp
//
//  Created by daiyue on 13-8-12.
//  Copyright (c) 2013年 Droplings. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HAMUser : NSObject
{
}

@property NSString* UUID;
@property NSString* name;
@property NSString* rootID;

@property int layoutx;
@property int layouty;

-(id)initWithName:(NSString*)_name;

@end
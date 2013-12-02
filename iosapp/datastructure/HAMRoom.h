//
//  HAMCardContainer.h
//  iosapp
//
//  Created by Dai Yue on 13-11-9.
//  Copyright (c) 2013年 Droplings. All rights reserved.
//

#import <Foundation/Foundation.h>

#define ROOM_ANIMATION_SCALE 1
#define ROOM_ANIMATION_SHAKE 2
#define ROOM_ANIMATION_NONE 0

@interface HAMRoom : NSObject
{}

@property NSString* cardID_;
@property int animation_;

-(HAMRoom*)initWithCardID:(NSString*)cardID animation:(int)animation;
-(Boolean)isEqualToRoom:(HAMRoom*)aRoom;

@end

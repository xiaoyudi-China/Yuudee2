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

typedef enum {
	HAMAnimationTypeNone = 0,
	HAMAnimationTypeScale = 1,
	HAMAnimationTypeShake = 2
} HAMAnimationType;

@interface HAMRoom : NSObject
{}

@property NSString* cardID;
@property HAMAnimationType animation;

-(HAMRoom*)initWithCardID:(NSString*)cardID animation:(HAMAnimationType)animation;
-(Boolean)isEqualToRoom:(HAMRoom*)aRoom;

@end

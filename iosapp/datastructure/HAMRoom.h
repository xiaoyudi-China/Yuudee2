//
//  HAMCardContainer.h
//  iosapp
//
//  Created by Dai Yue on 13-11-9.
//  Copyright (c) 2013年 Droplings. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
	HAMAnimationTypeNone = 0,
	HAMAnimationTypeScale = 1,
	HAMAnimationTypeShake = 2
} HAMAnimationType;

@interface HAMRoom : NSObject

@property NSString* cardID;
@property HAMAnimationType animation;
@property BOOL mute;

-(HAMRoom*)initWithCardID:(NSString*)cardID animation:(HAMAnimationType)animation muteState:(BOOL)mute;
-(Boolean)isEqualToRoom:(HAMRoom*)aRoom;

@end

//
//  HAMCardContainer.m
//  iosapp
//
//  Created by Dai Yue on 13-11-9.
//  Copyright (c) 2013年 Droplings. All rights reserved.
//

#import "HAMRoom.h"

@implementation HAMRoom
{}


-(HAMRoom*)initWithCardID:(NSString*)cardID animation:(HAMAnimationType)animation muteState:(BOOL)mute {
    if (self = [super init]) {
        self.cardID = cardID;
        self.animation = animation;
		self.mute = mute;
    }
    return self;
}

-(Boolean)isEqualToRoom:(HAMRoom*)aRoom
{
    return (self.cardID == aRoom.cardID && self.animation == aRoom.animation);
}

@end

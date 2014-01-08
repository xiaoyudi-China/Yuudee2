//
//  HAMAnimation.h
//  iosapp
//
//  Created by Dai Yue on 13-11-16.
//  Copyright (c) 2013年 Droplings. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HAMRoom.h"
#import "HAMCard.h"
@class HAMCardView;

@protocol HAMGifAnimationDelegate

- (void)changeGifImageToPicNum:(int)picNum;
- (void)endGif;

@end

@interface HAMAnimation : NSObject
{
    
}


@property id<HAMGifAnimationDelegate> gifDelegate_;

- (void)setCard:(HAMCard*)card andCardView:(HAMCardView*)cardView;

- (void)beginAnimation:(int)animationType;
- (Boolean)isRunning;

- (void)playGifWithTimeInterval:(double)interval totalPicNum:(int)totalnum;

@end

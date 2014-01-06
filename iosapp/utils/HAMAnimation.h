//
//  HAMAnimation.h
//  iosapp
//
//  Created by Dai Yue on 13-11-16.
//  Copyright (c) 2013年 Droplings. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HAMRoom.h"
#import "HAMCardView.h"
#import "HAMCard.h"

@interface HAMAnimation : NSObject
{
    
}

- (void)setCard:(HAMCard*)card andCardView:(HAMCardView*)cardView;

- (void)beginAnimation:(int)animationType;
- (Boolean)isRunning;

@end

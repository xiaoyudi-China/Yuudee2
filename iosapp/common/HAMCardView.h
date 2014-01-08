//
//  HAMCardView.h
//  iosapp
//
//  Created by Dai Yue on 13-12-26.
//  Copyright (c) 2013年 Droplings. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HAMViewInfo.h"
#import "HAMCard.h"
#import "HAMFileTools.h"
#import "HAMAnimation.h"

@class HAMAnimation;

@interface HAMCardView : UIView<HAMGifAnimationDelegate>
{}

- (id)initAtPosition:(CGPoint)position withViewInfo:(HAMViewInfo*)viewInfo card:(HAMCard*)card;

@end

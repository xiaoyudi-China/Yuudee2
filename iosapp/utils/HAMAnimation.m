//
//  HAMAnimation.m
//  iosapp
//
//  Created by Dai Yue on 13-11-16.
//  Copyright (c) 2013年 Droplings. All rights reserved.
//

#import "HAMAnimation.h"

#import "QBAnimationSequence.h"
#import "QBAnimationGroup.h"
#import "QBAnimationItem.h"
#import "HAMCardView.h"

#define SCALE_SIZE 500
@class HAMCardView;

@implementation HAMAnimation
{
    QBAnimationSequence *sequence_;
    
    NSTimer* gifTimer_;
    int gifTotalNum_;
    int gifCurrentNum_;
    
    HAMCard* card_;
    HAMCardView* cardView_;
}

@synthesize gifDelegate_;

- (void)setCard:(HAMCard*)card andCardView:(HAMCardView*)cardView{
    card_ = card;
    cardView_ = cardView;
}

- (void)beginAnimation:(int)animationType{
    
    UIView* superView = cardView_.superview;
    [superView bringSubviewToFront:cardView_];
    
    CGRect originFrame = cardView_.frame;
    double scale = SCALE_SIZE / originFrame.size.width;
    
    QBAnimationGroup *groupScaleBig = [QBAnimationGroup groupWithItem:[QBAnimationItem itemWithDuration:1.0 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        CGPoint pageCenter = CGPointMake(768 / 2, 1024 / 2);
        cardView_.center = pageCenter;
        cardView_.transform = CGAffineTransformMakeScale(scale, scale);
    }]];
    QBAnimationGroup *groupScaleNom = [QBAnimationGroup groupWithItem:[QBAnimationItem itemWithDuration:1.0 delay:card_.imageNum_ options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [self playGifOnCardView];
        cardView_.transform = CGAffineTransformMakeScale(1, 1);
        cardView_.frame = originFrame;
    }]];
    QBAnimationGroup *groupRotateLeftHalf = [QBAnimationGroup groupWithItem:[QBAnimationItem itemWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        cardView_.transform = CGAffineTransformRotate(cardView_.transform, M_PI/8);
    }]];
    QBAnimationGroup *groupRotateRightHalf = [QBAnimationGroup groupWithItem:[QBAnimationItem itemWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        cardView_.transform = CGAffineTransformRotate(cardView_.transform, -M_PI/8);
    }]];
    QBAnimationGroup *groupRotateLeft = [QBAnimationGroup groupWithItem:[QBAnimationItem itemWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        cardView_.transform = CGAffineTransformRotate(cardView_.transform, M_PI/4);
    }]];
    QBAnimationGroup *groupRotateRight = [QBAnimationGroup groupWithItem:[QBAnimationItem itemWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        cardView_.transform = CGAffineTransformRotate(cardView_.transform, -M_PI/4);
    }]];
    
    switch (animationType) {
        case ROOM_ANIMATION_NONE:
            [self playGifOnCardView];
            return;
            
        case ROOM_ANIMATION_SCALE:
            sequence_ = [[QBAnimationSequence alloc] initWithAnimationGroups:@[groupScaleBig, groupScaleNom] repeat:NO];
            [sequence_ start];
            break;
            
        case ROOM_ANIMATION_SHAKE:
            sequence_ = [[QBAnimationSequence alloc] initWithAnimationGroups:@[groupScaleBig, groupRotateRightHalf, groupRotateLeft, groupRotateRight, groupRotateLeftHalf, groupScaleNom] repeat:NO];
            [sequence_ start];
            break;
            
        default:
            break;
    }
    
    /*CABasicAnimation *pulseAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
     [pulseAnimation setDuration:1];
     [pulseAnimation setRepeatCount:1];
     
     [pulseAnimation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
     
     CATransform3D transform = CATransform3DMakeScale(3.5, 3.5, 1.0);
     
     [pulseAnimation setToValue:[NSValue valueWithCATransform3D:CATransform3DIdentity]];
     [pulseAnimation setToValue:[NSValue valueWithCATransform3D:transform]];
     
     // Tells CA to reverse the animation (e.g. animate back to the layer's transform)
     [pulseAnimation setAutoreverses:YES];
     
     CABasicAnimation *translation = [CABasicAnimation animationWithKeyPath:@"position"];
     translation.toValue = [NSValue valueWithCGPoint:CGPointMake(384, 512)];
     [translation setDuration:1];
     [translation setRepeatCount:1];
     [translation setAutoreverses:YES];
     
     // Finally... add the explicit animation to the layer... the animation automatically starts.
     [highlightLayer addAnimation:pulseAnimation forKey:@"pulse"];
     [highlightLayer addAnimation:translation forKey:@"translation"];*/
}

- (void)playGifOnCardView{
    if (card_.imageNum_ <= 1) {
        return;
    }
    
    gifDelegate_ = cardView_;
    
    [self playGifWithTimeInterval:1.0f totalPicNum:card_.imageNum_];
}

- (void)playGifWithTimeInterval:(double)interval totalPicNum:(int)totalnum{
    gifCurrentNum_ = 1;
    gifTotalNum_ = totalnum;
    
    if (gifTimer_ == nil) {
        gifTimer_ = [NSTimer scheduledTimerWithTimeInterval:interval target:self selector:@selector(changeGifPic) userInfo:nil repeats:YES];
        [gifTimer_ setFireDate:[NSDate distantFuture]];
    }
    [gifTimer_ setFireDate:[NSDate date]];
}

- (void)changeGifPic{
    
    if (++gifCurrentNum_ > gifTotalNum_){
        [gifTimer_ setFireDate:[NSDate distantFuture]];
        [gifDelegate_ endGif];
        return;
    }
    
    if (gifCurrentNum_ == 1) {
        return;
    }
    
    [gifDelegate_ changeGifImageToPicNum:gifCurrentNum_];
}

- (Boolean)isRunning{
    return sequence_.running;
}


@end

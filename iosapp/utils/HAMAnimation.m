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

#define SCALE_SIZE 500

@implementation HAMAnimation

+ (void)beginAnimation:(int)animationType onCardView:(UIView*)cardView
{
    UIView* superView = cardView.superview;
    [superView bringSubviewToFront:cardView];
    
    CGRect originFrame = cardView.frame;
    double scale = SCALE_SIZE / originFrame.size.width;
//    double scalex = (768 - SCALE_SIZE) / 2;
//    double scaley = (1024 - SCALE_SIZE) / 2;
    
    QBAnimationGroup *group1 = [QBAnimationGroup groupWithItem:[QBAnimationItem itemWithDuration:1.0 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        CGPoint pageCenter = CGPointMake(768 / 2, 1024 / 2);
        cardView.center = pageCenter;
        cardView.transform = CGAffineTransformMakeScale(scale, scale);
        //highlightLayer.transform = CATransform3DMakeScale(3.5, 3.5, 1.0);
        //translation.toValue = [NSValue valueWithCGPoint:CGPointMake(384, 512)];
        //highlightLayer.frame = CGRectMake(100, 200, 1000, 1000);
    }]];
    QBAnimationGroup *group2 = [QBAnimationGroup groupWithItem:[QBAnimationItem itemWithDuration:1.0 delay:1.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        cardView.transform = CGAffineTransformMakeScale(1, 1);
        cardView.frame = originFrame;
    }]];
    
    QBAnimationSequence* sequence;
    
    switch (animationType) {
        case ROOM_ANIMATION_NONE:
            return;
            
        case ROOM_ANIMATION_SCALE:
            sequence = [[QBAnimationSequence alloc] initWithAnimationGroups:@[group1, group2] repeat:NO];
            [sequence start];
            break;
            
        case ROOM_ANIMATION_SHAKE:
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


@end

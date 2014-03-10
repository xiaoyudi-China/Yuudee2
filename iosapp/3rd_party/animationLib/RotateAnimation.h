//
//  RotateAnimation.h
//  Layer
//
//  Created by  on 12-8-23.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

//定义三个圆
enum
{
    firstArc = 1,
    secondArc,
    thirdArc,
};

@interface RotateAnimation : UIView
{
    UIImageView *circleView1;
    UIImageView *circleView2;
    UIImageView *circleView3;
}
//由于此动画是圆形, 传入的frame需要设置成正方形
- (id)initWithFrame:(CGRect)frame;
-(void)setRotateAnimationBackgroundColor:(UIColor *)aColor;
@end

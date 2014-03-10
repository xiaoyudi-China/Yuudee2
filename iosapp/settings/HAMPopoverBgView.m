//
//  HAMPopoverBgView.m
//  iosapp
//
//  Created by Dai Yue on 13-12-5.
//  Copyright (c) 2013年 Droplings. All rights reserved.
//

#import "HAMPopoverBgView.h"

#define ArrowBase 0.0f
#define ArrowHeight 0.0f
#define BorderInset 0.0f

@implementation HAMPopoverBgView

@synthesize arrowDirection  = _arrowDirection;
@synthesize arrowOffset     = _arrowOffset;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

+ (CGFloat)arrowBase
{
    return ArrowBase;
}
+ (CGFloat)arrowHeight
{
    return ArrowHeight;
}
+ (UIEdgeInsets)contentViewInsets
{
    return UIEdgeInsetsMake(BorderInset, BorderInset, BorderInset,       BorderInset);
}
+ (BOOL)wantsDefaultContentAppearance
{
    return NO;
}

@end

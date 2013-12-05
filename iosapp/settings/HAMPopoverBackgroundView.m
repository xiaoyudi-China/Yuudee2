//
//  PopoverBackgroundView.m
//  CustomPopover
//
//  Created by Aaron Crabtree on 3/25/13.
//  Copyright (c) 2013 Tap Dezign. All rights reserved.
//

#import "HAMPopoverBackgroundView.h"

@interface HAMPopoverBackgroundView()
@end


@implementation HAMPopoverBackgroundView

// TODO: understand this !!!
@synthesize arrowDirection  = _arrowDirection;
@synthesize arrowOffset     = _arrowOffset;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
		self.layer.shadowColor = [UIColor clearColor].CGColor; // remove the shadow
    }
    return self;
}

+ (CGFloat)arrowBase
{
    return 0.0;
}

+ (CGFloat)arrowHeight
{
    return 0.0;
}

+ (UIEdgeInsets)contentViewInsets
{
    return UIEdgeInsetsZero;
}

+ (BOOL)wantsDefaultContentAppearance {
	return NO;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
}

@end

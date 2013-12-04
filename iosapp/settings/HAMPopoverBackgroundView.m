//
//  HAMPopoverBackgroundView.m
//  iosapp
//
//  Created by 张 磊 on 13-12-4.
//  Copyright (c) 2013年 Droplings. All rights reserved.
//

#import "HAMPopoverBackgroundView.h"

@implementation HAMPopoverBackgroundView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
		self.imageView = [[UIImageView alloc] init];
		self.imageView.alpha = 0.0;
		
		[self addSubview:self.imageView];
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

- (void)layoutSubviews {
	self.imageView.frame = (CGRect){CGPointZero, self.frame.size};
}

+ (CGFloat)arrowBase {
	return 0.0;
}

+ (CGFloat)arrowHeight {
	return 0.0;
}

+ (UIEdgeInsets)contentViewInsets {
	return UIEdgeInsetsZero;
}

+ (BOOL)wantsDefaultContentAppearance {
	return NO;
}

@end

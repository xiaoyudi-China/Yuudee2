//
//  HAMGridCell.m
//  iosapp
//
//  Created by 张 磊 on 13-10-24.
//  Copyright (c) 2013年 Droplings. All rights reserved.
//

#import "HAMGridCell.h"

@implementation HAMGridCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        NSArray *arrayOfViews = [[NSBundle mainBundle] loadNibNamed:@"HAMGridCell" owner:self options:nil];
        self = [arrayOfViews objectAtIndex:0];
		
	}
    return self;
}

- (IBAction)rightTopButtonPressed:(id)sender {
	[self.delegate rightTopButtonPressedForCell:self];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end

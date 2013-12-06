//
//  HAMViewTool.m
//  iosapp
//
//  Created by daiyue on 13-7-24.
//  Copyright (c) 2013年 Droplings. All rights reserved.
//

#import "HAMViewTool.h"

@implementation HAMViewTool

+(void)showAlert:(NSString*)text{
    UIAlertView* alert = [[UIAlertView alloc]
                          initWithTitle:@"提示"
                          message:text
                          delegate:self
                          cancelButtonTitle:@"确定"
                          otherButtonTitles:nil];
    [alert show];
}

+(void)setHighLightImage:(NSString*)imageName forButton:(UIButton*)button{
    UIImage *highLightImage = [UIImage imageNamed:imageName];
    [button setImage:highLightImage forState:UIControlStateHighlighted];
}

@end

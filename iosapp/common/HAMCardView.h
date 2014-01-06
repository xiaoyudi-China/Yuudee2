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

@interface HAMCardView : UIView
{}

- (id)initAtPosition:(CGPoint)position withViewInfo:(HAMViewInfo*)viewInfo card:(HAMCard*)card;
//- (void)changeCardImagePathToPath:(NSString*)newImagePath;
- (void)changeCardImageToPicNum:(int)picNum;

@end

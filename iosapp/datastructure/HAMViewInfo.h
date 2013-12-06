//
//  HAMViewInfo.h
//  iosapp
//
//  Created by daiyue on 13-7-24.
//  Copyright (c) 2013年 Droplings. All rights reserved.
//

#import <Foundation/Foundation.h>

#define VIEWINFO_LAYOUT_1x1 1
#define VIEWINFO_LAYOUT_2x2 2
#define VIEWINFO_LAYOUT_3x3 3
#define VIEWINFO_MAXCARDNUM 25

@interface HAMViewInfo : NSObject
{
    double minspace;
    double maxx;
    double maxy;
    CGPoint cardPos[VIEWINFO_MAXCARDNUM];
}

@property int xnum_;
@property int ynum_;
@property double cardWidth;
@property double cardHeight;

@property double fontSize;
@property double catLableY;
@property double cardLableY;

@property double picOffsetX;
@property double picOffsetY;
@property double picWidth;
@property double picHeight;

@property CGPoint editBtnOffset;
@property double editBtnWidth;
@property double editBtnHeight;

@property double blankBtnWidth;
@property double blankBtnHeight;
@property CGPoint blankBtnOffset;

//-(id)initWithframe:(CGRect)frame xnum:(int)_xnum ynum:(int)_ynum h:(double)_h minspace:(double)_minspace;
-(id)initWithXnum:(int)xnum ynum:(int)ynum;

-(CGPoint)cardPositionAtIndex:(int)index;

+(double)maxx;
+(double)maxy;

@end

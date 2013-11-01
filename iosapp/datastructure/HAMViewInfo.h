//
//  HAMViewInfo.h
//  iosapp
//
//  Created by daiyue on 13-7-24.
//  Copyright (c) 2013年 Droplings. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HAMViewInfo : NSObject
{
    double minspace;
    double maxx;
    double maxy;
}

@property int xnum;
@property int ynum;
@property double a;
@property double h;
@property double xSpace;
@property double ySpace;

@property double wordh;

@property double picOffsetX;
@property double picOffsetY;
@property double picWidth;
@property double picHeight;

-(id)initWithframe:(CGRect)frame xnum:(int)_xnum ynum:(int)_ynum h:(double)_h minspace:(double)_minspace;
-(void)updateInfoWithxnum:(int)_xnum ynum:(int)_ynum;

-(CGPoint)positionAtPosIndex:(int)index;

+(double)maxx;
+(double)maxy;

@end

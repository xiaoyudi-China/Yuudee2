//
//  HAMViewInfo.m
//  iosapp
//
//  Created by daiyue on 13-7-24.
//  Copyright (c) 2013年 Droplings. All rights reserved.
//

#import "HAMViewInfo.h"

@implementation HAMViewInfo

@synthesize xnum;
@synthesize ynum;
@synthesize a;
@synthesize h;
@synthesize xSpace;
@synthesize ySpace;
@synthesize picOffsetX;
@synthesize picOffsetY;
@synthesize picHeight;
@synthesize picWidth;
@synthesize wordh;

-(id)initWithframe:(CGRect)frame xnum:(int)_xnum ynum:(int)_ynum h:(double)_h minspace:(double)_minspace
{
    if (self=[super init]){
        xnum=_xnum;
        ynum=_ynum;
        //h=_h;
        
        //CGRect rect=[[UIScreen mainScreen]bounds];
        //CGRect recttab=[[UIApplication sharedApplication] statusBarFrame];
        maxx=frame.size.width;
        maxy=frame.size.height;
        
        minspace=_minspace;
        
        [self updateInfo];
    }
    return self;
}

-(void)updateInfoWithxnum:(int)_xnum ynum:(int)_ynum
{
    xnum=_xnum;
    ynum=_ynum;
    [self updateInfo];
}

-(void)updateInfo
{
    double a1=(maxx-(xnum+1)*minspace)/xnum;
    double a2=(maxy-(ynum+2)*minspace)/ynum-h;
    a=MIN(a1, a2);
    
    xSpace=(maxx-xnum*a)/(xnum+1);
    ySpace=(maxy-ynum*(a+h))/(ynum+1);
    
    //temp calculations
    h=0;
    wordh=a*0.235;
    
    picOffsetX=a*0.05;
    picOffsetY=picOffsetX;
    picWidth=a-2*picOffsetX;
    picHeight=a-wordh-picOffsetY;

}

+(double)maxx
{
    CGRect rect=[[UIScreen mainScreen]bounds];
    return rect.size.width;
}

+(double)maxy
{
    CGRect rect=[[UIScreen mainScreen]bounds];
    CGRect recttab=[[UIApplication sharedApplication] statusBarFrame];
    return rect.size.height-recttab.size.height;
}

@end
//
//  HAMGridViewTool.h
//  iosapp
//
//  Created by daiyue on 13-7-24.
//  Copyright (c) 2013年 Droplings. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import "HAMViewInfo.h"
#import "HAMCardView.h"
#import "HAMTools.h"
#import "HAMConfig.h"
#import "HAMSharedData.h"

@interface HAMGridViewTool : NSObject <UIScrollViewDelegate> {
    HAMViewInfo* viewInfo;
    HAMConfig* config;
    
    UIScrollView* scrollView_;
    int totalPageNum_;
    int currentPage_;
    NSMutableArray* pageViews_;
    
    UIViewController* viewController_;
    NSMutableArray* cardViewArray_;
    NSString* currentUUID_;
}

@property NSMutableArray* cardViewArray_;

-(id)initWithView:(UIScrollView*)_view viewInfo:(HAMViewInfo*)_viewInfo config:(HAMConfig*)_config delegate:(id)_viewController edit:(Boolean)_edit;
-(void)prepareRefreshView:(NSString*)nodeUUID scrollToFirstPage:(Boolean)showFirstPage;
-(void)refreshView:(NSString*)nodeUUID scrollToFirstPage:(Boolean)showFirstPage;
-(void)setLayoutWithxnum:(int)_xnum ynum:(int)_ynum;

//for sub class
- (UIButton*)addCardViewOfCard:(HAMCard*)card atPosIndex:(int)index onPage:(int)pageIndex tag:(int)tag;
- (void)addLabelAtPosIndex:(int)index onPage:(int)pageIndex text:(NSString*)text color:(UIColor*)color type:(int)cardType tag:(int)tag;
- (void)addCardAtPosIndex:(int)pos onPage:(int)pageIndex cardID:(NSString*)cardID index:(int)index;

@end

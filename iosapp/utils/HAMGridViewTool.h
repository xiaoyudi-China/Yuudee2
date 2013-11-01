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
#import "HAMTools.h"
#import "HAMConfig.h"

@interface HAMGridViewTool : NSObject{
    HAMViewInfo* viewInfo;
    HAMConfig* config;
    UIView* view;
    
    UIViewController* viewController_;
    NSMutableArray* layerArray;
    NSString* currentUUID_;
}

@property NSMutableArray* layerArray;

-(id)initWithView:(UIView*)_view viewInfo:(HAMViewInfo*)_viewInfo config:(HAMConfig*)_config viewController:(id)_viewController edit:(Boolean)_edit;
-(void)prepareRefreshView:(NSString*)nodeUUID;
-(void)refreshView:(NSString*)nodeUUID;
-(void)setLayoutWithxnum:(int)_xnum ynum:(int)_ynum;

//for sub class
-(UIButton*)addButtonWithi:(int)i j:(int)j picName:(NSString*)picName action:(SEL)action tag:(int)tag bgType:(int)bgType;
-(void)addLabelWithi:(int)i j:(int)j text:(NSString*)text color:(UIColor*)color tag:(int)index;
-(void)addCardAtPos:(int)pos cardID:(NSString*)cardID index:(int)index;
-(void)addAddNodeAtPos:(int)pos index:(int)index;

@end

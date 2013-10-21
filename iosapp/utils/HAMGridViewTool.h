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
    
    Boolean edit;
    
    id viewController;
}

@property NSMutableArray* layerArray;

-(id)initWithView:(UIView*)_view viewInfo:(HAMViewInfo*)_viewInfo config:(HAMConfig*)_config viewController:(id)_viewController edit:(Boolean)_edit;

-(void)refreshView:(NSString*)nodeUUID;
-(void)setLayoutWithxnum:(int)_xnum ynum:(int)_ynum;
@end

//
//  HAMDragableViewTool.h
//  iosapp
//
//  Created by Dai Yue on 13-10-25.
//  Copyright (c) 2013年 Droplings. All rights reserved.
//

#import "HAMGridViewTool.h"
#import "HAMStructureEditViewController.h"

#define MAX_CARD_NUM 20

@class HAMStructureEditViewController;

@interface HAMEditableGridViewTool : HAMGridViewTool
{
    //TODO: max cards in single screen - 20 here
    struct CGPoint positionArray_[MAX_CARD_NUM];
    int tagOfIndex_[MAX_CARD_NUM];
    NSMutableArray* cardViewArray_;
    NSMutableArray* editButtonArray_;
    Boolean isBlankAtTag_[MAX_CARD_NUM];
}

@end

//
//  HAMDragableViewTool.h
//  iosapp
//
//  Created by Dai Yue on 13-10-25.
//  Copyright (c) 2013年 Droplings. All rights reserved.
//

#import "HAMGridViewTool.h"
#import "HAMSettingsViewController.h"

#define EDITVIEW_MAX_CARD_NUM 1000

@class HAMSettingsViewController;

@interface HAMEditableGridViewTool : HAMGridViewTool
{
    //TODO: max cards in single screen - 1000 here
    struct CGPoint positionArray_[EDITVIEW_MAX_CARD_NUM];
    NSInteger tagOfIndex_[EDITVIEW_MAX_CARD_NUM];
    //int indexOfTag_[EDITVIEW_MAX_CARD_NUM];
    //NSMutableArray* cardViewArray_;
    NSMutableArray* editButtonArray_;
    Boolean isBlankAtTag_[EDITVIEW_MAX_CARD_NUM];
}

@end
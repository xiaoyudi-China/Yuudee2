//
//  HAMCardPreviewViewController.h
//  iosapp
//
//  Created by 张 磊 on 13-11-1.
//  Copyright (c) 2013年 Droplings. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HAMConfig.h"

@interface HAMCardPreviewViewController : UIViewController

@property (nonatomic, strong) NSString *cardID;
@property (nonatomic, strong) NSString *userID;
@property (nonatomic, assign) int slotToReplace;
@property (nonatomic, weak) HAMConfig *config;
@property (nonatomic, weak) IBOutlet UIImageView *cardImageView;
@property (nonatomic, weak) IBOutlet UILabel *textLabel;

@end

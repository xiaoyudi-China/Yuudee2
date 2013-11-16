//
//  HAMCardEditorViewController.h
//  iosapp
//
//  Created by 张 磊 on 13-11-15.
//  Copyright (c) 2013年 Droplings. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HAMRecorderViewController.h"

@interface HAMCardEditorViewController : UIViewController <UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

- (IBAction)recordButtonTapped:(id)sender;
- (IBAction)pickImageButtonTapped:(id)sender;

@property (nonatomic, strong) HAMRecorderViewController *recorder;

@end

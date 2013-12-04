//
//  HAMCardEditorViewController.h
//  iosapp
//
//  Created by 张 磊 on 13-11-15.
//  Copyright (c) 2013年 Droplings. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HAMRecorderViewController.h"
#import "HAMCard.h"
#import "HAMConfig.h"
#import "HAMConstants.h"
#import "HAMImageCropperViewController.h"

@class HAMCardEditorViewController;
@protocol HAMCardEditorViewControllerDelegate <NSObject>

- (void)cardEditorDidEndEditing:(HAMCardEditorViewController*)cardEditor;

@end


@interface HAMCardEditorViewController : UIViewController <UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, HAMImageCropperViewControllerDelegate>

@property (strong, nonatomic) NSString *cardID;
@property (strong, nonatomic) NSString *categoryID;
@property (weak, nonatomic) HAMConfig *config;
@property (weak, nonatomic) UIPopoverController *popover;
@property (weak, nonatomic) id<HAMCardEditorViewControllerDelegate> delegate;

@property (strong, nonatomic) HAMCard *tempCard;

@property (nonatomic, strong) HAMRecorderViewController *recorder;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UITextField *cardNameField;
@property (weak, nonatomic) IBOutlet UIButton *deleteCardButton;
@property (weak, nonatomic) IBOutlet UIButton *finishButton;
@property (weak, nonatomic) IBOutlet UIButton *recordButton;

- (IBAction)recordButtonTapped:(id)sender;
- (IBAction)pickImageButtonTapped:(id)sender;
- (IBAction)deleteCardButtonTapped:(id)sender;
- (IBAction)cancelButtonTapped:(id)sender;
- (IBAction)finishButtonTapped:(id)sender;

@end

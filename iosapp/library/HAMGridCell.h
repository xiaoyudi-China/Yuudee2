//
//  HAMGridCell.h
//  iosapp
//
//  Created by 张 磊 on 13-10-24.
//  Copyright (c) 2013年 Droplings. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HAMGridCell;
@protocol HAMGridCellDelegate <NSObject>

-(void) rightTopButtonPressedForCell: (HAMGridCell*) cell;

@end


@interface HAMGridCell : UICollectionViewCell <UIActionSheetDelegate>

typedef enum {
	HAMGridCellModeAdd,
	HAMGridCellModeEdit
} HAMGridCellMode;

@property (weak, nonatomic) IBOutlet UIImageView *frameImageView;
@property (weak, nonatomic) IBOutlet UIImageView *contentImageView;
@property (weak, nonatomic) IBOutlet UILabel *textLabel;
@property (weak, nonatomic) IBOutlet UIButton *rightTopButton;

@property (weak, nonatomic) id<HAMGridCellDelegate> delegate;
@property (strong, nonatomic) NSIndexPath *indexPath;
@property BOOL itemSelected;

- (IBAction)rightTopButtonPressed:(id)sender;

@end

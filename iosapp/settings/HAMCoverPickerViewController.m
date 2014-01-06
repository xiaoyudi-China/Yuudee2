//
//  HAMCoverPickerViewController.m
//  iosapp
//
//  Created by 张 磊 on 14-1-6.
//  Copyright (c) 2014年 Droplings. All rights reserved.
//

#import "HAMCoverPickerViewController.h"

@interface HAMCoverPickerViewController ()

@end

@implementation HAMCoverPickerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
	[(UICollectionView*)self.view registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"ImageCell"];
	self.preferredContentSize = self.view.frame.size;
	
	self.images = [[NSMutableArray alloc] init];
	[self.images addObject:[UIImage imageNamed:@"defaultImage.png"]]; // xiaoyudi LOGO
	
	NSArray *cardIDs = [self.config childrenCardIDOfCat:self.categoryID];
	for (NSString *cardID in cardIDs) {
		HAMCard *card = [self.config card:cardID];
		UIImage *image = [UIImage imageWithContentsOfFile:[HAMFileTools filePath:card.image.localPath]];
		[self.images addObject:image];
	}
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
	return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
	return self.images.count;
}

- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
	UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ImageCell" forIndexPath:indexPath];
	UIImageView *imageView = [[UIImageView alloc] initWithFrame:cell.bounds];
	imageView.image = self.images[indexPath.row];

	if (cell.contentView.subviews.count > 0) // remove the old subviews
		[cell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
	[cell.contentView addSubview:imageView];
	
	return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
	UIImage *image = self.images[indexPath.row];
	[self.delegate coverPickerDidPickImage:image];
}

@end

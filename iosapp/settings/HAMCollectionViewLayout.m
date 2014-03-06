//
//  HAMCollectionViewLayout.m
//  iosapp
//
//  Created by 张 磊 on 14-3-5.
//  Copyright (c) 2014年 Droplings. All rights reserved.
//

#import "HAMCollectionViewLayout.h"

static const NSInteger NUM_ROWS = 3;
static const NSInteger NUM_COLS = 3;

@implementation HAMCollectionViewLayout

- (id)init {
	if (self = [super init]) {
		// TODO: avoid using magic numbers
		self.numItems = [self.collectionView numberOfItemsInSection:0];
	}
	
	return self;
}

// position the items like the springboard
- (void)prepareLayout {
	self.attributes = [[NSMutableArray alloc] initWithCapacity:self.numItems];
	for (NSInteger index = 0; index < self.numItems; index++) {
		NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
		UICollectionViewLayoutAttributes *attribute = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
		
		NSInteger numItemsOnPage = NUM_ROWS * NUM_COLS;
		CGFloat offset = (index / numItemsOnPage) * self.collectionView.bounds.size.width;
		NSInteger col = (index % numItemsOnPage) % NUM_ROWS;
		NSInteger row = (index % numItemsOnPage) / NUM_ROWS;
		CGFloat nx = self.sectionInset.left + col*(self.itemSize.width + self.minimumLineSpacing) + offset;
		CGFloat ny = self.sectionInset.top + row*(self.itemSize.height + self.minimumInteritemSpacing);
		attribute.frame = (CGRect){CGPointMake(nx, ny), self.itemSize};
		attribute.bounds = (CGRect){CGPointZero, self.itemSize};
		
		[self.attributes addObject:attribute];
	}
}

- (CGSize)collectionViewContentSize {
	NSInteger numItems = [self.collectionView numberOfItemsInSection:0];
	NSInteger numPages = (numItems + 9 - 1) / 9; // round up
	CGSize contentSize;
	contentSize.height = self.collectionView.bounds.size.height;
	contentSize.width = self.collectionView.bounds.size.width * numPages;
	
	return contentSize;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
	NSMutableArray *attrs = [[NSMutableArray alloc] init];
	for (UICollectionViewLayoutAttributes *attr in self.attributes) {
		if (CGRectIntersectsRect(rect, attr.frame))
			[attrs addObject:attr];
	}
	return attrs;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
	return self.attributes[indexPath.row];
}

@end

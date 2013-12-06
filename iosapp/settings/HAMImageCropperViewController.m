//
//  HAMImageCropperViewController.m
//  iosapp
//
//  Created by 张 磊 on 13-11-28.
//  Copyright (c) 2013年 Droplings. All rights reserved.
//

#import "HAMImageCropperViewController.h"

@interface HAMImageCropperViewController ()

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) UIImageView *imageView; // TODO: declare this in interface builder

@end

@implementation HAMImageCropperViewController

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
	if (self.image.imageOrientation != UIImageOrientationRight)
		self.image = [[UIImage alloc] initWithCGImage:self.image.CGImage scale:1.0 orientation:UIImageOrientationRight];
	self.imageView = [[UIImageView alloc] initWithFrame:self.scrollView.frame];
	self.imageView.contentMode = UIViewContentModeScaleAspectFill;
	self.imageView.image = self.image;
	
	[self.scrollView addSubview:self.imageView];
	self.scrollView.contentSize = self.imageView.frame.size;
	
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIView*)viewForZoomingInScrollView:(UIScrollView *)scrollView {
	return self.imageView;
}

- (IBAction)cancelButtonPressed:(id)sender {
	[self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)confirmButtonPressed:(id)sender {
	CGFloat scale = self.image.size.width / self.scrollView.frame.size.width / self.scrollView.zoomScale;
	CGRect rect;
	rect.origin.x = self.scrollView.contentOffset.x * scale;
	rect.origin.y = (self.scrollView.contentOffset.y + self.topCoverView.frame.size.height)* scale;
	rect.size.width = self.scrollView.frame.size.width * scale;
	rect.size.height = SCREEN_WIDTH * 3/4 * scale;
	
	CGRect transformedRect;
	transformedRect.origin.x = rect.origin.y;
	transformedRect.origin.y = self.image.size.width - (rect.origin.x + rect.size.width);
	transformedRect.size.width = rect.size.height;
	transformedRect.size.height = rect.size.width;
	
	CGImageRef imageRef = CGImageCreateWithImageInRect(self.image.CGImage, transformedRect);
	UIImage *croppedImage = [[UIImage alloc] initWithCGImage:imageRef scale:1.0 orientation:self.image.imageOrientation];
	[self.delegate imageCropper:self didFinishCroppingWithImage:croppedImage];
	
	[self.navigationController dismissViewControllerAnimated:YES completion:NULL];
}

@end

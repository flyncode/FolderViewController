//
//  ComboBoxViewController.m
//  ICSTest
//
//  Created by Chris Warner on 7/20/11.
//  Copyright 2011 AeroComputers, Inc. All rights reserved.
//

#import "TabFolderViewController.h"
#import <QuartzCore/QuartzCore.h>

const int STRETCH_LEFT_CAP = 28;
const int OFFSET_X = 10;
const int OFFSET_Y = 15;

@interface TabFolderViewController (Private)
- (void)captureTabImageWithRect:(CGRect)tabRect imageMask:(UIImage*)maskImage;
@end

@implementation TabFolderViewController (Private)

- (void)adjustArrowPositionFromPoint:(CGPoint)pt
{
	CGRect ctrlFrame = [_control frame];
#if 1
	// Apart of _folderView
	_arrowBGView.frame = CGRectMake(ctrlFrame.origin.x - STRETCH_LEFT_CAP - OFFSET_X, 
									 -ctrlFrame.size.height - OFFSET_Y,
									 ctrlFrame.size.width + (STRETCH_LEFT_CAP * 2) + (OFFSET_X * 2), 
									 /*ctrlFrame.size.height*/ + _arrowBGView.image.size.height /*(OFFSET_Y * 2)*/);
	
	_tabCover.frame = self.arrowTip.frame;
#else
	// Subview of self.view
	_arrowBGView.frame = CGRectMake(ctrlFrame.origin.x - STRETCH_LEFT_CAP - OFFSET_X, 
									ctrlFrame.origin.y - OFFSET_Y,
									ctrlFrame.size.width + (STRETCH_LEFT_CAP * 2) + (OFFSET_X * 2), 
									ctrlFrame.size.height + _arrowBGView.image.size.height /*(OFFSET_Y * 2)*/);
	
	_tabCover.frame = [_folderView convertRect:self.arrowTip.frame fromView:self.view];
#endif
}

- (void)layoutFinalFrame
{
	[super layoutFinalFrame];
	
	// Move the "tab" image out of the way as well
	//self.arrowCover.frame = CGRectOffset(self.arrowCover.frame, 0, 
	//								   self.mFolderView.frame.size.height/* + self.arrowCover.frame.size.height*/);
	
	_tabCover.frame = CGRectOffset(_tabCover.frame, 0, 
								   self.folderView.frame.size.height + _tabCover.frame.size.height);
}

- (void)captureImageFromControl:(id)control
{
	// Follow normal procedure for the bottom portion
	// of the background view
	[super captureImageFromControl:control];
	
	// Create the tab cover mask by stretching the arrow
	// image to the size of the tab
	UIImage* _tabMask = [[UIImage imageNamed:@"Arrow_Mask.png"] stretchableImageWithLeftCapWidth:STRETCH_LEFT_CAP topCapHeight:0];
	
	CGRect ctrlFrame = [control frame];
	ctrlFrame = CGRectMake(ctrlFrame.origin.x - STRETCH_LEFT_CAP - OFFSET_X, 
									ctrlFrame.origin.y - OFFSET_Y,
									ctrlFrame.size.width + (STRETCH_LEFT_CAP * 2) + (OFFSET_X * 2), 
									ctrlFrame.size.height + (OFFSET_Y * 2));
	
	_tabCover.frame = ctrlFrame;
	_tabCover.image = _tabMask;
	
	UIGraphicsBeginImageContext(ctrlFrame.size);
	//[_tabMask drawInRect:ctrlFrame];
	CGContextRef g = UIGraphicsGetCurrentContext();
	[_tabCover.layer renderInContext:g];
	
	UIImage* sizedMask = UIGraphicsGetImageFromCurrentImageContext();
	
	// Capture portion of view that is the "tab cover"
	[control setHidden:YES];
	[self captureTabImageWithRect:ctrlFrame imageMask:sizedMask];
	[control setHidden:NO];
	
	//_tabCover.image = sizedMask;
	
	//[self.view bringSubviewToFront:control];
	//[self.view sendSubviewToBack:_folderView];
}

- (void)captureTabImageWithRect:(CGRect)tabRect imageMask:(UIImage*)maskImage
{	
	UIGraphicsBeginImageContext(tabRect.size);
	
	// Offset the current context to the portion of the view
	// that encompasses the tab cover
	CGContextRef g = UIGraphicsGetCurrentContext();
	CGContextTranslateCTM(g, -tabRect.origin.x, -tabRect.origin.y);
	
	// Capture the main content view
	[self.view.layer renderInContext:g];	
	
	UIImage* tabFG = UIGraphicsGetImageFromCurrentImageContext();
	
	// Create a CGImageMask from the UIImage
	CGImageRef maskRef = maskImage.CGImage; 
	CGImageRef mask = CGImageMaskCreate(CGImageGetWidth(maskRef),
										CGImageGetHeight(maskRef),
										CGImageGetBitsPerComponent(maskRef),
										CGImageGetBitsPerPixel(maskRef),
										CGImageGetBytesPerRow(maskRef),
										CGImageGetDataProvider(maskRef), NULL, false);
	
	// Mask the offscreen render with the input maskImage
	CGImageRef masked = CGImageCreateWithMask(tabFG.CGImage, mask);
	_tabCover.image = [UIImage imageWithCGImage:masked];
}

@end

@implementation TabFolderViewController

//@synthesize arrowCover;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
	{
        // Custom initialization
	}
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
	
	// Override the arrow image with a stretch-able version
	_arrowBGView.image = [[UIImage imageNamed:@"Arrow.png"] stretchableImageWithLeftCapWidth:28.0 topCapHeight:0.0];

	// Create other resources - Lazy initialization via property?
	_tabCover = [[UIImageView alloc] initWithFrame:CGRectZero];
	[self.folderView insertSubview:_tabCover belowSubview:_bgBottomView];
	//[_folderView addSubview:_tabCover];
	//[self.view insertSubview:_tabCover aboveSubview:_folderView];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

@end

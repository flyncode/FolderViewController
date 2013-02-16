// ============================================================================
//
//  ComboBoxViewController.m
//  ICSTest
//
//  Created by Chris Warner on 7/20/11.
//  Copyright 2011 BrilliantConcept.net
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
// 
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
// 
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
// 
// ============================================================================

#import "TabFolderViewController.h"
#import <QuartzCore/QuartzCore.h>

const int STRETCH_LEFT_CAP = 28;
const int OFFSET_X = 0;
const int OFFSET_Y = 15;

@interface TabFolderViewController (Protected)
- (void)layoutOpenFolderAtPoint:(CGPoint)folderPt;
@end

@interface TabFolderViewController (Private)
- (void)captureTabImageWithRect:(CGRect)tabRect imageMask:(UIImage*)maskImage;
@end

@implementation TabFolderViewController (Private)

- (void)adjustArrowPositionFromPoint:(CGPoint)pt
{
	if ([_control superview] != [self.arrowTip superview])
	{
		//		self.arrowTip.frame = [[_control superview] convertRect:self.arrowTip.frame 
		//													   fromView:self.view];
		
		//[self.arrowCover removeFromSuperview];
		//[[_control superview] insertSubview:self.arrowCover belowSubview:_control];
		
		[self.arrowTip removeFromSuperview];		
		[self.arrowCover removeFromSuperview];
		
		[[_control superview] insertSubview:self.arrowCover belowSubview:_control];
		[[_control superview] insertSubview:self.arrowTip belowSubview:self.arrowCover];
	}
	
	CGRect ctrlFrame = [_control frame];
	CGRect arrowFrame = CGRectMake(ctrlFrame.origin.x - STRETCH_LEFT_CAP - OFFSET_X, 
								ctrlFrame.origin.y - OFFSET_Y,
								ctrlFrame.size.width + (STRETCH_LEFT_CAP * 2) + (OFFSET_X * 2), 
								self.arrowTip.image.size.height + (OFFSET_Y * 2));
	
	// Position in our view
	//CGRect arrowFrame = [self getArrowRectInFolderViewForControl:_control];	
	self.arrowTip.frame = arrowFrame;
	self.arrowCover.frame = arrowFrame;	
	
	self.foreArrowCover.frame = [self.folderView convertRect:arrowFrame fromView:[_control superview]];
}

- (void)adjustFolderFrameRelativeToPoint:(CGPoint)folderPt
{
	// Override to ignore the arrow image's height in determining
	// the y-placement
	self.folderView.frame = CGRectMake(0, folderPt.y,
									   self.view.frame.size.width, 
									   self.contentView.frame.size.height);
	
	// Fill the Folder View with the contentView
	self.contentView.frame = self.folderView.bounds;
}

- (void)layoutOpenFolderAtPoint:(CGPoint)folderPt
{
	[super layoutOpenFolderAtPoint:folderPt];
	
	// Move the "tab" image out of the way as well
	self.arrowCover.hidden = NO;
	self.arrowCover.frame = CGRectNewOriginY(self.arrowCover.frame,
		self.arrowTip.frame.origin.y + self.arrowTip.frame.size.height + 
		self.folderView.frame.size.height);
	
	self.foreArrowCover.frame = [self.folderView convertRect:self.arrowCover.frame fromView:[self.arrowCover superview]];
	self.foreArrowCover.hidden = NO;
	[[self.foreArrowCover superview] bringSubviewToFront:self.foreArrowCover];
										
	//[self.folderView bringSubviewToFront:self.arrowCover];
	[self.view bringSubviewToFront:(UIView*)_control];
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
	CGRect tabSizeRec = CGRectMake(0, 0, ctrlFrame.size.width + (STRETCH_LEFT_CAP * 2) + (OFFSET_X * 2), 
								   self.arrowTip.image.size.height + (OFFSET_Y * 2));
								   //ctrlFrame.size.height + (OFFSET_Y * 2));
	
	CGRect oldFrame = self.arrowCover.frame;
	self.arrowCover.frame = tabSizeRec;
	self.arrowCover.image = _tabMask;
	
	UIGraphicsBeginImageContext(tabSizeRec.size);
	[_tabMask drawInRect:tabSizeRec];
	//CGContextRef g = UIGraphicsGetCurrentContext();
	//[self.arrowCover.layer renderInContext:g];
	
	self.arrowCover.frame = oldFrame;
	
	UIImage* sizedMask = UIGraphicsGetImageFromCurrentImageContext();
	
	// Capture portion of view that is the "tab cover"
	//CGRect tabRectInView = CGRectOffset(tabSizeRec, ctrlFrame.origin.x - STRETCH_LEFT_CAP - OFFSET_X, ctrlFrame.origin.y - OFFSET_Y);
	CGRect tabRectInView = [self.view convertRect:ctrlFrame fromView:[_control superview]];
	
	BOOL controlWasHidden = [control isHidden];
	[control setHidden:YES];
	[self captureTabImageWithRect:tabRectInView imageMask:sizedMask];
	[control setHidden:controlWasHidden];
}

- (void)captureTabImageWithRect:(CGRect)tabRect imageMask:(UIImage*)maskImage
{	
	UIGraphicsBeginImageContext(tabRect.size);
	
	// Offset the current context to the portion of the view
	// that encompasses the tab cover
	CGContextRef g = UIGraphicsGetCurrentContext();
	CGContextTranslateCTM(g, -tabRect.origin.x, -tabRect.origin.y);
	
	// Capture the main content view
	self.arrowTip.hidden = YES;
	//[[self.arrowCover superview].layer renderInContext:g];	
	[self.view.layer renderInContext:g];
	self.arrowTip.hidden = NO;
	
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
	self.arrowCover.image = [UIImage imageWithCGImage:masked];
	self.foreArrowCover.image = [UIImage imageWithCGImage:masked];
	
	CGImageRelease(masked);
	CGImageRelease(mask);
}

@end

@implementation TabFolderViewController

- (void)willOpenFolderForControl:(id)control
{
	self.arrowCover.hidden = NO;
	[super willOpenFolderForControl:control];
}

- (void)didCloseFolderForControl:(id)control
{
	[super didCloseFolderForControl:control];
	self.arrowCover.hidden = YES;
}

#pragma mark - Properties

- (UIImageView*)arrowTip
{
	if (self->_arrowBGView == nil)
	{
		// Override the arrow image with a stretch-able version
		UIImageView* _val = [super arrowTip];
		_val.image = [_val.image stretchableImageWithLeftCapWidth:28.0 topCapHeight:0.0];
	}
	
	return [super arrowTip];
}

- (UIImageView*)arrowCover
{
	if (_tabCover == nil)
	{
		_tabCover = [[UIImageView alloc] initWithFrame:CGRectZero];
		[self.folderView addSubview:_tabCover];
	}
	return _tabCover;
}

- (UIImageView*)foreArrowCover
{
	if (_foreArrowCover == nil)
	{
		_foreArrowCover = [[UIImageView alloc] initWithFrame:CGRectZero];
		[self.folderView addSubview:_foreArrowCover];
	}
	
	return _foreArrowCover;
}

#pragma mark - UIViewController stuff

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

- (void)dealloc
{
	if (_tabCover != nil)
	{
		[_tabCover release];
		_tabCover = nil;
	}
	
	[super dealloc];
}

#pragma mark - View lifecycle

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
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

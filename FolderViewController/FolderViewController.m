// ============================================================================
//
//  FolderViewController.m
//
//  Created by Bharath Booshan on 02/12/11
//  Refactored by Chris Warner on 07/27/11
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

#import "FolderViewController.h"
#import <QuartzCore/QuartzCore.h>

const int ANIMATION_STETCH = 1;

@implementation FolderViewController (Protected)

- (CGPoint)folderOriginForControl:(id)control
{
	return CGPointMake([control center].x, [control frame].origin.y + [control frame].size.height);
}

- (void)adjustArrowPositionFromPoint:(CGPoint)pt
{
	// Place The Arrow View such that it is right below and 
	// to the Center of the Tapped Folder Icon Tapped.  The
	// setAnimationEnabled calls prevent any animation of
	// the arrow when the folder is closing
	//
	// TODO: Fix the closing animation bug (the arrow's
	// frame should be constant)
	[UIView setAnimationsEnabled:NO];
	
	//_arrowBGView.center = CGPointMake(pt.x, 0);
	CGSize imgSize = self.arrowTip.image.size;
	self.arrowTip.frame = CGRectMake(pt.x - (imgSize.width / 2), -imgSize.height, 
									 imgSize.width, imgSize.height);
	
	[UIView setAnimationsEnabled:YES];
}

- (void)captureImageFromControl:(id)control
{
	[self captureImageFromPoint:[self folderOriginForControl:control]];
	_lastControl = control;
}

- (void)captureImageFromPoint:(CGPoint)folderPt
{
    UIGraphicsBeginImageContext(self.view.frame.size);
	
	// Offset the current context to the portion of the view
	// to pan down as a result of opening the folder
	CGContextRef g = UIGraphicsGetCurrentContext();
	CGContextTranslateCTM(g, 0, -(folderPt.y + _arrowBGView.frame.size.height));
	
	// Capture the main view's content to an image
	[self.view.layer renderInContext:g];	
	
#if 0
	// Test pattern
	CGContextSetRGBStrokeColor(g, 1, 0, 0, 1);
	CGContextMoveToPoint(g, 0, 0);
	CGContextAddLineToPoint(g, self.view.bounds.size.width, self.view.bounds.size.height);
	CGContextMoveToPoint(g, self.view.bounds.size.width, 0);
	CGContextAddLineToPoint(g, 0, self.view.bounds.size.height);
	CGContextDrawPath(g, kCGPathStroke);	
#endif
	
	UIImage* backgroundImage = UIGraphicsGetImageFromCurrentImageContext();
	self.bottomBGImage.image = backgroundImage;
}

- (void)adjustFolderFrameRelativeToPoint:(CGPoint)folderPt
{
	//Place the Folder View Just below Arrow View
	self.folderView.frame = CGRectMake(0, folderPt.y + self.arrowTip.frame.size.height,
										self.contentView.frame.size.width, 
										self.contentView.frame.size.height);
}

- (void)adjustCaptureFrameRelativeToPoint:(CGPoint)folderPt
{
	// Make sure the view which displays the bottom offset
	// portion of the view is below the arrow
	self.bottomBGImage.frame = CGRectMake(0, self.folderView.frame.origin.y,
											self.view.bounds.size.width, 
											self.view.bounds.size.height);
}

- (void)layoutClosedFolderAtPoint:(CGPoint)folderPt
{
	[self adjustArrowPositionFromPoint:folderPt];
	[self adjustFolderFrameRelativeToPoint:folderPt];
	[self adjustCaptureFrameRelativeToPoint:folderPt];	
}

- (void)layoutOpenFolderAtPoint:(CGPoint)folderPt
{
	// Move the captured view BG into position below the edge of the folder
	self.bottomBGImage.frame = CGRectOffset(self.bottomBGImage.frame, 0, self.folderView.frame.size.height);
}

@end

@implementation FolderViewController

#pragma mark - Properties

@synthesize delegate;
@synthesize isOpen;
@synthesize contentView;

- (UIView*)folderView
{
	if (_folderView == nil)
	{
		_folderView = [[UIView alloc] initWithFrame:CGRectZero];
		_folderView.hidden = YES;
		[self.view addSubview:_folderView];
	}
	
	return _folderView;
}

- (UIImageView*)bottomBGImage
{
	if (_bgBottomView == nil)
	{
		_bgBottomView = [[UIImageView alloc] initWithFrame:CGRectZero];
		_bgBottomView.hidden = YES;
		[self.view addSubview:_bgBottomView];
	}

	return _bgBottomView;
}

- (void)setBottomBGImage:(UIImageView *)bottomBGImage
{
	if (_bgBottomView != nil)
		[_bgBottomView release];
	
	_bgBottomView = [bottomBGImage retain];
}

- (UIImageView*)arrowTip
{
	if (_arrowBGView == nil)
	{
#if 1
		UIImage* arrowMask = [UIImage imageNamed:@"Arrow_Mask.png"];
		
		UIGraphicsBeginImageContext(arrowMask.size);
		CGContextRef g = UIGraphicsGetCurrentContext();
		
		UIColor* fabricColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"fabric"]];
		[fabricColor setFill];
		
		CGContextFillRect(g, CGRectMake(0,0,arrowMask.size.width,arrowMask.size.height));
		UIImage* fabricImg = UIGraphicsGetImageFromCurrentImageContext();
		
		UIImage* img = [FolderViewController maskImage:fabricImg withMask:arrowMask];	
#else
		UIImage* img = [UIImage imageNamed:@"ArrowShadow.png"];
		if (img == nil)
			NSLog(@"WARNING: Could not load ArrowShadow.png");
#endif
		_arrowBGView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,img.size.width,img.size.height)];
		_arrowBGView.image = img;
		[self.folderView addSubview:_arrowBGView];
	}
	
	return _arrowBGView;
}

- (void)setArrowTip:(UIImageView *)arrowTip
{
	if (_arrowBGView != nil)
		[_arrowBGView release];
	_arrowBGView = [arrowTip retain];
}

#pragma mark -

+ (UIImage*)maskImage:(UIImage*)src withMask:(UIImage*)maskImage
{
	// Create a CGImageMask from the UIImage
	CGImageRef maskRef = maskImage.CGImage; 
	CGImageRef mask = CGImageMaskCreate(CGImageGetWidth(maskRef),
										CGImageGetHeight(maskRef),
										CGImageGetBitsPerComponent(maskRef),
										CGImageGetBitsPerPixel(maskRef),
										CGImageGetBytesPerRow(maskRef),
										CGImageGetDataProvider(maskRef), NULL, false);
	
	// Mask the offscreen render with the input maskImage
	CGImageRef masked = CGImageCreateWithMask(src.CGImage, mask);
	UIImage* res = [UIImage imageWithCGImage:masked];
	
	// Cleanup
	CGImageRelease(masked);
	CGImageRelease(mask);
	
	return res;
}

#pragma mark - View Lifecycle

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
	
	_control = nil;
	_lastControl = nil;
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return UIInterfaceOrientationIsLandscape(interfaceOrientation);	
}

- (void)didReceiveMemoryWarning
{
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload
{
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

- (void)dealloc
{
	self.arrowTip = nil;
	self.bottomBGImage = nil;
			
    [super dealloc];
}

#pragma mark - Folder View retrieval
- (UIView*)folderViewForControl:(id)control
{
	if (self.delegate != nil)
		return [self.delegate folderView:self needsContentForControl:control];
	@throw @"No Folder View content!";
}

#pragma mark - Open/Close methods

- (IBAction)toggleFolder:(id)sender
{
	if( !self.isOpen )
		[self openFolder:sender];
	else
		[self closeFolder:sender];
}
	 
- (IBAction)openFolder:(id)sender
{	
	_control = sender;
	
	if (self.isOpen)
		return;
	
	// Notify our delegate that we will open
	if ([self.delegate respondsToSelector:@selector(willOpenFolderForControl:)])
		[self.delegate willOpenFolderForControl:_control];
	
	// STEP 0: Get the content of the Folder View, via a sub-class or delegate
	self.contentView = [self folderViewForControl:sender];
	[self.folderView removeFromSuperview];
	[self.view insertSubview:self.folderView belowSubview:_control];
	[self.view bringSubviewToFront:self.bottomBGImage];
	
	// Add the fabric background for free
	UIColor* fabricColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"fabric"]];
	self.contentView.backgroundColor = fabricColor;
	
	// Add the content to our folder container
	[self.folderView addSubview:self.contentView];					
		
	CGPoint folderPt = [self folderOriginForControl:sender];
	
	// STEP 1: Capture the Main View Content into an image, if we need to
	if ((_lastControl == nil) || (_lastControl != sender))
		[self captureImageFromControl:_control];
	else
		NSLog(@"Skipping captureImageFromControl");
	
	// STEP 2: Layout the folder view, arrow image, and bottom 
	// part of the content view
	[self layoutClosedFolderAtPoint:folderPt];
	
	// STEP 3: Animate the view components, so the folder moves
	// into the open position
	[UIView beginAnimations:@"FolderOpen" context:NULL];
	[UIView setAnimationDuration:(0.5 * (double)ANIMATION_STETCH)];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];		
	[UIView setAnimationDidStopSelector:@selector(animation:didFinish:context:)];
	[UIView setAnimationDelegate:self];
	
	self.folderView.hidden = NO;
	self.bottomBGImage.hidden = NO;
	
	[self layoutOpenFolderAtPoint:folderPt];
	[UIView commitAnimations];
	
	self->isOpen = YES;
}

- (void)closeFolder:(id)sender
{
	// TEMPORARY HACK
	_control = sender;
	
	if (!self.isOpen)
		return;
	
	// Notify our delegate that we will close
	if ([self.delegate respondsToSelector:@selector(willCloseFolderForControl:)])
		[self.delegate willCloseFolderForControl:_control];

	CGPoint folderPt = [self folderOriginForControl:sender];
	
	// Restore the layout and hide the folder view after animation
	[UIView beginAnimations:@"FolderClose" context:NULL];
	[UIView setAnimationDuration:(0.5 * (double)ANIMATION_STETCH)];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
	[UIView setAnimationDidStopSelector:@selector(animation:didFinish:context:)];
	[UIView setAnimationDelegate:self];
	
	[self layoutClosedFolderAtPoint:folderPt];
	
	[UIView commitAnimations];
	self->isOpen = NO;
}

-(void)animation:(NSString*)animation didFinish:(BOOL)finish context:(void *)context
{
	if ([animation isEqualToString:@"FolderOpen"])
	{
		if ([self.delegate respondsToSelector:@selector(didOpenFolderForControl:)])
			[self.delegate didOpenFolderForControl:_control];
	}
	else if ([animation isEqualToString:@"FolderClose"])
	{
		self.folderView.hidden = YES;
		self.bottomBGImage.hidden = YES;

		[self.contentView removeFromSuperview];
		self.contentView = nil;
		
		if ([self.delegate respondsToSelector:@selector(didCloseFolderForControl:)])
			[self.delegate didCloseFolderForControl:_control];
		
		_control = nil;
	}
}

@end

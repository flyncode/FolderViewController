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
	CGPoint center = [control center];
	CGRect frame = [control frame];
	
	// Adjust the coordinates to our view's coordinate system
	if ([control superview] != self.view)
	{
		center = [[control superview] convertPoint:center toView:self.view];
		frame = [[control superview] convertRect:frame toView:self.view];
	}
	
	return CGPointMake(center.x, frame.origin.y + frame.size.height);
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
	UIGraphicsBeginImageContextWithOptions(self.view.frame.size, YES, 0);
	
	// Offset the current context to the portion of the view
	// to pan down as a result of opening the folder
	CGContextRef g = UIGraphicsGetCurrentContext();
	CGContextTranslateCTM(g, 0, -self.bottomBGImage.frame.origin.y);
	
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
										self.view.frame.size.width, 
										self.contentView.frame.size.height);
	
	// Fill the Folder View with the contentView
	self.contentView.frame = self.folderView.bounds;
}

- (void)adjustCaptureFrameRelativeToPoint:(CGPoint)folderPt
{
	self.bottomBGImage.frame = CGRectMake(0, folderPt.y,
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
	[self.view sendSubviewToBack:self.arrowTip];
	[self adjustFolderFrameRelativeToPoint:folderPt];
	self.bottomBGImage.frame = CGRectMake(0, 
									folderPt.y + self.folderView.frame.size.height,
									self.view.bounds.size.width, 
									self.view.bounds.size.height);
}

- (void)bottomBGImageWasTapped
{
	if (self.isOpen)
		[self closeFolder:self.bottomBGImage];
}

#pragma mark - Sub-class Hooks / Delegate Notification operations

- (void)willOpenFolderForControl:(id)control
{
	if ([self.delegate respondsToSelector:@selector(willOpenFolderForControl:)])
		[self.delegate willOpenFolderForControl:control];
}

- (void)didOpenFolderForControl:(id)control
{
	if ([self.delegate respondsToSelector:@selector(didOpenFolderForControl:)])
		[self.delegate didOpenFolderForControl:control];
}

- (void)willCloseFolderForControl:(id)control
{
	if ([self.delegate respondsToSelector:@selector(willCloseFolderForControl:)])
		[self.delegate willCloseFolderForControl:control];
}

- (void)didCloseFolderForControl:(id)control
{
	if ([self.delegate respondsToSelector:@selector(didCloseFolderForControl:)])
		[self.delegate didCloseFolderForControl:control];
}

@end

@implementation FolderViewController

#pragma mark - Properties

@synthesize delegate;
@synthesize cacheBottomBG;
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
		_bgBottomView.userInteractionEnabled = YES;

		UITapGestureRecognizer* tapToClose = [[UITapGestureRecognizer alloc] initWithTarget:self 
																					 action:@selector(bottomBGImageWasTapped)];
		tapToClose.numberOfTapsRequired = 1;
		tapToClose.numberOfTouchesRequired = 1;
		[_bgBottomView addGestureRecognizer:tapToClose];
		[tapToClose release];
		
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
		// Make a mask of the fabric background color, that will
		// serve as the background of the arrow
		UIImage* arrowMask = [UIImage imageNamed:@"Arrow_Mask.png"];
		
		// Make a graphics context the size of the arrow
		UIGraphicsBeginImageContext(arrowMask.size);
		CGContextRef g = UIGraphicsGetCurrentContext();
		
		// Fill the context with the iOS Fabric background
		UIColor* fabricColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"fabric"]];
		[fabricColor setFill];
		CGContextFillRect(g, CGRectMake(0,0,arrowMask.size.width,arrowMask.size.height));
		
		// Mask the fabric with the shape of the arrow
		UIImage* fabricImg = UIGraphicsGetImageFromCurrentImageContext();
		UIImage* img = [FolderViewController maskImage:fabricImg withMask:arrowMask];	

		_arrowBGView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,img.size.width,img.size.height)];
		_arrowBGView.image = img;
		_arrowBGView.hidden = YES;
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

#pragma mark - Initializers

- (id)initWithCoder:(NSCoder *)aDecoder
{
	if (self = [super initWithCoder:aDecoder])
		self.cacheBottomBG = YES;
	return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])
		self.cacheBottomBG = YES;
	return self;
}

#pragma mark - Utility Methods

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
	
	@throw [NSException exceptionWithName:@"NoFolderViewContent" 
								   reason:@"No sub-class or Delegate method" 
								 userInfo:nil];
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
	
	// STEP -1: Dismiss keyboard if subview is FirstResponder.  If using the
	// delegate instead of subclassing, this will need to be done by the client
	for (UIView* child in self.view.subviews)
	{
		if (child.isFirstResponder)
		{
			[child resignFirstResponder];
			break;
		}
	}
	
	// Notify our delegate that we will open
	[self willOpenFolderForControl:_control];
	
	// STEP 0: Get the content of the Folder View, via a sub-class or delegate
	self.contentView = [self folderViewForControl:sender];
	
	// Adjust the Z-order of all the views 
	// NOTE: The invoking control is brought to the top of the view's Z-order
	// (other than the folder & bottomBG views)
	[self.folderView removeFromSuperview];
	[self.view bringSubviewToFront:_control];
	[self.view insertSubview:self.folderView belowSubview:_control];
	[self.view bringSubviewToFront:self.bottomBGImage];
	
	// Add the fabric background for free
	UIColor* fabricColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"fabric"]];
	self.folderView.backgroundColor = fabricColor;
	
	// Add the content to our folder container
	[self.folderView addSubview:self.contentView];					
		
	// CW - 2011.08.20 - Put the controls into place first so we can correctly
	// capture the view content into images
	
	// STEP 1: Layout the folder view, arrow image, and bottom 
	// part of the content view
	
	// NOTE: Always layout since the size of the folder view can
	// change based upon content
	CGPoint folderPt = [self folderOriginForControl:sender];
	[self layoutClosedFolderAtPoint:folderPt];
	
	// STEP 2: Capture the Main View Content into an image, if we need to
	if (!self.cacheBottomBG || (_lastControl == nil) || (_lastControl != sender))
		[self captureImageFromControl:_control];
	else
		NSLog(@"Skipping positioning & capturing step");
	
	// STEP 3: Animate the view components, so the folder moves
	// into the open position
	[UIView beginAnimations:@"FolderOpen" context:NULL];
	[UIView setAnimationDuration:(0.5 * (double)ANIMATION_STETCH)];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];		
	[UIView setAnimationDidStopSelector:@selector(animation:didFinish:context:)];
	[UIView setAnimationDelegate:self];
	
	self.folderView.hidden = NO;
	self.bottomBGImage.hidden = NO;
	self.arrowTip.hidden = NO;
	
	[self layoutOpenFolderAtPoint:folderPt];
	[UIView commitAnimations];
	
	self->isOpen = YES;
}

- (void)closeFolder:(id)sender
{
	// NOTE: Close for the control that we opened for,
	// not whoever invoked this event!
	//_control = sender;
	
	if (!self.isOpen)
		return;
	
	// Notify our delegate that we will close
	[self willCloseFolderForControl:_control];

	CGPoint folderPt = [self folderOriginForControl:_control];
	
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
		[self didOpenFolderForControl:_control];
	}
	else if ([animation isEqualToString:@"FolderClose"])
	{
		self.folderView.hidden = YES;
		self.bottomBGImage.hidden = YES;
		self.arrowTip.hidden = YES;

		[self.contentView removeFromSuperview];
		self.contentView = nil;
		
		[self didCloseFolderForControl:_control];		
		_control = nil;
	}
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	//[self captureImageFromControl:_control];
	[self layoutOpenFolderAtPoint:[self folderOriginForControl:_lastControl]];

	// We can't used the cache'd bottom image next time
	_lastControl = nil;
}

@end

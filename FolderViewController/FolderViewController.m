//
//  FolderViewController.m
//
//  Created by Bharath Booshan on 02/12/11
//  Refactored by Chris Warner on 07/27/11
//

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

- (void)captureImageFromPoint:(CGPoint)selectedFolderPoint
{
    UIGraphicsBeginImageContext(self.view.frame.size);
	
	// Offset the current context to the portion of the view
	// to pan down as a result of opening the folder
	CGContextRef g = UIGraphicsGetCurrentContext();
	CGContextTranslateCTM(g, 0, -(selectedFolderPoint.y + _arrowBGView.frame.size.height));
	
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

- (void)layoutFirstFrameRelativeToPoint:(CGPoint)selectedFolderPoint
{
	[self adjustArrowPositionFromPoint:selectedFolderPoint];
	
	//Place the Folder View Just below Arrow View
	CGRect folderViewFrame = CGRectMake(0, selectedFolderPoint.y + _arrowBGView.frame.size.height,		// Compensate for the arrow
										self.tempContent.frame.size.width, 
										self.tempContent.frame.size.height);
	
	// Make sure the view which displays the bottom offset
	// portion of the view is below the arrow
	CGRect maskFrame = CGRectMake(0, folderViewFrame.origin.y,
								  self.view.bounds.size.width, 
								  self.view.bounds.size.height);
	
	self.folderView.frame = folderViewFrame;
	self.bottomBGImage.frame = maskFrame;
	self.arrowTip.hidden = NO;
}

- (void)layoutFinalFrame
{
	// Move the captured view BG into position below the edge of the folder
	self.bottomBGImage.frame = CGRectOffset(self.bottomBGImage.frame, 0, self.folderView.frame.size.height);
}

@end

@implementation FolderViewController

#pragma mark - Properties

@synthesize delegate;
@synthesize isOpen;
@synthesize tempContent;

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

- (UIImageView*)arrowTip
{
	if (_arrowBGView == nil)
	{
		UIImage* img = [UIImage imageNamed:@"Arrow.png"];

		_arrowBGView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,img.size.width,img.size.height)];
		_arrowBGView.image = img;
		[self.folderView addSubview:_arrowBGView];
	}
	
	return _arrowBGView;
}

#pragma mark - View Lifecycle

/*
// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/


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
	[self.arrowTip release];
	_arrowBGView = nil;
	
	[self.bottomBGImage release];
	_bgBottomView = nil;
		
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
	self.tempContent = [self folderViewForControl:sender];
	[self.folderView removeFromSuperview];
	[self.view insertSubview:self.folderView belowSubview:_control];
	//[self.view sendSubviewToBack:self.almostFolderView];			// Try to force the folder view behind the rest of the content
	[self.folderView addSubview:self.tempContent];			// Add the content to our folder container
		
	CGPoint selectedFolderPoint = [self folderOriginForControl:sender];
	NSLog(@"Open Point: %f, %f", selectedFolderPoint.x, selectedFolderPoint.y);
	
	// STEP 1: Capture the Main View Content into an image, if we need to
	if ((_lastControl == nil) || (_lastControl != sender))
		[self captureImageFromControl:_control];
	
	// STEP 2: Layout the folder view, arrow image, and bottom 
	// part of the content view
	[self layoutFirstFrameRelativeToPoint:selectedFolderPoint];
	
	// STEP 3: Animate the view components, so the folder moves
	// into the open position
	[UIView beginAnimations:@"FolderOpen" context:NULL];
	[UIView setAnimationDuration:(0.5 * (double)ANIMATION_STETCH)];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];		
	[UIView setAnimationDidStopSelector:@selector(animation:didFinish:context:)];
	[UIView setAnimationDelegate:self];
	
	self.folderView.hidden = NO;
	self.bottomBGImage.hidden = NO;
	
	[self layoutFinalFrame];
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

	// Restore the layout and hide the folder view after animation
	CGPoint selectedFolderPoint = [self folderOriginForControl:sender];
	NSLog(@"Close Point: %f, %f", selectedFolderPoint.x, selectedFolderPoint.y);
	
	// Animate the folder closed
	[UIView beginAnimations:@"FolderClose" context:NULL];
	[UIView setAnimationDuration:(0.5 * (double)ANIMATION_STETCH)];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
	[UIView setAnimationDidStopSelector:@selector(animation:didFinish:context:)];
	[UIView setAnimationDelegate:self];
	
	[self layoutFirstFrameRelativeToPoint:selectedFolderPoint];
	
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
	   [self.tempContent removeFromSuperview];
	   self.tempContent = nil;
	   _bgBottomView.hidden = YES;
	   _arrowBGView.hidden = YES;
		
		if ([self.delegate respondsToSelector:@selector(didCloseFolderForControl:)])
			[self.delegate didCloseFolderForControl:_control];
		
		_control = nil;
	}
}

@end

// ============================================================================
//
//  FolderAnimationViewController.h
//  FolderAnimation
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

#import <UIKit/UIKit.h>

@class FolderViewController;

@protocol FolderViewControllerDelegate <NSObject>
@optional
- (UIView*)folderView:(FolderViewController*)viewController needsContentForControl:(id)control;
- (void)willOpenFolderForControl:(id)control;
- (void)didOpenFolderForControl:(id)control;
- (void)willCloseFolderForControl:(id)control;
- (void)didCloseFolderForControl:(id)control;
@end

@interface FolderViewController : UIViewController
{
	UIView* _folderView;	
	UIImageView* _arrowBGView;
	UIImageView* _bgBottomView;
	
	id _control;
	id _lastControl;
}

@property(assign, readwrite) BOOL cacheBottomBG;
@property(assign, readonly) BOOL isOpen;
@property(nonatomic, retain) IBOutlet id<FolderViewControllerDelegate> delegate;
@property(nonatomic, retain) UIView* contentView;
@property(nonatomic, assign, readonly) UIView* folderView;
@property(nonatomic, retain) UIImageView* arrowTip;
@property(nonatomic, retain) UIImageView* bottomBGImage;

// Initializers
- (id)initWithCoder:(NSCoder *)aDecoder;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil;

// Action methods
- (IBAction)toggleFolder:(id)sender;
- (IBAction)openFolder:(id)sender;
- (IBAction)closeFolder:(id)sender;

- (UIView*)folderViewForControl:(id)control;

// Utility methods
+ (UIImage*)maskImage:(UIImage*)src withMask:(UIImage*)maskImage;

@end

@interface FolderViewController (Protected)
- (CGPoint)folderOriginForControl:(id)control;

// Sub-class Hooks / Delegate Notification operations
- (void)willOpenFolderForControl:(id)control;
- (void)didOpenFolderForControl:(id)control;
- (void)willCloseFolderForControl:(id)control;
- (void)didCloseFolderForControl:(id)control;

// General layout operations
- (void)layoutClosedFolderAtPoint:(CGPoint)folderPt;
- (void)layoutOpenFolderAtPoint:(CGPoint)folderPt;

// Fine-grained layout operations
- (void)adjustArrowPositionFromPoint:(CGPoint)folderPt;
- (void)adjustFolderFrameRelativeToPoint:(CGPoint)folderPt;
- (void)adjustCaptureFrameRelativeToPoint:(CGPoint)folderPt;

- (void)captureImageFromControl:(id)control;
- (void)captureImageFromPoint:(CGPoint)folderPt;

- (void)bottomBGImageWasTapped;
@end

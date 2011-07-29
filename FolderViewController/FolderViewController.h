//
//  FolderAnimationViewController.h
//  FolderAnimation
//
//  Created by Bharath Booshan on 12/02/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

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

@property(assign, readonly) BOOL isOpen;
@property(nonatomic, retain) IBOutlet id<FolderViewControllerDelegate> delegate;
@property(nonatomic, retain) UIView* tempContent;
@property(nonatomic, assign, readonly) UIView* folderView;
@property(nonatomic, retain, readonly) UIImageView* arrowTip;
@property(nonatomic, retain, readonly) UIImageView* bottomBGImage;

- (IBAction)toggleFolder:(id)sender;
- (IBAction)openFolder:(id)sender;
- (IBAction)closeFolder:(id)sender;

- (UIView*)folderViewForControl:(id)control;

@end

@interface FolderViewController (Protected)
- (CGPoint)folderOriginForControl:(id)control;
- (void)adjustArrowPositionFromPoint:(CGPoint)pt;
- (void)captureImageFromControl:(id)control;
- (void)captureImageFromPoint:(CGPoint)selectedFolderPoint;
- (void)layoutFirstFrameRelativeToPoint:(CGPoint)selectedFolderPoint;
- (void)layoutFinalFrame;
@end

//
//  DelegateTestController.h
//  FolderViewController
//
//  Created by Chris Warner on 7/29/11.
//  Copyright 2011 AeroComputers, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FolderViewController.h"

@interface DelegateTestController : UIViewController <FolderViewControllerDelegate>

- (IBAction)openFolderDelegate:(id)sender;

@property (nonatomic, retain) IBOutlet FolderViewController* folderController;
@property (nonatomic, retain) IBOutlet UIButton* button;
@property (nonatomic, retain) IBOutlet UIView* folderContent;

@end

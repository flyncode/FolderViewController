//
//  ModalTestController.h
//  
//
//  Created by Chris Warner on 8/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TabFolderViewController.h"

@interface ModalViewController : TabFolderViewController {
	UIView *folderContent;
}

@property (retain, nonatomic) IBOutlet UIView *folderContent;
@end

@interface ModalTestController : UIViewController
{
	ModalViewController *modalView;
}

@property (retain, nonatomic) IBOutlet ModalViewController *modalView;

- (IBAction)closeView:(id)sender;
- (IBAction)showModalVIew:(id)sender;

@end

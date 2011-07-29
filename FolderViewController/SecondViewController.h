//
//  SecondViewController.h
//  FolderViewController
//
//  Created by Chris Warner on 7/27/11.
//  Copyright 2011 AeroComputers, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TabFolderViewController.h"

@interface SecondViewController : TabFolderViewController
{
	UIView *folderContent;
}

@property (retain, nonatomic) IBOutlet UIView *folderContent;

@end

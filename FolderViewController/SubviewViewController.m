//
//  SubviewViewController.m
//  FolderViewController
//
//  Created by Chris Warner on 2/9/13.
//  Copyright (c) 2013 AeroComputers, Inc. All rights reserved.
//

#import "SubviewViewController.h"

@interface SubviewViewController ()

@end

@implementation SubviewViewController

#pragma mark - FolderView support

- (UIView*)folderViewForControl:(id)control
{
	return self.folderContent;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_folderContent release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setFolderContent:nil];
    [super viewDidUnload];
}
@end

//
//  DelegateTestController.m
//  FolderViewController
//
//  Created by Chris Warner on 7/29/11.
//  Copyright 2011 AeroComputers, Inc. All rights reserved.
//

#import "DelegateTestController.h"

@implementation DelegateTestController

@synthesize folderController;
@synthesize button;
@synthesize folderContent;

- (IBAction)openFolderDelegate:(id)sender
{
	// Forward call to FolderViewController
	[self.folderController toggleFolder:sender];
}

#pragma mark - FolderViewControllerDelegate methods

- (UIView*)folderView:(FolderViewController*)folder needsContentForControl:(id)sender
{
	return self.folderContent;
}

#pragma mark - UIViewController stuff

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
	{
        self.title = NSLocalizedString(@"Delegate", @"Delegate");
        self.tabBarItem.image = [UIImage imageNamed:@"first"];
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	// Do any additional setup after loading the view from its nib.
	//[self.button addTarget:self action:@selector(openFolderDelegate:) forControlEvents:UIControlEventTouchUpInside];
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

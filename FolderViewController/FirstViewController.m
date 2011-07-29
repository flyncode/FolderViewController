//
//  FirstViewController.m
//  FolderViewController
//
//  Created by Chris Warner on 7/27/11.
//  Copyright 2011 AeroComputers, Inc. All rights reserved.
//

#import "FirstViewController.h"

@implementation FirstViewController
@synthesize folderContent;

#pragma mark - FolderView support

- (UIView*)folderViewForControl:(id)control
{
	return self.folderContent;
}

- (void)willOpenFolderForControl:(id)control
{
	NSLog(@"willOpenFolder");
}

- (void)didOpenFolderForControl:(id)control
{
	NSLog(@"didOpenFolder");
}

- (void)willCloseFolderForControl:(id)control
{
	NSLog(@"willCloseFolder");
}

- (void)didCloseFolderForControl:(id)control
{
	NSLog(@"didCloseFolder");
}

#pragma mark - Standard UIViewController stuff

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Arrow", @"Arrow");
        self.tabBarItem.image = [UIImage imageNamed:@"first"];
		self.delegate = self;
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
	[self setFolderContent:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

- (void)dealloc {
	[folderContent release];
	[super dealloc];
}
@end

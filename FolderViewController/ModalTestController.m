//
//  ModalTestController.m
//  
//
//  Created by Chris Warner on 8/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ModalTestController.h"

@implementation ModalViewController
@synthesize folderContent;
- (id)init
{
	self = [super init];
	if (!self)
	{
		self.view = [[UIView alloc] initWithFrame:CGRectMake(0,0,100,100)];
		self.view.backgroundColor = [UIColor darkGrayColor];
	}
	return self;
}

- (UIView*)folderViewForControl:(id)control
{
	return self.folderContent;
}
- (void)dealloc
{
	[folderContent release];
	[super dealloc];
}
@end

@implementation ModalTestController
@synthesize modalView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
		self.title = @"Modal Test";
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
}

- (void)viewDidUnload
{
	[self setModalView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

#pragma mark - Events

- (IBAction)closeView:(id)sender
{
	[self.parentViewController dismissModalViewControllerAnimated:YES];
}

- (IBAction)showModalVIew:(id)sender
{
	self.modalView.modalPresentationStyle = UIModalPresentationFormSheet;
	[self presentModalViewController:self.modalView animated:YES];
}

- (void)dealloc {
	[modalView release];
	[super dealloc];
}
@end

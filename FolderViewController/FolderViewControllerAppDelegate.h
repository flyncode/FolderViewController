//
//  FolderViewControllerAppDelegate.h
//  FolderViewController
//
//  Created by Chris Warner on 7/27/11.
//  Copyright 2011 AeroComputers, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FolderViewControllerAppDelegate : UIResponder <UIApplicationDelegate, UITabBarControllerDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) UITabBarController *tabBarController;

@end

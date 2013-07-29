//
//  AppDelegate.m
//  Ubiquity
//
//  Created by Angela Zhang on 7/24/13.
//  Copyright (c) 2013 Team Ubi. All rights reserved.
//

#import "AppDelegate.h"
#import <Parse/Parse.h>
#import "LoginViewController.h"
#import "RecentViewController.h"
#import "OptionsViewController.h"
#import "NewMessageViewController.h"
#import "FriendsViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

@synthesize window = _window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    //Set up Parse/Facebook interfacing
    [Parse setApplicationId:@"yCZ5bGegG7VMoZ4eYqXwiXAmFz1sU0yKLYpA0F9R" clientKey:@"XaJTZmXmJ3Hq1WjWuWACdTT549svsOo4BY7koW4C"];
    [GMSServices provideAPIKey:@"AIzaSyBTSqQBVPdVVKCPSGHdfTL3GEQQC7Y--hQ"];
    
    [PFFacebookUtils initializeFacebook];
  //  self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:[[LoginViewController alloc] init]];
    
    if ([PFUser currentUser]) {
        RecentViewController *rvc = [[RecentViewController alloc] init];
        UINavigationController *recentNavController = [[UINavigationController alloc]
                                             initWithRootViewController:rvc];
        [UIView  beginAnimations: @"Showinfo"context: nil];
        NewMessageViewController *nmvc = [[NewMessageViewController alloc] init];
        UINavigationController *newMessageNavController = [[UINavigationController alloc]                                                         initWithRootViewController:nmvc];

        
        FriendsViewController *fvc = [[FriendsViewController alloc] init];
        UINavigationController *friendsNavController = [[UINavigationController alloc]
                                                  initWithRootViewController:fvc];
        
        OptionsViewController *ovc = [[OptionsViewController alloc] init];
        UINavigationController *optionsNavController = [[UINavigationController alloc]
                                                        initWithRootViewController:ovc];
        
        UITabBarController *tabBarController = [[UITabBarController alloc] init];
        [tabBarController setViewControllers:@[recentNavController, newMessageNavController,
                                               friendsNavController, optionsNavController]];
        UITabBarItem *recentTab = [recentNavController tabBarItem];
        [recentTab setTitle:@"Recent Items"];
        UITabBarItem *newMessageTab = [newMessageNavController
                                       tabBarItem];
        [newMessageTab setTitle:@"New Message"];
        [newMessageTab setImage:[UIImage imageNamed:@"newMessage.png"]];
        UITabBarItem *friendsTab = [friendsNavController tabBarItem];
        [friendsTab setTitle:@"Friends"];
        UITabBarItem *optionsTab = [optionsNavController tabBarItem];
        [optionsTab setTitle:@"Options"];
        [optionsTab setImage:[UIImage imageNamed:@"options.png"]];
        
        [self.window setRootViewController:tabBarController];
    } else {
         [self presentLoginViewController];
    }
    
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [FBSession.activeSession close];
}

//Support for Facebook Single Sign-on
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [PFFacebookUtils handleOpenURL:url];
}

- (void)presentLoginViewController {
	// Go to the welcome screen and have them log in or create an account.
	LoginViewController *loginViewController = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
	loginViewController.title = @"Welcome to Ubi!";
	
	UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:loginViewController];
	navController.navigationBarHidden = YES;
    
	self.window.rootViewController = navController;
}


@end

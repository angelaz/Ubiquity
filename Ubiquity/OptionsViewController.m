//
//  OptionsViewController.m
//  Ubiquity
//
//  Created by Catherine Morrison on 7/24/13.
//  Copyright (c) 2013 Team Ubi. All rights reserved.
//

#import "OptionsViewController.h"
#import <Parse/Parse.h>
#import "AppDelegate.h"
@interface OptionsViewController ()

@end

@implementation OptionsViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (id)init
{
    self = [super init];
    if (self) {
        UINavigationItem *nav = [self navigationItem];
        [nav setTitle:@"Options"];
        UIBarButtonItem *logoutButton = [[UIBarButtonItem alloc] initWithTitle:@"Logout" style:UIBarButtonItemStylePlain target:self action:@selector(logoutButtonTouchHandler:)];
        [[self navigationItem] setRightBarButtonItem:logoutButton];
        UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                    target:self
                                                                                    action:@selector(dismissOptions)];
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [button addTarget:self
                   action:@selector(loginToTwitter)
         forControlEvents:UIControlEventTouchDown];
        [button setTitle:@"Twitter" forState:UIControlStateNormal];
        button.frame = CGRectMake(80.0, 210.0, 160.0, 40.0);
        [self.view addSubview:button];
        
        [[self navigationItem] setLeftBarButtonItem:backButton];
    }
    
    return self;
}
- (void)logoutButtonTouchHandler:(id)sender {
    
    [PFUser logOut];
    if ([PFUser currentUser] == nil)
    {
        NSLog(@"Successfully Logged out");
        //[self.navigationController pushViewController:[[RecentViewController alloc] init] animated:YES];
        LoginViewController *loginViewController = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
        [self.tabBarController setSelectedIndex:0];
        [self.tabBarController presentViewController:loginViewController animated:NO completion:nil];
    }
}
- (void)dismissOptions
{
    [self dismissViewControllerAnimated:YES completion:nil];
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
	// Do any additional setup after loading the view.
    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(nextTab:)];
    [swipeRight setDirection:UISwipeGestureRecognizerDirectionRight];
    [self.view addGestureRecognizer:swipeRight];

}

- (void)nextTab:(id)sender
{
    int controllerIndex = 1;
    
    UIView * fromView = self.tabBarController.selectedViewController.view;
    UIView * toView = [[self.tabBarController.viewControllers objectAtIndex:controllerIndex] view];
    
    // Transition using a page curl.
    [UIView transitionFromView:fromView toView:toView duration:0.5
                       options: (controllerIndex > self.tabBarController.selectedIndex ? UIViewAnimationOptionTransitionFlipFromRight : UIViewAnimationOptionTransitionFlipFromLeft)
                    completion:^(BOOL finished) {
                        
                        if (finished) {
                            self.tabBarController.selectedIndex = controllerIndex;
                        }
                        
                    }];
    
    [self.tabBarController setSelectedIndex: controllerIndex];
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) loginToTwitter {
//    [PFTwitterUtils logInWithBlock:^(PFUser *user, NSError *error) {
//        if (!user) {
//            NSLog(@"Uh oh. The user cancelled the Twitter login.");
//            return;
//        } else if (user.isNew) {
//            NSLog(@"User signed up and logged in with Twitter!");
//        } else {
//            NSLog(@"User logged in with Twitter!");
//        }    
//    }];
    
    if (![PFTwitterUtils isLinkedWithUser:[PFUser currentUser]]) {
        [PFTwitterUtils linkUser:[PFUser currentUser] block:^(BOOL succeeded, NSError *error) {
            if ([PFTwitterUtils isLinkedWithUser:[PFUser currentUser]]) {
                NSLog(@"Woohoo, user logged in with Twitter!");
            }
        }];
    }
}

- (void)save:(id)sender
{
    //FOR USE IF WE TURN THIS INTO A DISMISS BUTTON
    //[self dismissViewControllerAnimated:YES completion:nil];
    
    //  //  ExpenseItem *newItem = [[ExpenseItemStore sharedStore] createItem];
    //  //  DetailViewController *detailViewController = [[DetailViewController alloc] initForNewItem:YES];
    //  //  [detailViewController setItem:newItem];
    //
    //  //  [detailViewController setDismissBlock:^{[[self tableView] reloadData];}];
    //
    //  //  UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:detailViewController];
    //  //  [navController setModalPresentationStyle:UIModalPresentationFormSheet];
    //   // [navController setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
    //  //  [self presentViewController:navController
    //    //                   animated:YES
    //   //                  completion:nil];
}

@end

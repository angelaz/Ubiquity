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
//        UIBarButtonItem *bbi = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave
//                                                                             target:self
//                                                                             action:@selector(save:)];
        UIBarButtonItem *logoutButton = [[UIBarButtonItem alloc] initWithTitle:@"Logout" style:UIBarButtonItemStylePlain target:self action:@selector(logoutButtonTouchHandler:)];
        [[self navigationItem] setRightBarButtonItem:logoutButton];
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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

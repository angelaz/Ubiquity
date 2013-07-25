//
//  OptionsViewController.m
//  Ubiquity
//
//  Created by Catherine Morrison on 7/24/13.
//  Copyright (c) 2013 Team Ubi. All rights reserved.
//

#import "OptionsViewController.h"

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
        UIBarButtonItem *bbi = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                                                             target:self
                                                                             action:@selector(save:)];
        [[self navigationItem] setRightBarButtonItem:bbi];
    }
    
    return self;
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

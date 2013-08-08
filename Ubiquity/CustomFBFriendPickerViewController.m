//
//  CustomFBFriendPickerViewController.m
//  Ubiquity
//
//  Created by Winnie Wu on 7/31/13.
//  Copyright (c) 2013 Team Ubi. All rights reserved.
//

#import "CustomFBFriendPickerViewController.h"
#import "AppDelegate.h"

@interface CustomFBFriendPickerViewController () <FBFriendPickerDelegate, UISearchBarDelegate>

@end

@implementation CustomFBFriendPickerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"Add Friends";
        self.cancelButton = nil;

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

@end

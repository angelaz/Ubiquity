//
//  FriendsViewController.m
//  Ubiquity
//
//  Created by Angela Zhang on 7/24/13.
//  Copyright (c) 2013 Team Ubi. All rights reserved.
//

#import "FriendsViewController.h"
#import <Parse/Parse.h>

@interface FriendsViewController () <UITableViewDataSource, UITableViewDelegate, FBFriendPickerDelegate>
{

}
@end

@implementation FriendsViewController
- (id) init{
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        UINavigationItem *nav = [self navigationItem];
        [nav setTitle:@"Friends"];
        UIBarButtonItem *add = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                             target:self
                                                                             action:@selector(displayFriendPicker)];
        self.navigationItem.rightBarButtonItem = add;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    UINib *nib = [UINib nibWithNibName:@"FriendCell" bundle:nil];
    [[self tableView] registerNib:nib forCellReuseIdentifier:@"FriendCell"];

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSLog(@"%@", selectedFriends);
    [[self tableView] reloadData];
}

- (id)initWithStyle:(UITableViewStyle)style
{
    return [self init];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_allFriends count];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)displayFriendPicker
{
    if (!friendPickerController) {
        friendPickerController = [[FBFriendPickerViewController alloc]
                                  initWithNibName:nil bundle:nil];
        friendPickerController.delegate = self;
        friendPickerController.title = @"Select friends";
    }
    
    [friendPickerController loadData];
    [self.navigationController pushViewController:friendPickerController
                                         animated:true];
    
    selectedFriends = friendPickerController.selection; //need to instantiate this elsewhere
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = (UITableViewCell*)[tableView
                                               dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        cell.textLabel.font = [UIFont systemFontOfSize:16];
        cell.textLabel.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
        cell.textLabel.clipsToBounds = YES;
        
        cell.detailTextLabel.font = [UIFont systemFontOfSize:12];
        cell.detailTextLabel.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
        cell.detailTextLabel.textColor = [UIColor colorWithRed:0.4
                                                         green:0.6
                                                          blue:0.8
                                                         alpha:1];
        cell.detailTextLabel.clipsToBounds = YES;
    }
    
    cell.textLabel.text = [selectedFriends objectAtIndex:indexPath.row];
    return cell;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
@end

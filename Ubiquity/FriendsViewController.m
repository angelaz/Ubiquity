//
//  FriendsViewController.m
//  Ubiquity
//
//  Created by Angela Zhang on 7/24/13.
//  Copyright (c) 2013 Team Ubi. All rights reserved.
//

#import "FriendsViewController.h"

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
        //        ubiquityFriends = [PFObject objectWithClassName:@"UbiquityFriends"];
        //        ubiquityFriends.objectId = [[PFUser currentUser] objectForKey:@"profile"][@"facebookId"];
        //        if (!selectedFriends) selectedFriends = [[NSArray alloc] init];
        //        [ubiquityFriends setObject:selectedFriends forKey:@"friends"];
        //        [ubiquityFriends saveInBackground];
        //        NSLog(@"%@", ubiquityFriends.objectId);
        ////        if (!ubiquityFriends) {
        ////            selectedFriends = [[NSArray alloc] init];
        ////            [ubiquityFriends setObject:selectedFriends forKey:@"friends"];
        ////        }
        //        PFQuery *query = [PFQuery queryWithClassName:@"UbiquityFriends"];
        //        [query getObjectInBackgroundWithId:ubiquityFriends.objectId block:^(PFObject *friends, NSError *error) {
        //            // Do something with the returned PFObject in the gameScore variable.
        //            //selectedFriends = [friends objectForKey:@"friends"];
        //            if (!error) {
        //                NSLog(@"Here are my friends: %@", friends);
        //            } else {
        //                // Log details of the failure
        //                NSLog(@"Error: %@ %@", error, [error userInfo]);
        //            }
        //        }];
        
    }
    selectedFriends = [[NSArray alloc] init];
    PFACL *defaultACL = [PFACL ACL];
    [defaultACL setPublicReadAccess:YES];
    [defaultACL setPublicWriteAccess:YES];
    [PFACL setDefaultACL:defaultACL withAccessForCurrentUser:YES];
    ubiquityFriends = [PFObject objectWithClassName:@"UbiquityFriends"];
    ubiquityFriends.objectId = [[PFUser currentUser] objectForKey:@"profile"][@"facebookId"];
    [ubiquityFriends setObject:selectedFriends forKey:@"friends"];
    [ubiquityFriends setObject:[[PFUser currentUser] objectForKey:@"profile"][@"facebookId"] forKey:@"userID"];
    [ubiquityFriends saveInBackground];
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    PFQuery *query = [PFQuery queryWithClassName:@"UbiquityFriends"];
    //[query whereKey:@"userID" equalTo:[[PFUser currentUser] objectForKey:@"profile"][@"facebookId"]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *friends, NSError *error) {
        if (!error) {
            // The find succeeded.
            NSLog(@"Successfully retrieved %d friends.", friends.count);
            // Do something with the found objects
            for (PFObject *friend in friends) {
                NSLog(@"%@", friend.objectId);
            }
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
    [[self tableView] reloadData];
}
- (id)initWithStyle:(UITableViewStyle)style
{
    return [self init];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


//Friends Table View Logic
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [selectedFriends count];
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
        //        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        //        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        //
        //        cell.textLabel.font = [UIFont systemFontOfSize:16];
        //        cell.textLabel.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
        //        cell.textLabel.clipsToBounds = YES;
        //
        //        cell.detailTextLabel.font = [UIFont systemFontOfSize:12];
        //        cell.detailTextLabel.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
        //        cell.detailTextLabel.textColor = [UIColor colorWithRed:0.4
        //                                                         green:0.6
        //                                                          blue:0.8
        //                                                         alpha:1];
        //        cell.detailTextLabel.clipsToBounds = YES;
    }
    NSLog(@"%@", [selectedFriends objectAtIndex:indexPath.row]);
    NSDictionary *userData = [selectedFriends objectAtIndex:indexPath.row];
    NSString *facebookID = userData[@"id"];
    NSString *name = userData[@"name"];
    
    NSURL *pictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", facebookID]];
    NSData *data = [NSData dataWithContentsOfURL:pictureURL];
    UIImage *img = [UIImage imageWithData:data];
    cell.imageView.image = img;
    cell.imageView.layer.cornerRadius = 8.0f;
    cell.imageView.layer.frame = CGRectMake(0.0, 0.0, 75.0, 75.0); //I want to resize/crop these images
    cell.imageView.layer.masksToBounds = YES;                      //But that can be lower priority
    cell.textLabel.text = name;
    return cell;
}

// gets cropped FB profile pic sized image (not scaled though)
- (UIImage*) getSubImageFrom: (UIImage*) img WithRect: (CGRect) rect {
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGRect drawRect = CGRectMake(-rect.origin.x, -rect.origin.y, img.size.width, img.size.height);
    CGContextClipToRect(context, CGRectMake(0, 0, rect.size.width, rect.size.height));
    [img drawInRect:drawRect];
    UIImage* subImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return subImage;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    /* Implement loading/viewing/selecting a friend's saved public locations here */
    
}

//FriendPicker Display Logic
- (void)displayFriendPicker
{
    if (!friendPickerController) {
        friendPickerController = [[FBFriendPickerViewController alloc]
                                  initWithNibName:nil bundle:nil];
        friendPickerController.delegate = self;
        friendPickerController.cancelButton = nil;
        friendPickerController.title = @"Select friends";
    }
    
    [friendPickerController loadData];
    [self.navigationController pushViewController:friendPickerController
                                         animated:true];
}
- (void)friendPickerViewControllerSelectionDidChange:
(FBFriendPickerViewController *)friendPicker
{
    
    
}
- (void)facebookViewControllerDoneWasPressed:(id)sender {
    //Save friends
    selectedFriends = friendPickerController.selection;
    [ubiquityFriends setObject:friendPickerController.selection forKey:@"friends"];
    [ubiquityFriends saveInBackground];
    // Dismiss the friend picker
    [self.navigationController popToRootViewControllerAnimated:YES];
}
@end

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
        
        self.tableView.scrollEnabled = YES;
        
        selectedFriends = [[NSMutableArray alloc] init];
        
        PFQuery *query = [PFQuery queryWithClassName:@"UbiquityFriends"];
        [query whereKey:@"userID" equalTo:[[PFUser currentUser] objectId]];
        NSLog(@"the current user is %@", [[PFUser currentUser] objectId]);
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {   // The find succeeded.
                NSLog(@"Successfully retrieved %d objects.", objects.count);
                if ([objects count] > 0) {      //Saved friend list exists
                    for (PFObject *object in objects) {
                        ubiquityFriends = object;
                        selectedFriends = [object objectForKey:@"friends"];;   //Load saved friends
                    }
                } else {    //No saved friend list, instantiate new one
                    //Setting up PFObject
                    ubiquityFriends = [PFObject objectWithClassName:@"UbiquityFriends"];
                    [ubiquityFriends setObject:selectedFriends forKey:@"friends"];
                    [ubiquityFriends setObject:[[PFUser currentUser] objectId] forKey:@"userID"];
                    [ubiquityFriends setObject:[PFUser currentUser] forKey:@"user"];
                    //User read/write permissions
                    PFACL *defaultACL = [PFACL ACL];
                    [defaultACL setPublicReadAccess:YES];       //Everyone can see a given Ubiquity user's in-app friends
                    [defaultACL setPublicWriteAccess:NO];       //But only that user can modify their friend list
                    [defaultACL setWriteAccess:YES forUser:[PFUser currentUser]];
                    ubiquityFriends.ACL = defaultACL;
                }
                
            } else {        // Log details of the failure
                NSLog(@"Error: %@ %@", error, [error userInfo]);
            }
        }];
        
    }
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
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:CellIdentifier];
    }
    NSDictionary *userData = [selectedFriends objectAtIndex:indexPath.row];
    NSString *facebookID = userData[@"id"];
    NSString *name = userData[@"name"];
    
    FBProfilePictureView *profilePictureView = [[FBProfilePictureView alloc] init];
    profilePictureView.frame = CGRectMake(0.0, 0.0, 45.0, 45.0);
    profilePictureView.profileID = facebookID;
    [cell.imageView addSubview:profilePictureView];
    
//    NSURL *pictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", facebookID]];
//    NSData *imageData = [NSData dataWithContentsOfURL:pictureURL];
    cell.imageView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://www.faithlineprotestants.org/wp-content/uploads/2010/12/facebook-default-no-profile-pic.jpg"]]];
    //cell.imageView.image = [UIImage imageWithData:imageData];
    //cell.imageView.image = [self getSubImageFrom:[UIImage imageWithData:data] WithRect:CGRectMake(0.0, 0.0, 75.0, 75.0)];
    
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
        friendPickerController.title = @"Add Friends";
    }
    
    [friendPickerController loadData];
    [self.navigationController pushViewController:friendPickerController
                                         animated:true];

}
- (void)friendPickerViewControllerSelectionDidChange:
(FBFriendPickerViewController *)friendPicker
{
    for (id friend in friendPicker.selection) {
        if (![selectedFriends containsObject:friend]) {
            [selectedFriends addObject:friend];
        }
    }
}
- (void)facebookViewControllerDoneWasPressed:(id)sender {
    //Save friends
    [ubiquityFriends setObject:selectedFriends forKey:@"friends"];
    [ubiquityFriends saveInBackground];
    // Dismiss the friend picker
    [self.navigationController popToRootViewControllerAnimated:YES];
    NSLog(@"object ID is:%@", ubiquityFriends.objectId);
}
@end

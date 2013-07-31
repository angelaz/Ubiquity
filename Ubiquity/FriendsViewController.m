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
        userLoggedIn = NO;
        if ([PFUser currentUser])
        {
            userLoggedIn = YES;
            UINavigationItem *nav = [self navigationItem];
            [nav setTitle:@"Friends"];
            UIBarButtonItem *add = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                                 target:self
                                                                                 action:@selector(displayFriendPicker)];
            self.navigationItem.rightBarButtonItem = add;
            
            UIBarButtonItem *remove = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash
                                                                                    target:self
                                                                                    action:@selector(removeFriends)];
            self.navigationItem.leftBarButtonItem = remove;
            
            self.tableView.scrollEnabled = YES;
            
            selectedFriends = [[NSMutableArray alloc] init];
            
            PFQuery *query = [PFQuery queryWithClassName:@"UbiquityFriends"];
            [query whereKey:@"userID" equalTo:[[PFUser currentUser] objectId]];
            NSLog(@"the current user is %@", [[PFUser currentUser] objectId]);

            
            
//            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
//                if (!error) {   // The find succeeded.
//                    NSLog(@"Successfully retrieved %d objects.", objects.count);
//                    if ([objects count] > 0) {      //Saved friend list exists
//                        for (PFObject *object in objects) {
//                            ubiquityFriends = object;
//                            selectedFriends = [object objectForKey:@"friends"];;   //Load saved friends
//                        }
//                    } else {    //No saved friend list, instantiate new one
//                        //Setting up PFObject
//                        ubiquityFriends = [PFObject objectWithClassName:@"UbiquityFriends"];
//                        [ubiquityFriends setObject:selectedFriends forKey:@"friends"];
//                        [ubiquityFriends setObject:[[PFUser currentUser] objectId] forKey:@"userID"];
//                        [ubiquityFriends setObject:[PFUser currentUser] forKey:@"user"];
//                        //User read/write permissions
//                        PFACL *defaultACL = [PFACL ACL];
//                        [defaultACL setPublicReadAccess:YES];       //Everyone can see a given Ubiquity user's in-app friends
//                        [defaultACL setPublicWriteAccess:NO];       //But only that user can modify their friend list
//                        [defaultACL setWriteAccess:YES forUser:[PFUser currentUser]];
//                        ubiquityFriends.ACL = defaultACL;
//                    }
//                    
//                } else {        // Log details of the failure
//                    NSLog(@"Error: %@ %@", error, [error userInfo]);
//                }
//            }];
        }
    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    if (!userLoggedIn)
        [self init];

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
    
    //Gray out a cell if that friend doesn't use Parse
    PFQuery *findUsers = [PFQuery queryWithClassName:@"_User"];
    [findUsers whereKey:@"fbId" equalTo:facebookID];
    [findUsers findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {   // The find succeeded.
            if (objects.count == 0) {               //This user doesn't use Ubiquity
                cell.textLabel.textColor = [UIColor lightGrayColor];
                UIButton *inviteFriendButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
                inviteFriendButton.frame = CGRectMake(cell.bounds.size.width - 60, 5.0f, 60.0f, 44.0f);
                [inviteFriendButton setTitle:@"Invite" forState:UIControlStateNormal];
                [inviteFriendButton addTarget:self
                                       action:@selector(inviteFriendforUser:)
                             forControlEvents:UIControlEventTouchUpInside];
                [cell addSubview:inviteFriendButton];
            }
        } else {        // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
    
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

- (void)inviteFriendforUser:(PFUser *) user
{
    /* Implement inviting friends to the Ubiquity app here */
    NSLog(@"Heyyo. You tried to invite a friend but this isn't implemented yet. Sadface.");
}

- (void)removeFriends
{
    if (self.tableView.editing == NO) {
        [self.tableView setEditing:YES animated:YES];
    } else {
        [self.tableView setEditing:NO animated:YES];
        [ubiquityFriends setObject:selectedFriends forKey:@"friends"];
        [ubiquityFriends saveInBackground];
    }
    
}
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [selectedFriends removeObjectAtIndex:indexPath.row];
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.tableView setEditing:NO animated:YES];
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
            //NSLog(@"the current friend: %@", friend);
            
            //NSLog(@"fbId = %@", [friend objectForKey:@"id"]);
            
            PFQuery *query = [PFQuery queryWithClassName:@"_User"];
            [query whereKey:@"fbId" equalTo:[friend objectForKey:@"id"]];

            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                if (!error) {
                    // The find succeeded.
                    NSLog(@"Successfully retrieved %d friends.", objects.count);
                    // Do something with the found objects
                    if(objects.count > 0) {
                        //There really should be only one return here, max
                        for (PFObject *object in objects) {
                            if(objects.count > 0) {
                                
                                PFObject *me = [PFUser currentUser];
                                PFRelation *relation = [object relationforKey:@"follows"];
                                [relation addObject:me];
                                [me saveInBackground];
                                NSLog(@"Saved relation");
                            }
                        }
                    } else {
                        //MAKE NEW TEMP USER? INVITE BUTTON? GRAY OUT?
                    }
                } else {
                    // Log details of the failure
                    NSLog(@"Error: %@ %@", error, [error userInfo]);
                }
            }];
            
            
//            PFObject *me = [PFUser currentUser];
//            PFRelation *relation = [friend relationforKey:@"follows"];
//            [relation addObject:me];
//            [me saveInBackground];
        
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

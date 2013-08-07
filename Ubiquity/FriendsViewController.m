//
//  FriendsViewController.m
//  Ubiquity
//
//  Created by Angela Zhang on 7/24/13.
//  Copyright (c) 2013 Team Ubi. All rights reserved.
//

#import "FriendsViewController.h"

@interface FriendsViewController () <UITableViewDataSource, UITableViewDelegate, FBFriendPickerDelegate, UISearchBarDelegate>
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

            PFRelation *relation = [[PFUser currentUser] relationforKey:@"follows"];
            PFQuery *query = [relation query];
            
            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                if (!error) {   // The find succeeded.
                    if ([objects count] > 0) {      //Saved friend list exists
                        selectedFriends = [[NSMutableArray alloc] initWithArray:objects];
                    } else {    //No saved friend list.
                        selectedFriends = [[NSMutableArray alloc] init];
                    }
                } else {        // Log details of the failure
                    //NSLog(@"Error: %@ %@", error, [error userInfo]);
                }
            }];
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
    [super viewWillAppear:NO];
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

    
    NSString *facebookID = [userData objectForKey:@"fbId"];//userData[@"id"];
    NSString *name = [userData objectForKey:@"profile"][@"name"];//userData[@"name"];
    NSLog(@"Current user: %@", name);
    FBProfilePictureView *profilePictureView = [[FBProfilePictureView alloc] init];
    profilePictureView.frame = CGRectMake(0.0, 0.0, 45.0, 45.0);
    profilePictureView.profileID = facebookID;
    [cell.imageView addSubview:profilePictureView];
    cell.imageView.image = [UIImage imageNamed:@"pixel"];
    cell.textLabel.text = name;
    
    //Gray out a cell if that friend doesn't use Parse
    if ([PFAnonymousUtils isLinkedWithUser:[selectedFriends objectAtIndex:indexPath.row]]) { //Anonymous user, not registered for Parse!
        cell.textLabel.textColor = [UIColor lightGrayColor];
        UIButton *inviteFriendButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        inviteFriendButton.frame = CGRectMake(cell.bounds.size.width - 60, 5.0f, 60.0f, 44.0f);
        [inviteFriendButton setTitle:@"Invite" forState:UIControlStateNormal];
        [inviteFriendButton addTarget:self
                               action:@selector(inviteFriendforUser:)
                     forControlEvents:UIControlEventTouchUpInside];
        [cell addSubview:inviteFriendButton];
    }
//    NSPredicate *predicate = [NSPredicate predicateWithFormat:
//                              @"authData != 'Anonymous'"];
//    PFQuery *findUsers = [PFQuery queryWithClassName:@"_User" predicate:predicate];
//    [findUsers findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
//        if (!error) {   // The find succeeded.
//            if (objects.count == 0) {               //This user doesn't use Ubiquity
//                cell.textLabel.textColor = [UIColor lightGrayColor];
//                UIButton *inviteFriendButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
//                inviteFriendButton.frame = CGRectMake(cell.bounds.size.width - 60, 5.0f, 60.0f, 44.0f);
//                [inviteFriendButton setTitle:@"Invite" forState:UIControlStateNormal];
//                [inviteFriendButton addTarget:self
//                                       action:@selector(inviteFriendforUser:)
//                             forControlEvents:UIControlEventTouchUpInside];
//                [cell addSubview:inviteFriendButton];
//            }
//            for (id object in objects) {
//                NSLog(@"This person DOES use parse: %@", object);
//            }
//        } else {        // Log details of the failure
//            NSLog(@"Error: %@ %@", error, [error userInfo]);
//        }
//    }];
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
    NSLog(@"%@", [selectedFriends objectAtIndex:indexPath.row]);
    
}

- (void)inviteFriendforUser:(PFUser *) user
{
    /* Implement inviting friends to the Ubiquity app here */
    NSLog(@"Trying to invite friend!");
    NSMutableDictionary* params =   [NSMutableDictionary dictionaryWithObjectsAndKeys:nil];
    [FBWebDialogs presentRequestsDialogModallyWithSession:nil
                                                  message:[NSString stringWithFormat:@"Join Ubiquity so you can send and receive messages from me!"]
                                                    title:nil
                                               parameters:params
                                                  handler:^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
                                                      if (error) {
                                                          // Case A: Error launching the dialog or sending request.
                                                          NSLog(@"Error sending request.");
                                                      } else {
                                                          if (result == FBWebDialogResultDialogNotCompleted) {
                                                              // Case B: User clicked the "x" icon
                                                              NSLog(@"User canceled request.");
                                                          } else {
                                                              NSLog(@"Request Sent.");
                                                          }
                                                      }}];
}

- (void)removeFriends
{
    
    if (self.tableView.editing == NO) {
        [self.tableView setEditing:YES animated:YES];

    } else {
        [self.tableView setEditing:NO animated:YES];
        //TODO
        //REMOVE FRIENDS WHEN REMOVED
        
//        [ubiquityFriends setObject:selectedFriends forKey:@"friends"];
//        [ubiquityFriends saveInBackground];

    }
    
}
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        [friendPickerController.selection removeObject: [selectedFriends objectAtIndex:indexPath.row]];
        [selectedFriends removeObjectAtIndex:indexPath.row];
        
        
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.tableView setEditing:NO animated:NO];
}

//Search bar
- (void)addSearchBarToFriendPickerView
{
    if (friendPickerController.searchBar == nil) {
        CGFloat searchBarHeight = 44.0;
        friendPickerController.searchBar =
        [[UISearchBar alloc]
         initWithFrame:
         CGRectMake(0,0,
                    self.view.bounds.size.width,
                    searchBarHeight)];
        friendPickerController.searchBar.autoresizingMask = friendPickerController.searchBar.autoresizingMask |
        UIViewAutoresizingFlexibleWidth;
        friendPickerController.searchBar.delegate = self;
        friendPickerController.searchBar.showsCancelButton = YES;
        
        [friendPickerController.canvasView addSubview:friendPickerController.searchBar];
        CGRect newFrame = self.view.bounds;
        newFrame.size.height -= searchBarHeight;
        newFrame.origin.y = searchBarHeight;
        self.tableView.frame = newFrame;
    }
}
- (void) handleSearch:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    friendPickerController.searchText = searchBar.text;
    [friendPickerController updateView];
}
- (void)searchBarSearchButtonClicked:(UISearchBar*)searchBar
{
    [self handleSearch:searchBar];
}
- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar {
    friendPickerController.searchText = nil;
    [searchBar resignFirstResponder];
}
- (BOOL)friendPickerViewController:(FBFriendPickerViewController *)friendPicker
                 shouldIncludeUser:(id<FBGraphUser>)user
{
    if (friendPickerController.searchText && ![friendPickerController.searchText isEqualToString:@""]) {
        NSRange result = [user.name
                          rangeOfString:friendPickerController.searchText
                          options:NSCaseInsensitiveSearch];
        if (result.location != NSNotFound) {
            return YES;
        } else {
            return NO;
        }
    } else {
        return YES;
    }
    return YES;
}

//FriendPicker Display Logic
- (void)displayFriendPicker
{
    if (!friendPickerController) {
        friendPickerController = [[CustomFBFriendPickerViewController alloc]
                                  initWithNibName:nil bundle:nil];
        friendPickerController.delegate = self;
    }
    [friendPickerController loadData];
    //[self addSearchBarToFriendPickerView];
//    [self.navigationController pushViewController:friendPickerController
//                                         animated:true];
    [self.navigationController presentViewController:friendPickerController
                       animated:YES
                     completion:^(void){
                         [self addSearchBarToFriendPickerView];
                     }
     ];
    
    
}
- (void)friendPickerViewControllerSelectionDidChange:
(FBFriendPickerViewController *)friendPicker
{
    for (id<FBGraphUser> user in friendPicker.selection) {
            
        PFQuery *query = [PFQuery queryWithClassName:@"_User"];
        [query whereKey:@"fbId" equalTo:[user id]];

        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                // The find succeeded.
                //NSLog(@"Successfully retrieved %d friends.", objects.count);
                if(objects.count > 0) {
                    //There really should be only one return here, max
                    for (PFObject *object in objects) {
                        if(objects.count > 0) {
                            
                            PFObject *me = [PFUser currentUser];
                            PFRelation *relation = [me relationforKey:@"follows"];
                            [relation addObject:object];
                            [me saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                                if (!error) {
                                    //NSLog(@"Success saving relation");
                                    [selectedFriends addObject:object];
                                } else {
                                    //NSLog(@"Error saving relation");
                                }
                            }];
                            //NSLog(@"Saved relation");
                        }
                    }
                } else {
                    [PFAnonymousUtils logInWithBlock:^(PFUser *newGuy, NSError *e) {
                    if(!e) {
                        PFObject *me = [PFUser currentUser];
                        PFRelation *relation = [me relationforKey:@"follows"];
                        [relation addObject:newGuy];
                        [me saveInBackgroundWithBlock:nil];
                        
                        [newGuy setObject:user.id forKey:@"fbId"];
                        [newGuy setObject:user    forKey:@"profile"];
                        [newGuy saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                            if(!error) {
                                [selectedFriends addObject:newGuy];
                            }
                        }];
                    } else {
                        NSLog(@"%@", e);
                    }

                    }];
                }
            }
            }];
            
            
//            PFObject *me = [PFUser currentUser];
//            PFRelation *relation = [friend relationforKey:@"follows"];
//            [relation addObject:me];
//            [me saveInBackground];
        
        //}
    }
}
- (void)facebookViewControllerDoneWasPressed:(id)sender {
    //Save friends
    //selectedFriends = friendPickerController.selection;
    
    
//    [ubiquityFriends setObject:friendPickerController.selection forKey:@"friends"];
//
//    [ubiquityFriends saveInBackground];
    // Dismiss the friend picker
    //[self.navigationController popToRootViewControllerAnimated:YES];
    //NSLog(@"object ID is:%@", ubiquityFriends.objectId);
    [self dismissModalViewControllerAnimated:YES];
}
@end

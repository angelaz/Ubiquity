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
        
        selectedFriends = [[NSArray alloc] init];
        
        PFQuery *query = [PFQuery queryWithClassName:@"UbiquityFriends"];
        [query whereKey:@"userID" equalTo:[[PFUser currentUser] objectId]];
        NSLog(@"the current user is %@", [[PFUser currentUser] objectId]);
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {   // The find succeeded.
                NSLog(@"Successfully retrieved %d objects.", objects.count);
                if ([objects count] > 0) {      //Saved friend list exists
                    for (PFObject *object in objects) {
                        NSLog(@"%@", object.objectId);
                        NSArray *friendList = [object objectForKey:@"friends"];
                        selectedFriends = friendList;   //Load saved friends
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
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:CellIdentifier];
    }
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
    selectedFriends = friendPickerController.selection;
    [ubiquityFriends setObject:friendPickerController.selection forKey:@"friends"];
    [ubiquityFriends saveInBackground];
    
}
- (void)facebookViewControllerDoneWasPressed:(id)sender {
    //Save friends
    selectedFriends = friendPickerController.selection;
    [ubiquityFriends setObject:friendPickerController.selection forKey:@"friends"];
    [ubiquityFriends saveInBackground];
    // Dismiss the friend picker
    [self.navigationController popToRootViewControllerAnimated:YES];
    NSLog(@"object ID is:%@", ubiquityFriends.objectId);
}
@end

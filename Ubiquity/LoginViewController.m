//

#import "LoginViewController.h"
#import "UserDetailsViewController.h"
#import <Parse/Parse.h>
#import "RecentViewController.h"
#import "AppDelegate.h"

@implementation LoginViewController


#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Facebook Profile";
    
    // Check if user is cached and linked to Facebook, if so, bypass login    
//    if ([PFUser currentUser] && [PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]) {
//        [self.navigationController pushViewController:[[RecentViewController alloc] init] animated:YES];
//    }
}


#pragma mark - Login mehtods

/* Login to facebook method */
- (IBAction)loginButtonTouchHandler:(id)sender  {
    // Set permissions required from the facebook user account
    NSArray *permissionsArray = @[ @"user_about_me", @"user_relationships", @"user_birthday", @"user_location"];
    
    // Login PFUser using facebook
    [PFFacebookUtils logInWithPermissions:permissionsArray block:^(PFUser *user, NSError *error) {
        [_activityIndicator stopAnimating]; // Hide loading indicator
        
        if (!user) {
            if (!error) {
                NSLog(@"Uh oh. The user cancelled the Facebook login.");
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Log In Error" message:@"Uh oh. The user cancelled the Facebook login." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Dismiss", nil];
                [alert show];
            } else {
                NSLog(@"Uh oh. An error occurred: %@", error);
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Log In Error" message:[error description] delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Dismiss", nil];
                [alert show];
            }
        } else if (user.isNew) {
            NSLog(@"User with facebook signed up and logged in!");
            [self pullFBDataAndOrganize];
            
            [self dismissViewControllerAnimated:YES completion:nil];
//            self.navigationController.navigationBarHidden = NO;
//            [self.navigationController pushViewController:[[RecentViewController alloc] init] animated:YES];
            
        } else {
            NSLog(@"User with facebook logged in!");

            [self pullFBDataAndOrganize];
            
            [self dismissViewControllerAnimated:YES completion:nil];
            self.tabBarController.selectedIndex = 0;

        }
    }];
    RecentViewController *recent = [[RecentViewController alloc] init];
    [recent startStandardUpdates];
    
    [_activityIndicator startAnimating]; // Show loading indicator until login is finished
}

- (void) linkOrStoreUserDetails:(NSDictionary *)userData toId:(id)facebookID {
    //Check for data which needs linking
    
    PFQuery *checkIfExists = [PFQuery queryWithClassName:@"UserData"];
    NSLog(@"%@", [PFUser currentUser]);
    
    [checkIfExists whereKey:@"facebookId" equalTo:facebookID];
    [checkIfExists findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            //If the user already has a stub
            if([objects count] > 0) {
                for(PFObject *o in objects) {
                    //Update the profile
                    [o setObject:userData forKey:@"profile"];

                    //Link that profile to this one
                    //Also serves to update existing accounts
                    [[PFUser currentUser] setObject:o   forKey:@"userData"];
                    [[PFUser currentUser] setObject:facebookID forKey:@"fbId"];
                    [[PFUser currentUser] saveInBackground];
                }
                //If the user is brand new, no stub found for them
            } else {
                //Make new user data object
                PFObject *userDataObject = [PFObject objectWithClassName:@"UserData"];
                [userDataObject setObject:userData forKey:@"profile"];
                [userDataObject setObject:facebookID forKey:@"facebookId"];
                [userDataObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    //Once you make it, save the link
                    [[PFUser currentUser] setObject:userDataObject forKey:@"userData"];
                    [[PFUser currentUser] setObject:facebookID forKey:@"fbId"];
                    [[PFUser currentUser] saveInBackground];
                }];
                
            }
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];

}

- (void) pullFBDataAndOrganize {
    // Send request to Facebook
    FBRequest *request = [FBRequest requestForMe];
    [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        // handle response
        if (!error) {
            // Parse the data received
            NSMutableDictionary *userData = (NSMutableDictionary *)result;
            
            NSString *facebookID = userData[@"id"];
            
            NSURL *pictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", facebookID]];
            
            
//            NSMutableDictionary *userProfile = [NSMutableDictionary dictionaryWithCapacity:7];
//            
//            if (facebookID) {
//                userProfile[@"facebookId"] = facebookID;
//            }
//            
//            if (userData[@"name"]) {
//                userProfile[@"name"] = userData[@"name"];
//            }
//            
//            if (userData[@"location"][@"name"]) {
//                userProfile[@"location"] = userData[@"location"][@"name"];
//            }
//            
//            if (userData[@"gender"]) {
//                userProfile[@"gender"] = userData[@"gender"];
//            }
//            
//            if (userData[@"birthday"]) {
//                userProfile[@"birthday"] = userData[@"birthday"];
//            }
//            
//            if (userData[@"relationship_status"]) {
//                userProfile[@"relationship"] = userData[@"relationship_status"];
//            }
            
            if ([pictureURL absoluteString]) {
                userData[@"pictureURL"] = [pictureURL absoluteString];
            }
            
            [self linkOrStoreUserDetails:userData toId:facebookID];
            
            //[self updateProfile];
        } else if ([[[[error userInfo] objectForKey:@"error"] objectForKey:@"type"]
                    isEqualToString: @"OAuthException"]) { // Since the request failed, we can check if it was due to an invalid session
            NSLog(@"The facebook session was invalidated");
        } else {
            NSLog(@"Some other error: %@", error);
        }
    }];

}


// Set received values if they are not nil and reload the table
//- (void)updateProfile {
//    if ([[PFUser currentUser] objectForKey:@"profile"][@"location"]) {
//        [self.rowDataArray replaceObjectAtIndex:0 withObject:[[PFUser currentUser] objectForKey:@"profile"][@"location"]];
//    }
//    
//    if ([[PFUser currentUser] objectForKey:@"profile"][@"gender"]) {
//        [self.rowDataArray replaceObjectAtIndex:1 withObject:[[PFUser currentUser] objectForKey:@"profile"][@"gender"]];
//    }
//    
//    if ([[PFUser currentUser] objectForKey:@"profile"][@"birthday"]) {
//        [self.rowDataArray replaceObjectAtIndex:2 withObject:[[PFUser currentUser] objectForKey:@"profile"][@"birthday"]];
//    }
//    
//    if ([[PFUser currentUser] objectForKey:@"profile"][@"relationship"]) {
//        [self.rowDataArray replaceObjectAtIndex:3 withObject:[[PFUser currentUser] objectForKey:@"profile"][@"relationship"]];
//    }
//    
//    [self.tableView reloadData];
//    
//    // Set the name in the header view label
//    if ([[PFUser currentUser] objectForKey:@"profile"][@"name"]) {
//        self.headerNameLabel.text = [[PFUser currentUser] objectForKey:@"profile"][@"name"];
//    }
//    
//    // Download the user's facebook profile picture
//    self.imageData = [[NSMutableData alloc] init]; // the data will be loaded in here
//    
//    if ([[PFUser currentUser] objectForKey:@"profile"][@"pictureURL"]) {
//        NSURL *pictureURL = [NSURL URLWithString:[[PFUser currentUser] objectForKey:@"profile"][@"pictureURL"]];
//        
//        NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:pictureURL
//                                                                  cachePolicy:NSURLRequestUseProtocolCachePolicy
//                                                              timeoutInterval:2.0f];
//        // Run network request asynchronously
//        NSURLConnection *urlConnection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
//        if (!urlConnection) {
//            NSLog(@"Failed to download picture");
//        }
//    }
//}


@end

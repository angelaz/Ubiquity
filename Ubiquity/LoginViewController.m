//

#import "LoginViewController.h"
#import "UserDetailsViewController.h"
#import <Parse/Parse.h>
#import "AppDelegate.h"
#import "LoginView.h"
#import "WallPostsViewController.h"

@implementation LoginViewController


#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Facebook Profile";
    LoginView *view = [[LoginView alloc] initWithFrame: [UIScreen mainScreen].bounds];
    [self setView: view];
    [view.loginButton addTarget:self action:@selector(loginButtonTouchHandler:) forControlEvents:UIControlEventTouchUpInside];

    // Check if user is cached and linked to Facebook, if so, bypass login
//    if ([PFUser currentUser] && [PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]) {
//        [self.navigationController pushViewController:[[RecentViewController alloc] init] animated:YES];
//    }
}


#pragma mark - Login mehtods

/* Login to facebook method */
- (void)loginButtonTouchHandler:(id)sender  {
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
            [self pullMyFBDataAndOrganize];
            
            [self.navigationController pushViewController:[[WallPostsViewController alloc] init] animated:YES];
            
        } else {
            NSLog(@"User with facebook logged in!");

            [self pullMyFBDataAndOrganize];
            
            [self dismissViewControllerAnimated:YES completion:nil];
            self.tabBarController.selectedIndex = 0;

        }
    }];
    WallPostsViewController *wallPosts = [[WallPostsViewController alloc] init];
    
    [_activityIndicator startAnimating]; // Show loading indicator until login is finished
}



- (void) pullMyFBDataAndOrganize {
    // Send request to Facebook
    FBRequest *request = [FBRequest requestForMe];
    [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        // handle response
        if (!error) {
            // Parse the data received
            NSMutableDictionary *userData = (NSMutableDictionary *)result;
            
            NSString *facebookID = userData[@"id"];
            
            NSURL *pictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", facebookID]];
            
            if ([pictureURL absoluteString]) {
                userData[@"pictureURL"] = [pictureURL absoluteString];
            }
            
            //Paradigm for storing this data to the current user
            [AppDelegate linkOrStoreUserDetails:userData
                                           toId:facebookID
                                         toUser:[PFUser currentUser]
                          andStoreUnderRelation:nil
                                       toObject:nil
                                     finalBlock:nil
             ];
            
            
            //[self updateProfile];
        } else if ([[[[error userInfo] objectForKey:@"error"] objectForKey:@"type"]
                    isEqualToString: @"OAuthException"]) { // Since the request failed, we can check if it was due to an invalid session
            NSLog(@"The facebook session was invalidated");
        } else {
            NSLog(@"Some other error: %@", error);
        }
    }];
}

@end

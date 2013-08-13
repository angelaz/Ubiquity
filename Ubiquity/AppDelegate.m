//
//  AppDelegate.m
//  Ubiquity
//
//  Created by Angela Zhang on 7/24/13.
//  Copyright (c) 2013 Team Ubi. All rights reserved.
//

#import "AppDelegate.h"
#import <Parse/Parse.h>
#import "LoginViewController.h"
#import "OptionsViewController.h"
#import "NewMessageViewController.h"
#import "FriendsViewController.h"
#import <GoogleMaps/GoogleMaps.h>
#import "WallPostsViewController.h"
#import "HomeMapViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

@synthesize window = _window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    //Set up Parse/Facebook interfacing
    [Parse setApplicationId:@"yCZ5bGegG7VMoZ4eYqXwiXAmFz1sU0yKLYpA0F9R" clientKey:@"XaJTZmXmJ3Hq1WjWuWACdTT549svsOo4BY7koW4C"];
    [GMSServices provideAPIKey:@"AIzaSyBTSqQBVPdVVKCPSGHdfTL3GEQQC7Y--hQ"];
    [PFFacebookUtils initializeFacebook];
    [PFTwitterUtils initializeWithConsumerKey:@"bk8P1pWhDoqSeQrbCo1A"
                               consumerSecret:@"p3A2h5FavogvCu2eBh7Jyegf9fAYpk9zTVW4ZBq7KA"];
    
    self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:[[HomeMapViewController alloc] init]];

    [UINavigationBar appearance].tintColor = mainThemeColor;

    // register for push notifications
    [application registerForRemoteNotificationTypes:
     UIRemoteNotificationTypeBadge |
     UIRemoteNotificationTypeAlert |
     UIRemoteNotificationTypeSound];
    
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    if ([PFUser currentUser] == nil) {
        [self presentLoginViewController];
    }
    
    return YES;
}


// if push notification registration is successful
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    // Store the deviceToken in the current installation and save it to Parse.
    [PFPush storeDeviceToken:deviceToken];
    [PFPush subscribeToChannelInBackground:@""];
    
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    [currentInstallation saveInBackground];
    NSLog(@"Registered for push");
}


- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSLog(@"Failed to register for push, %@", error);
}

// method for handling when push notif is received while app is open/in foreground
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [PFPush handlePush:userInfo];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [FBSession.activeSession close];
}

//Support for Facebook Single Sign-on
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [PFFacebookUtils handleOpenURL:url];
}

- (void)presentLoginViewController {
	// Go to the welcome screen and have them log in or create an account.
	LoginViewController *loginViewController = [[LoginViewController alloc] init];
	loginViewController.title = @"Welcome to Ubi!";
    [self.window.rootViewController presentViewController:loginViewController animated:NO completion:nil];
	
    //	UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:loginViewController];
    //	navController.navigationBarHidden = YES;
    //
    //	self.window.rootViewController = navController;
}

+ (void) linkOrStoreUserDetails:(NSObject *)userData        //Dict of info
                           toId:(id)facebookID              //FB ID
                         toUser:(PFUser *)user              //If there's already a user, add it to them
          andStoreUnderRelation:(NSString *)relationLabel   //If there's a relation to store under, called this
                       toObject:(PFObject *) object         //Related under this object
                     finalBlock:(void(^)(PFObject *made))finalBlock   //Then do this after finishing
    {
    
    //Check for data which needs linking
    
    PFQuery *checkIfExists = [PFQuery queryWithClassName:@"UserData"];
    
    [checkIfExists whereKey:@"facebookId" equalTo:facebookID];
    [checkIfExists findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            //If the user already has a stub
            if([objects count] > 0) {
                for(PFObject *o in objects) {
                    //Update the profile
                    [o setObject:userData forKey:@"profile"];
                    [o setObject:facebookID forKey:@"facebookId"];
                    
                    //Link that profile to this one
                    //Also serves to update existing accounts
                    if(user != nil) {
                        [user setObject:o   forKey:@"userData"];
                        [user setObject:facebookID forKey:@"fbId"];
                        [user saveInBackgroundWithBlock:^(BOOL suceeded, NSError *error){
                            finalBlock(o);
                        }];
                    }
                    
                    if (relationLabel != nil) {
                        PFRelation *relation = [object relationforKey:relationLabel];
                        [relation addObject:o];
                        [object saveInBackgroundWithBlock:^(BOOL suceeded, NSError *error) {
                            finalBlock(o);
                        }];
                    }
                    
                }
            
                //If the user is brand new, no stub found for them
            } else {
                //Make new user data object
                PFObject *userDataObject = [PFObject objectWithClassName:@"UserData"];
                [userDataObject setObject:userData forKey:@"profile"];
                [userDataObject setObject:facebookID forKey:@"facebookId"];
                [userDataObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    NSLog(@"%@", error);
                    
                    //Once you make it, save the link
                    if(user != nil) {
                        [user setObject:userDataObject forKey:@"userData"];
                        [user setObject:facebookID forKey:@"fbId"];
                        [user saveInBackgroundWithBlock:^(BOOL suceeded, NSError *error){
                            finalBlock(userDataObject);
                        }];
                    }
                    if (relationLabel != nil) {
                        PFRelation *relation = [object relationforKey:relationLabel];
                        [relation addObject:userDataObject];
                        [object saveInBackgroundWithBlock:^(BOOL suceeded, NSError *error) {
                            finalBlock(userDataObject);
                        }];
                    }
                    
                }];
            }
        }
    }];
}


@end

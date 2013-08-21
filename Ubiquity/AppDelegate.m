//
//  AppDelegate.m
//  Ubiquity
//
//  Created by Angela Zhang on 7/24/13.
//  Copyright (c) 2013 Team Ubi. All rights reserved.
//

#import "AppDelegate.h"
#import "OptionsViewController.h"
#import "NewMessageViewController.h"
#import "WallPostsViewController.h"
#import "HomeMapViewController.h"
#import "LocationController.h"


static AppDelegate *launchedDelegate;

@interface AppDelegate ()

@end

@implementation AppDelegate

@synthesize window = _window;
@synthesize rdio;

+ (Rdio *)rdioInstance
{
    return launchedDelegate.rdio;
}

+ (NSMutableArray *)postsByPublic
{
    return launchedDelegate.publicArray;
}

+ (NSMutableArray *)postsByFriends
{
    return launchedDelegate.friendsArray;
}

+ (NSMutableArray *)postsBySelf
{
    return launchedDelegate.selfArray;
}

+ (PFObject *)publicUser
{
    return launchedDelegate.publicUserObject;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    //Parse
    [Parse setApplicationId:@"yCZ5bGegG7VMoZ4eYqXwiXAmFz1sU0yKLYpA0F9R" clientKey:@"XaJTZmXmJ3Hq1WjWuWACdTT549svsOo4BY7koW4C"];
    [[[PFUser currentUser] objectForKey:@"userData"] fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error){}];
    [[[PFUser currentUser] objectForKey:@"facebookId"] fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error){}];

    [PFFacebookUtils initializeFacebook];
    
    //Google Maps
    [GMSServices provideAPIKey:@"AIzaSyBTSqQBVPdVVKCPSGHdfTL3GEQQC7Y--hQ"];
    
    //Twitter
    [PFTwitterUtils initializeWithConsumerKey:@"bk8P1pWhDoqSeQrbCo1A"
                               consumerSecret:@"p3A2h5FavogvCu2eBh7Jyegf9fAYpk9zTVW4ZBq7KA"];
    
    //Rdio
    launchedDelegate = self;
    rdio = [[Rdio alloc] initWithConsumerKey:@"5zk8jxx8g6kj2yyttbmdvqkt" andSecret:@"fPYZqmPDPG" delegate:nil];
    
    launchedDelegate.selfArray = [[NSMutableArray alloc] init];
    launchedDelegate.friendsArray = [[NSMutableArray alloc] init];
    launchedDelegate.publicArray = [[NSMutableArray alloc] init];
    
    PFQuery *query = [PFQuery queryWithClassName:@"UserData"];
    [query whereKey:@"facebookId" equalTo:[NSString stringWithFormat:@"100006434632076"]];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        self.publicUserObject = object;
    }];

    
    self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:[[HomeMapViewController alloc] init]];
    
    UIColor *color = lighterThemeColor;
    [[UINavigationBar appearance] setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setBackgroundColor:color];
    //[UINavigationBar appearance].tintColor = color;
    [[UIBarButtonItem appearance] setBackgroundImage:[[UIImage alloc] init] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [[UIBarButtonItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont boldSystemFontOfSize:17], UITextAttributeFont,nil] forState:UIControlStateNormal];
    [[UISegmentedControl appearance] setBackgroundImage:[UIImage imageNamed:@"UnselectedSeg"]
                                               forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [[UISegmentedControl appearance] setBackgroundImage:[UIImage imageNamed:@"SelectedSeg"]                                               forState:UIControlStateSelected barMetrics:UIBarMetricsDefault];
    
    [[UISegmentedControl appearance] setDividerImage:[UIImage imageNamed:@"Div"]
                                 forLeftSegmentState:UIControlStateNormal
                                   rightSegmentState:UIControlStateSelected
                                          barMetrics:UIBarMetricsDefault];
    
    // register for push notifications
    [application registerForRemoteNotificationTypes:
     UIRemoteNotificationTypeBadge |
     UIRemoteNotificationTypeAlert |
     UIRemoteNotificationTypeSound];
    
    //self.window.backgroundColor = [UIColor grayColor];
    [self.window setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"bluewood.jpg"]]];
    
    [self.window makeKeyAndVisible];
    if (![PFUser currentUser]) {
        [self presentLoginViewController];
    }
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"HasLaunchedOnce"])
    {
        NSLog(@"app has already launched once");
        self.firstLaunch = NO;
    }
    else
    {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"HasLaunchedOnce"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        self.firstLaunch = YES;
        // This is the first launch ever
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
    NSLog(@"application sent to background");
    LocationController* locationController = [LocationController sharedLocationController];
    [locationController.locationManager startMonitoringSignificantLocationChanges];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [FBAppCall handleDidBecomeActive];
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
    UINavigationController *loginNavController = [[UINavigationController alloc] initWithRootViewController:loginViewController];
    [self.window.rootViewController presentViewController:loginNavController animated:NO completion:nil];
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

+ (void) openPostForFirstTime:(PFObject *)post withReceipt:(PFObject *) receipt atDate:(NSDate *)date{
    
    [receipt setObject:date forKey:@"dateOpened"];
    [receipt saveInBackground];
    
    if([receipt objectForKey:@"sender"] != nil) {
        
        NSString *myFacebookId = [NSString stringWithFormat:@"%@",[[post objectForKey:@"sender"] objectForKey:@"facebookId"]];
        if(![[receipt objectForKey:@"sender"] isEqualToString:myFacebookId]) {
            PFQuery *userDataFromSenderId = [PFQuery queryWithClassName:@"UserData"];
            [userDataFromSenderId whereKey:@"facebookId" equalTo:[receipt objectForKey:@"sender"]];
            [userDataFromSenderId includeKey:@"userData"];
        
            PFQuery *userFromUserData = [PFQuery queryWithClassName:@"_User"];
            [userFromUserData whereKey:@"userData" matchesQuery:userDataFromSenderId];
        
            // Create our Installation query
            PFQuery *pushToUser = [PFInstallation query];
            [pushToUser whereKey:@"owner" matchesQuery:userFromUserData];
        
            NSString *myName = [NSString stringWithFormat:@"%@",[[post objectForKey:@"sender"] objectForKey:@"profile"][@"name"]];
            NSString *pushMessage = [NSString stringWithFormat:@"%@ tell me dis", myName];
            
            [PFPush sendPushMessageToQueryInBackground:pushToUser
            withMessage:pushMessage];
        }
    }

}

+ (PFObject *) postReceipt:(PFObject *)post {
    
    [[[PFUser currentUser] objectForKey:@"userData"] fetchIfNeeded];
    
    NSString *facebookId = [[[PFUser currentUser] objectForKey:@"userData"] objectForKey:@"facebookId"];
    NSArray *rrArray = [post objectForKey:@"readReceiptsArray"];
    
    for(PFObject *r in rrArray) {
        if([[r objectForKey:@"receiver"] isEqualToString:facebookId]) {
            return r;
        }
    }

    return nil;
}

+ (void) makeParseQuery: (int)type{
    
    PFQuery *query = [self queryForType:type];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            [AppDelegate storeObjects:objects ofType:type];
        } else {
            NSLog(@"Error in loading self and friends map posts: %@", error);
        }
    }];
    
}

+ (PFQuery *) queryForType:(NSInteger)type {
    
	PFQuery *query = [PFQuery queryWithClassName:kPAWParsePostsClassKey];
    
    NSLog(@"querying for table called");
	// If no objects are loaded in memory, we look to the cache first to fill the table
	// and then subsequently do a query against the network.
	//if ([self.objects count] == 0) {
    
    query.cachePolicy = kPFCachePolicyNetworkElseCache;
	
    //}
    
	// Query for posts near our current location.
    
	// Get our current location:
	LocationController* locationController = [LocationController sharedLocationController];
    CLLocationCoordinate2D currentCoordinate = locationController.location.coordinate;
    
	CLLocationAccuracy filterDistance = locationController.locationManager.distanceFilter;
    
	// And set the query to look by location
	PFGeoPoint *point = [PFGeoPoint geoPointWithLatitude:currentCoordinate.latitude longitude:currentCoordinate.longitude];
	[query whereKey:kPAWParseLocationKey nearGeoPoint:point withinKilometers:filterDistance / kPAWMetersInAKilometer];
    
    [query includeKey:kPAWParseSenderKey];
    [query includeKey:@"readReceiptsArray"];
    [query orderByDescending:@"createdAt"];
    
    
    if (type == TYPE_SELF) {
        NSLog(@"Only shows notes from self");
        [query whereKey:@"sender" equalTo:[[PFUser currentUser] objectForKey:@"userData"]];
        [query whereKey:@"receivers" equalTo:[[PFUser currentUser] objectForKey:@"userData"]];
    } else if (type == TYPE_FRIENDS) {
        NSLog(@"Shows notes from friends");
        [query whereKey:@"receivers" equalTo:[[PFUser currentUser] objectForKey:@"userData"]];
        [query whereKey:@"sender" notEqualTo:[[PFUser currentUser] objectForKey:@"userData"]];
    } else if (type == TYPE_PUBLIC) {
        NSLog(@"Shows public notes");
        [query whereKey:@"receivers" equalTo:[AppDelegate publicUser]];
    }
    
	return query;

}

+ (void) storeObjects:(NSArray *)objects ofType:(NSInteger) type {
    if (type == TYPE_SELF) {
        launchedDelegate.selfArray = [objects mutableCopy];
    } else if (type == TYPE_FRIENDS) {
        launchedDelegate.friendsArray = [objects mutableCopy];
    } else if (type == TYPE_PUBLIC) {
        launchedDelegate.publicArray = [objects mutableCopy];
    }

    [[NSNotificationCenter defaultCenter]
     postNotificationName: kPAWPostsUpdated
     object:self];
    
    LocationController *locationController = [LocationController sharedLocationController];
    [locationController updateLocation:locationController.location.coordinate];

}

@end

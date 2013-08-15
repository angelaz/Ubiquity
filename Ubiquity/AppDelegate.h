//
//  AppDelegate.h
//  Ubiquity
//
//  Created by Angela Zhang on 7/24/13.
//  Copyright (c) 2013 Team Ubi. All rights reserved.
//


//theme colors
#define mainThemeColor [UIColor colorWithRed:0.016 green:0.506 blue:0.62 alpha:1]; /*#04819e*/
#define tabBarColor [UIColor colorWithRed:0.004 green:0.325 blue:0.404 alpha:1]; /*#015367*/
#define lightestThemeColor [UIColor colorWithRed:0.376 green:0.725 blue:0.808 alpha:1]; /*#60b9ce*/
#define lighterThemeColor [UIColor colorWithRed:0.22 green:0.698 blue:0.808 alpha:1]; /*#38b2ce*/

static NSUInteger const kPAWWallPostMaximumCharacterCount = 140;

static double const kPAWFeetToMeters = 0.3048; // this is an exact value.
static double const kPAWFeetToMiles = 5280.0; // this is an exact value.
static double const kPAWWallPostMaximumSearchDistance = 100.0;
static double const kPAWMetersInAKilometer = 1000.0; // this is an exact value.

static NSUInteger const kPAWWallPostsSearch = 20; // query limit for pins and tableviewcells

// Parse API key constants:
static NSString * const kPAWParsePostsClassKey = @"Posts";
static NSString * const kPAWParseSenderKey = @"sender";
static NSString * const kPAWParseUsernameKey = @"username";
static NSString * const kPAWParseTextKey = @"text";
static NSString * const kPAWParseLocationKey = @"location";
static NSString * const kPAWParseCreatedKey = @"createdAt";

static NSString * const kNMFrequencyKey = @"frequency";

// NSNotification userInfo keys:
static NSString * const kPAWFilterDistanceKey = @"filterDistance";
static NSString * const kPAWLocationKey = @"location";

// Notification names:
static NSString * const kPAWFilterDistanceChangeNotification = @"kPAWFilterDistanceChangeNotification";
static NSString * const kPAWLocationChangeNotification = @"kPAWLocationChangeNotification";
static NSString * const kPAWPostCreatedNotification = @"kPAWPostCreatedNotification";
static NSString * const KPAWInitialLocationFound = @"kPAWInitialLocationFound";
static NSString * const kPAWCameraZoomChangeNotification = @"kPAWCameraZoomChangeNotification";


// UI strings:
static NSString * const kPAWWallCantViewPost = @"Can’t view post! Get closer.";
static NSString * const test = @"";

//NewMessage strings:
static NSString * const kNMNever = @"Appear Once";
static NSString * const kNMDaily = @"Every Day";
static NSString * const kNMWeekly = @"Every Week";
static NSString * const kNMMonthy = @"Every Month";




#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <GoogleMaps/GoogleMaps.h>
#import <Rdio/Rdio.h>

#import "LoginViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong) UISegmentedControl *segmentedControl;
@property (nonatomic, strong) UINavigationController *navigationController;
@property (readonly) Rdio *rdio;

- (void)presentLoginViewController;

+ (void) linkOrStoreUserDetails:(NSObject *)userData
                           toId:(id)facebookID
                         toUser:(PFUser *)user
          andStoreUnderRelation:(NSString *)relationLabel
                       toObject:(PFObject *) object
                     finalBlock:(void(^)(PFObject *made))finalBlock;

+ (Rdio *)rdioInstance;
@end
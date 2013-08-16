//
//  LocationController.m
//
//  Created by Jinru on 12/19/09.
//  Copyright 2009 Arizona State University. All rights reserved.
//

#import "LocationController.h"
#import "AppDelegate.h"
#import "Geocoding.h"

@implementation LocationController

@synthesize locationManager = _locationManager;
@synthesize delegate = _delegate;
//@synthesize location = _location;

#pragma mark - Singleton implementation in ARC
+ (LocationController *)sharedLocationController
{
    static LocationController *sharedLocationControllerInstance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedLocationControllerInstance = [[self alloc] init];
        
        [sharedLocationControllerInstance.locationManager startUpdatingLocation];
        
    });
    return sharedLocationControllerInstance;
}

- (void) updateLocation:(CLLocationCoordinate2D)currentCoordinate
{
    self.marker.map = self.map;

}

-(id) init {
    self = [super init];
    if(self != nil){
        
        self.location = [[CLLocation alloc] initWithLatitude:0 longitude:0];

        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        
        self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
        self.locationManager.distanceFilter = 50.0f;
        //self.locationManager.headingFilter = 5;
        
        self.marker = [GMSMarker markerWithPosition:self.location.coordinate];
       // self.marker.icon = [GMSMarker markerImageWithColor:[UIColor blueColor]];
        self.marker.icon = [UIImage imageNamed:@"CurLocationMarker"];
        self.marker.animated = YES;
        
        [locationManager startUpdatingLocation];
        NSLog(@"Location updates started");
        
        if ([PFUser currentUser] != nil) {
            pushQuery = [PFInstallation query];
            [pushQuery whereKey:@"deviceType" equalTo:@"ios"];
            [pushQuery whereKey:@"owner" equalTo:[PFUser currentUser]];
        }

    }
    return self;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    
    BOOL isInBackground = NO;
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground)
    {
        isInBackground = YES;
    }
    
    if ([PFUser currentUser] != nil) {
        if (pushQuery == nil) {
            pushQuery = [PFInstallation query];
            [pushQuery whereKey:@"deviceType" equalTo:@"ios"];
            [pushQuery whereKey:@"owner" equalTo:[PFUser currentUser]];
        }
    }
    
    NSLog(@"%f is the accuracy level", locationManager
           .location.horizontalAccuracy);
    _location = [locations lastObject];
    
    NSDate* eventDate = _location.timestamp;
    NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
    
    if (abs(howRecent) < 15.0) {
        // If the event is recent, do something with it. Otherwise use old location and don't waste battery.
        NSLog(@"latitude %+.6f, longitude %+.6f\n", _location.coordinate.latitude,   _location.coordinate.longitude);
        
        if(hasReceivedFirstUpdate == NO) {
            hasReceivedFirstUpdate = YES;
            
            GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:self.marker.position.latitude
                                                                    longitude:self.marker.position.longitude
                                                                         zoom:15];
            [self.map setCamera:camera];
            
            self.marker.map = self.map;
            [self moveMarkerToLocation:_location.coordinate];
            
            [[NSNotificationCenter defaultCenter]
             postNotificationName: KPAWInitialLocationFound
             object:self];
        }
        
        [[NSNotificationCenter defaultCenter]
         postNotificationName: kPAWLocationChangeNotification
         object:self];
        
        [self sendForegroundLocationToServerForPushNotifications:_location];
    }
    
    if (isInBackground)
    {
        [self sendBackgroundLocationToServerForPushNotifications:_location];
    }
}

//Example block

- (void)moveMarkerToGeocode:(Geocoding*)gs then:(void(^)(void)) block {
    
}

- (void) moveMarkerToLocation:(CLLocationCoordinate2D)newCoordinate
{
    
    self.marker.position = newCoordinate;
    
    self.marker.title = @"Here";
    self.marker.snippet = @"My location";
    self.marker.animated = YES;

    
    [self.map clear];
    
    [[NSNotificationCenter defaultCenter]
     postNotificationName:kPAWLocationChangeNotification
     object:self];
    
    GMSGeocoder *geocoder = [[GMSGeocoder alloc] init];
    [geocoder reverseGeocodeCoordinate:newCoordinate completionHandler:^(GMSReverseGeocodeResponse *resp, NSError *error) {
        if (!error) {
            NSString* reverseGeocodedLocation = [NSString stringWithFormat:@"%@, %@", resp.firstResult.addressLine1, resp.firstResult.addressLine2];
            
            self.markerLatestAddress = reverseGeocodedLocation;
            
        } else {
            NSLog(@"Error in reverse geocoding: %@", error);
            self.markerLatestAddress = @"";
        }
        
        self.marker.map = self.map;
        
        GMSCameraUpdate *geoLocateCam = [GMSCameraUpdate setTarget:newCoordinate];
        [self.map animateWithCameraUpdate:geoLocateCam];
    }];

    
}

-(void) sendForegroundLocationToServerForPushNotifications:(CLLocation *)location
{

    PFQuery *query = [PFQuery queryWithClassName:@"Posts"];
	// Query for posts near our current location.
    
	// Get our current location:
    CLLocationCoordinate2D currentCoordinate = location.coordinate;
	CLLocationAccuracy filterDistance = self.locationManager.distanceFilter;
    
	// And set the query to look by location
	PFGeoPoint *point = [PFGeoPoint geoPointWithLatitude:currentCoordinate.latitude longitude:currentCoordinate.longitude];
	[query whereKey:kPAWParseLocationKey nearGeoPoint:point withinKilometers:filterDistance / kPAWMetersInAKilometer];
    [query includeKey:kPAWParseSenderKey];
    [query includeKey:@"readReceiptsArray"];
    [query orderByDescending:@"createdAt"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *posts, NSError *error) {
        if (!error) {   // The find succeeded.
            if ([posts count] > 0) {      //Saved friend list exists
                NSLog(@"Seeing if new push notifications for found posts");
                for (PFObject *post in posts) {
                    NSArray *receiptsArray = [post objectForKey:@"readReceiptsArray"];
                    for (PFObject *receipt in receiptsArray) {
                        if ([[receipt objectForKey:@"receiver"] isEqualToString:[[PFUser currentUser] objectForKey:@"fbId"]]) {
                            if ([receipt objectForKey:@"dateOpened"] == [NSNull null]) {
                                NSLog(@"New push notifications so new notes!");
                                
                                PFObject *senderInfo = [post objectForKey:@"sender"];
                                PFObject *profile = [senderInfo objectForKey:@"profile"];
                                NSString *sender = [NSString stringWithFormat:@"%@",[profile objectForKey:@"name"]];
                                NSString *pushMessage = [NSString stringWithFormat:@"Received a message from %@", sender];
                                
                                // Send push notification to query
                                [PFPush sendPushMessageToQueryInBackground:pushQuery
                                                               withMessage:pushMessage];
                                
                                
                                [receipt setObject:[NSDate date] forKey:@"dateOpened"];
                                [receipt saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                                    NSLog(@"saving read receipts error: %@", error);
                                }];
                            }
                        };
                    }
                }
            } else {
                // Log details of the failure
                NSLog(@"No posts found");
            }
        } else {
            NSLog(@"Error in finding push notifications: %@", error);
        }
    }];
}


-(void) sendBackgroundLocationToServerForPushNotifications:(CLLocation *)location
{
    // REMEMBER. We are running in the background if this is being executed.
    // We can't assume normal network access.
    // bgTask is defined as an instance variable of type UIBackgroundTaskIdentifier
    
    // Note that the expiration handler block simply ends the task. It is important that we always
    // end tasks that we have started.
    UIBackgroundTaskIdentifier bgTask = [[UIApplication sharedApplication]
                                         beginBackgroundTaskWithExpirationHandler:
                                         ^(void){
                                             NSLog(@"background task initialized");
                                             [[UIApplication sharedApplication] endBackgroundTask:bgTask];
                                         }];
    
    // ANY CODE WE PUT HERE IS OUR BACKGROUND TASK
    
    PFQuery *query = [PFQuery queryWithClassName:@"Posts"];
	// Query for posts near our current location.
    
	// Get our current location:
    CLLocationCoordinate2D currentCoordinate = location.coordinate;
	CLLocationAccuracy filterDistance = self.locationManager.distanceFilter;
    
	// And set the query to look by location
	PFGeoPoint *point = [PFGeoPoint geoPointWithLatitude:currentCoordinate.latitude longitude:currentCoordinate.longitude];
	[query whereKey:kPAWParseLocationKey nearGeoPoint:point withinKilometers:filterDistance / kPAWMetersInAKilometer];
    [query includeKey:kPAWParseSenderKey];
    [query includeKey:@"readReceiptsArray"];
    [query orderByDescending:@"createdAt"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *posts, NSError *error) {
        if (!error) {   // The find succeeded.
            if ([posts count] > 0) {      //Saved friend list exists
                NSLog(@"Seeing if new push notifications for found posts");
                for (PFObject *post in posts) {
                    NSArray *receiptsArray = [post objectForKey:@"readReceiptsArray"];
                    for (PFObject *receipt in receiptsArray) {
                        if ([[receipt objectForKey:@"receiver"] isEqualToString:[[PFUser currentUser] objectForKey:@"fbId"]]) {
                            if ([receipt objectForKey:@"dateOpened"] == [NSNull null]) {
                                NSLog(@"New push notifications so new notes!");
                                
                                PFObject *senderInfo = [post objectForKey:@"sender"];
                                PFObject *profile = [senderInfo objectForKey:@"profile"];
                                NSString *sender = [NSString stringWithFormat:@"%@",[profile objectForKey:@"name"]];
                                NSString *pushMessage = [NSString stringWithFormat:@"Received a message from %@", sender];
                                
                                // Send push notification to query
                                [PFPush sendPushMessageToQueryInBackground:pushQuery
                                                               withMessage:pushMessage];
                                
                                
                                [receipt setObject:[NSDate date] forKey:@"dateOpened"];
                                [receipt saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                                    NSLog(@"saving read receipts error: %@", error);
                                }];
                            }
                        };
                    }
                }
            } else {
                // Log details of the failure
                NSLog(@"No posts found");
            }
        } else {
            NSLog(@"Error in finding push notifications: %@", error);
        }
    }];

    
    // AFTER ALL THE UPDATES, close the task
    
    if (bgTask != UIBackgroundTaskInvalid)
    {
        [[UIApplication sharedApplication] endBackgroundTask:bgTask];
        bgTask = UIBackgroundTaskInvalid;
    }
}

@end
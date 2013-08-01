//
//  RecentViewController.m
//  UbiFirst
//
//  Created by Catherine Morrison on 7/24/13.
//  Copyright (c) 2013 Catherine Morrison. All rights reserved.
//



#import "RecentViewController.h"

#import "AppDelegate.h"

#import <CoreLocation/CoreLocation.h>
#import "NewMessageViewController.h"
#import "TextMessage.h"
#import "WallPostsViewController.h"
#import "LocationController.h"

@interface RecentViewController ()

@property (nonatomic, strong) UISegmentedControl *segmentedControl;

@property (nonatomic, strong) NSMutableArray *annotations;
@property (nonatomic, copy) NSString *className;

@property (nonatomic, strong) WallPostsViewController *wallPostsViewController;

@property (nonatomic, strong) NSMutableArray *allPosts;

// CLLocationManagerDelegate methods:
- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation;

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error;

- (void)startStandardUpdates;

- (void)queryForAllPostsNearLocation:(CLLocation *)currentLocation withNearbyDistance:(CLLocationAccuracy)nearbyDistance;
- (void)updatePostsForLocation:(CLLocation *)location withNearbyDistance:(CLLocationAccuracy) filterDistance;

// NSNotification callbacks
- (void)distanceFilterDidChange:(NSNotification *)note;
- (void)locationDidChange:(NSNotification *)note;
- (void)postWasCreated:(NSNotification *)note;

@end

@implementation RecentViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (id)init
{
    self = [super init];
    if (self) {
        UINavigationItem *nav = [self navigationItem];
       // [nav setTitle:@"Recent"];
        UIBarButtonItem *bbi = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                             target:self
                                                                             action:@selector(addNewItem:)];
        [[self navigationItem] setRightBarButtonItem:bbi];
        
        _segmentedControl = [[UISegmentedControl alloc] initWithItems:@[@"Friends", @"Public", @"Favorites"]];
        
        _segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
        [_segmentedControl setSelectedSegmentIndex:0];
        
        [_segmentedControl addTarget:self
                              action:@selector(changeSegment:)
                    forControlEvents:UIControlEventValueChanged];
        
        nav.titleView = _segmentedControl;
        
    }
    
    return self;
}

- (void)changeSegment:(UISegmentedControl *)sender
{
    NSInteger value = [sender selectedSegmentIndex];
    WallPostsViewController *wall = self.wallPostsViewController;
    if (value == 0) {
        wall.indexing = 0;
        NSLog(@"Changed value to 0");
        [wall loadObjects];
    } else if (value == 1) {
        wall.indexing = 1;
        NSLog(@"Changed value to 1");
        [wall loadObjects];
    } else if (value == 2) {
        indexNumber = 2;
        NSLog(@"Changed value to 2");
    }
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self) {
		self.title = @"Recent Posts";
		self.className = kPAWParsePostsClassKey;
		_annotations = [[NSMutableArray alloc] initWithCapacity:10];
		_allPosts = [[NSMutableArray alloc] initWithCapacity:10];
	}
	return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(postWasCreated:) name:kPAWPostCreatedNotification object:nil];
    
    // Register for the user location change notification: kPAWLocationChangeNotification
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(locationDidChange:)
                                                 name:kPAWLocationChangeNotification
                                               object:nil];
    
    self.wallPostsViewController = [[WallPostsViewController alloc] init];
    self.wallPostsViewController.view.frame = CGRectMake(0.f, 0.f, 320.f, super.view.frame.size.height);
    
    // Add the WallPostsViewController as a child of RecentViewController
    [self addChildViewController:self.wallPostsViewController];
    // Add the view of WallPostsViewController as a
    // subview of RecentViewController's view
    [self.view addSubview:self.wallPostsViewController.view];
    
    // Uncomment the following line to preserve selection between presentations.
     //self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [self startStandardUpdates];
}


- (void)addNewItem:(id)sender

{
    
    NewMessageViewController *nmvc = [[NewMessageViewController alloc] init];
    [self presentViewController:nmvc animated:YES completion:nil];
    
    //  ExpenseItem *newItem = [[ExpenseItemStore sharedStore] createItem];
    //  DetailViewController *detailViewController = [[DetailViewController alloc] initForNewItem:YES];
    //  [detailViewController setItem:newItem];
    
    //  [detailViewController setDismissBlock:^{[[self tableView] reloadData];}];
    
    //  UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:detailViewController];
    //  [navController setModalPresentationStyle:UIModalPresentationFormSheet];
    // [navController setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
    //  [self presentViewController:navController
    //                   animated:YES
    //                  completion:nil];
}

- (void)queryForAllPostsNearLocation:(CLLocation *)currentLocation
                  withNearbyDistance:(CLLocationAccuracy)nearbyDistance
{
    PFQuery *wallPostQuery = [PFQuery queryWithClassName:self.className];
    
    // If no objects are loaded in memory, we look to the cache first to fill the table
    // and then subsequently do a query against the network.
    if ([self.allPosts count] == 0) {
        wallPostQuery.cachePolicy = kPFCachePolicyCacheThenNetwork;
    }
    
    // Create a PFGeoPoint using the current location (to use in our query)
    PFGeoPoint *userLocation =
    [PFGeoPoint geoPointWithLatitude:currentLocation.coordinate.latitude
                           longitude:currentLocation.coordinate.longitude];
    
    // Create a PFQuery asking for all wall posts 100km of the user
    // We won't be showing all of the posts returned, 100km is our buffer
    [wallPostQuery whereKey:kPAWParseLocationKey
               nearGeoPoint:userLocation
           withinKilometers:kPAWWallPostMaximumSearchDistance];
    
    // Include the associated PFUser objects in the returned data
    [wallPostQuery includeKey:kPAWParseUserKey];
    
    // Limit the number of wall posts returned to 20
    wallPostQuery.limit = kPAWWallPostsSearch;
    
    //Run the query in background with completion block
    [wallPostQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
     {
         if (error) // The query failed
         {
             NSLog(@"Error in geo query!");
             NSLog(@"%@", error);
         }
         else // The query is successful
         {
             // 1. Find new posts (those that we did not already have)
             // In this array we'll store the posts returned by the query
             NSMutableArray *newPosts = [[NSMutableArray alloc] initWithCapacity:kPAWWallPostsSearch];
             
             // Loop through all returned PFObjects
             for (PFObject *object in objects)
             {
                 // Create an object of type PAWPost with the PFObject
                 TextMessage *newPost = [[TextMessage alloc] initWithPFObject:object];
                 
                 // Now we check if we already had this wall post
                 BOOL found = NO;
                 for (TextMessage *currentPost in _allPosts) // Loop through all the wall posts we have
                 {
                     if ([newPost equalToPost:currentPost]) // Are they the same?
                     {
                         found = YES;
                     }
                 }
                 
                 if (!found) // If we did not already have this wall post
                 {
                     [newPosts addObject:newPost];
                 }
             }
             
             // 2. Find posts to remove (those we have but that we did not get from this query)
             // Will contain wall posts we currently have that were not returned in the query
             NSMutableArray *postsToRemove =
             [[NSMutableArray alloc] initWithCapacity:kPAWWallPostsSearch];
             
             // Loop through all the the wall posts we currently have
             for (TextMessage *currentPost in _allPosts)
             {
                 BOOL found = NO;
                 
                 // Loop through all the wall posts we received
                 for (PFObject *object in objects)
                 {
                     // Create an object of type PAWPost with the PFObject
                     TextMessage *newPost = [[TextMessage alloc] initWithPFObject:object];
                     if ([currentPost equalToPost:newPost]) // Are they equal?
                     {
                         found = YES;
                     }
                 }
                 
                 // If we did not find the wall post we currently have in the set of posts
                 // the query returned, then we add it to the 'postsToRemove' array
                 if (!found)
                 {
                     [postsToRemove addObject:currentPost];
                 }
             }
             
             // 3. Configure the new posts (if its outside the search radius, we hide the post message)
             // We loop through all the new posts (i.e. all objects in the 'newPosts' array)
             for (TextMessage *newPost in newPosts)
             {
                 // Get the location of the wall post
                 CLLocation *objectLocation =
                 [[CLLocation alloc] initWithLatitude:newPost.coordinate.latitude
                                            longitude:newPost.coordinate.longitude];
                 
                 // For posts outside the search radius, we show a different
                 // message by setting the following property
                 CLLocationDistance distanceFromCurrent = [currentLocation distanceFromLocation:objectLocation];
                 [newPost setTitleAndSubtitleOutsideDistance:( distanceFromCurrent > nearbyDistance ? YES : NO )];
                 
                 // Animate all pins after the initial load
                 //newPost.animatesDrop = mapPinsPlaced;
             }
             
             // 4. Remove the old posts and add the new posts
             // We remove all undesired posts from both the cache and the map
             //  [mapView removeAnnotations:postsToRemove];
             [_allPosts removeObjectsInArray:postsToRemove];
             
             // We add all new posts to both the cache and the map
             //  [mapView addAnnotations:newPosts];
             [_allPosts addObjectsFromArray:newPosts];
             //  self.mapPinsPlaced = YES;
         }
     }];
}

- (void)distanceFilterDidChange:(NSNotification *)note {
	CLLocationAccuracy filterDistance = [[[note userInfo] objectForKey:kPAWFilterDistanceKey] doubleValue];
    
//	if (self.searchRadius == nil) {
//		self.searchRadius = [[PAWSearchRadius alloc] initWithCoordinate:appDelegate.currentLocation.coordinate radius:appDelegate.filterDistance];
//		[mapView addOverlay:self.searchRadius];
//	} else {
//		self.searchRadius.radius = appDelegate.filterDistance;
//	}
    
	// Update our pins for the new filter distance:
    LocationController* locationController = [LocationController sharedLocationController];
	[self updatePostsForLocation:locationController.location withNearbyDistance:filterDistance];
	
	// If they panned the map since our last location update, don't recenter it.
	//if (!self.mapPannedSinceLocationUpdate) {
		// Set the map's region centered on their location at 2x filterDistance
	//	MKCoordinateRegion newRegion = MKCoordinateRegionMakeWithDistance(appDelegate.currentLocation.coordinate, appDelegate.filterDistance * 2.0f, appDelegate.filterDistance * 2.0f);
        
	//	[mapView setRegion:newRegion animated:YES];
	//	self.mapPannedSinceLocationUpdate = NO;
	//} else {
		// Just zoom to the new search radius (or maybe don't even do that?)
	//	MKCoordinateRegion currentRegion = mapView.region;
	//	MKCoordinateRegion newRegion = MKCoordinateRegionMakeWithDistance(currentRegion.center, appDelegate.filterDistance * 2.0f, appDelegate.filterDistance * 2.0f);
        
	//	BOOL oldMapPannedValue = self.mapPannedSinceLocationUpdate;
	//	[mapView setRegion:newRegion animated:YES];
	//	self.mapPannedSinceLocationUpdate = oldMapPannedValue;
	//}
}

- (void)locationDidChange:(NSNotification *)note;
{
    LocationController* locationController = [LocationController sharedLocationController];
    
    
    // If we haven't drawn the search radius on the map, initialize it.
    //  if (self.searchRadius == nil)
    //    {
    //        self.searchRadius =
    //        [[PAWSearchRadius alloc] initWithCoordinate:appDelegate.currentLocation.coordinate
    //                                             radius:appDelegate.filterDistance];
    //        [mapView addOverlay:self.searchRadius];
    //    }
    //    else
    //    {
    //        self.searchRadius.coordinate = appDelegate.currentLocation.coordinate;
    //    }
    
    // Update the map with new pins:
    [self queryForAllPostsNearLocation:locationController.location
                    withNearbyDistance:locationController.filterDistance];
    // And update the existing pins to reflect any changes in filter distance:
    [self updatePostsForLocation:locationController.location
              withNearbyDistance:locationController.filterDistance];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)postWasCreated:(NSNotification *)note {
    LocationController* locationController = [LocationController sharedLocationController];
	[self queryForAllPostsNearLocation:locationController.location withNearbyDistance:locationController.filterDistance];
}


- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error {
	NSLog(@"%s", __PRETTY_FUNCTION__);
	NSLog(@"Error: %@", [error description]);
    
	if (error.code == kCLErrorDenied) {
		//[_locationManager stopUpdatingLocation];
	} else if (error.code == kCLErrorLocationUnknown) {
		// todo: retry?
		// set a timer for five seconds to cycle location, and if it fails again, bail and tell the user.
	} else {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error retrieving location"
		                                                message:[error description]
		                                               delegate:nil
		                                      cancelButtonTitle:nil
		                                      otherButtonTitles:@"Ok", nil];
		[alert show];
	}
}

- (void)updatePostsForLocation:(CLLocation *)currentLocation withNearbyDistance:(CLLocationAccuracy) nearbyDistance {
	for (TextMessage *post in _allPosts) {
		CLLocation *objectLocation = [[CLLocation alloc] initWithLatitude:post.coordinate.latitude longitude:post.coordinate.longitude];
		// if this post is outside the filter distance, don't show the regular callout.
		CLLocationDistance distanceFromCurrent = [currentLocation distanceFromLocation:objectLocation];
		if (distanceFromCurrent > nearbyDistance) { // Outside search radius
			[post setTitleAndSubtitleOutsideDistance:YES];
			//[mapView viewForAnnotation:post];
			//[(MKPinAnnotationView *) [mapView viewForAnnotation:post] setPinColor:post.pinColor];
		} else {
			[post setTitleAndSubtitleOutsideDistance:NO]; // Inside search radius
			//[mapView viewForAnnotation:post];
			//[(MKPinAnnotationView *) [mapView viewForAnnotation:post] setPinColor:post.pinColor];
		}
	}
}

- (void)startStandardUpdates {
    LocationController *locationController = [LocationController sharedLocationController];
    CLLocationManager *locManager = [locationController locationManager];
	if (nil == locManager) {
		locManager = [[CLLocationManager alloc] init];
	}
    
	locManager.delegate = self;
	//locManager.desiredAccuracy = kCLLocationAccuracyBest;
    
	// Set a movement threshold for new events.
	locManager.distanceFilter = 1000.0f;
    
	[locManager startUpdatingLocation];
    
	CLLocation *currentLocation = locManager.location;
	if (currentLocation) {
	//	AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
	//	appDelegate.currentLocation = currentLocation;
        locManager.delegate = locationController;
	}
    
}

#pragma mark - Table view data source

@end

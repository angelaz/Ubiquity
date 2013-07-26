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

@interface RecentViewController ()

@property (nonatomic, strong) CLLocationManager *_locationManager;
@property (nonatomic, strong) NSMutableArray *annotations;
@property (nonatomic, copy) NSString *className;

@property (nonatomic, strong) NSMutableArray *allPosts;

- (void)startStandardUpdates;

// CLLocationManagerDelegate methods:
- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation;

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error;


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
        [nav setTitle:@"Recent"];
     //   UIBarButtonItem *bbi = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
     //       target:self
     //                                                                        action:@selector(addNewItem:)];
     //   [[self navigationItem] setRightBarButtonItem:bbi];
    }
    
    return self;
}

//- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
//	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
//	if (self) {
//		self.title = @"Recent Posts";
//		self.className = kPAWParsePostsClassKey;
//		_annotations = [[NSMutableArray alloc] initWithCapacity:10];
//		_allPosts = [[NSMutableArray alloc] initWithCapacity:10];
//	}
//	return self;
//}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(postWasCreated:) name:kPAWPostCreatedNotification object:nil];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}




//
//- (void)addNewItem:(id)sender
//{
//  //  ExpenseItem *newItem = [[ExpenseItemStore sharedStore] createItem];
//  //  DetailViewController *detailViewController = [[DetailViewController alloc] initForNewItem:YES];
//  //  [detailViewController setItem:newItem];
//    
//  //  [detailViewController setDismissBlock:^{[[self tableView] reloadData];}];
//    
//  //  UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:detailViewController];
//  //  [navController setModalPresentationStyle:UIModalPresentationFormSheet];
//   // [navController setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
//  //  [self presentViewController:navController
//    //                   animated:YES
//   //                  completion:nil];
//}

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    // This is where the post happens
    [appDelegate setCurrentLocation:newLocation];
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
    wallPostQuery.limit = [NSNumber numberWithInt:kPAWWallPostsSearch];
    
    //Run the query in background with completion block
    [wallPostQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
     {
         if (error) // The query failed
         {
             NSLog(@"Error in geo query!");
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
                // [newPost setTitleAndSubtitleOutsideDistance:( distanceFromCurrent > nearbyDistance ? YES : NO )];
                 
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


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)postWasCreated:(NSNotification *)note {
	//AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
}

#pragma mark - Table view data source

@end

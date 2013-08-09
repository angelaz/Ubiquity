//
//  RecentViewController.h
//  UbiFirst
//
//  Created by Catherine Morrison on 7/24/13.
//  Copyright (c) 2013 Catherine Morrison. All rights reserved.
//

static int indexNumber = 0;

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "WallPostsViewController.h"

@class WallPostsViewController;

@interface RecentViewController : UIViewController
@property  BOOL firstTime;

- (void)startStandardUpdates;
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

- (void)queryForAllPostsNearLocation:(CLLocation *)currentLocation withNearbyDistance:(CLLocationAccuracy)nearbyDistance;
- (void)updatePostsForLocation:(CLLocation *)location withNearbyDistance:(CLLocationAccuracy) filterDistance;

// NSNotification callbacks
- (void)distanceFilterDidChange:(NSNotification *)note;
- (void)locationDidChange:(NSNotification *)note;
- (void)postWasCreated:(NSNotification *)note;

@end

@protocol PAWWallViewControllerHighlight <NSObject>



@end

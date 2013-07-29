//
//  LocationController.m
//
//  Created by Jinru on 12/19/09.
//  Copyright 2009 Arizona State University. All rights reserved.
//

#import "LocationController.h"
#import "AppDelegate.h"

@implementation LocationController

@synthesize locationManager = _locationManager;
@synthesize delegate = _delegate;
@synthesize location = _location;

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

-(id) init {
    self = [super init];
    if(self != nil){
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        _filterDistance = 30;
        [locationManager setDistanceFilter: _filterDistance];
    }
    return self;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    
    _location = [locations lastObject];
    
    [[NSNotificationCenter defaultCenter]
     postNotificationName: kPAWLocationChangeNotification
     object:self];
    
    NSLog(@"latitude %+.6f, longitude %+.6f\n", _location.coordinate.latitude,   _location.coordinate.longitude);
    
//    if([self.delegate conformsToProtocol:@protocol(CLLocationManagerDelegate)]) {
//        [self.delegate locationManager:manager didUpdateLocations:locations];
//    }

}

@end
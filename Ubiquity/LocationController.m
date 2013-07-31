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
        
        self.location = [[CLLocation alloc] initWithLatitude:37.4832526 longitude:-122.150037];
        
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        
        self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
        self.locationManager.distanceFilter = 1000.0f;
        //self.locationManager.headingFilter = 5;
        
        [locationManager startUpdatingLocation];
        NSLog(@"Location updates started");
        
    }
    return self;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    
    NSLog(@"%f is the accuracy level", locationManager
           .location.horizontalAccuracy);
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
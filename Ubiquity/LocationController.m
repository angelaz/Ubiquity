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

-(id) init {
    self = [super init];
    if(self != nil){
        
        self.location = [[CLLocation alloc] initWithLatitude:0 longitude:0];

        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        
        self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
        self.locationManager.distanceFilter = 50.0f;
        //self.locationManager.headingFilter = 5;
        
        self.marker = [[GMSMarker alloc] init];
        self.marker.icon = [GMSMarker markerImageWithColor:[UIColor blueColor]];
        self.marker.animated = YES;
        
        [locationManager startUpdatingLocation];
        NSLog(@"Location updates started");
    }
    return self;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    
    NSLog(@"%f is the accuracy level", locationManager
           .location.horizontalAccuracy);
    _location = [locations lastObject];
    
    NSLog(@"latitude %+.6f, longitude %+.6f\n", _location.coordinate.latitude,   _location.coordinate.longitude);

    if(hasReceivedFirstUpdate == NO) {
        hasReceivedFirstUpdate = YES;
        
        self.marker.map = self.map;
        self.marker.position = _location.coordinate;
        
        GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:self.marker.position.latitude
                                                                longitude:self.marker.position.longitude
                                                                     zoom:15];
        [self.map setCamera:camera];

        
        [[NSNotificationCenter defaultCenter]
         postNotificationName: KPAWInitialLocationFound
         object:self];
    }
    
    [[NSNotificationCenter defaultCenter]
     postNotificationName: kPAWLocationChangeNotification
     object:self];
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


@end
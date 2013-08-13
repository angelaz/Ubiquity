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
        
        self.location = [[CLLocation alloc] initWithLatitude:37.4832526 longitude:-122.150037];

        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        
        self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
        self.locationManager.distanceFilter = 50.0f;
        //self.locationManager.headingFilter = 5;
        
        [locationManager startUpdatingLocation];
        NSLog(@"Location updates started");
    }
    return self;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    
    if(self.marker == nil) {
        self.marker = [[GMSMarker alloc] init];
        self.marker.position = [[locations lastObject] coordinate];
    }
    
    NSLog(@"%f is the accuracy level", locationManager
           .location.horizontalAccuracy);
    _location = [locations lastObject];
    
    [[NSNotificationCenter defaultCenter]
     postNotificationName: kPAWLocationChangeNotification
     object:self];
    
    NSLog(@"latitude %+.6f, longitude %+.6f\n", _location.coordinate.latitude,   _location.coordinate.longitude);

}

//Example block
//GMSCameraUpdate *geoLocateCam = [GMSCameraUpdate setTarget:geolocation];
//[_nmv.map animateWithCameraUpdate:geoLocateCam];

- (void)moveMarkerToGeocode:(Geocoding*)gs withMap:(GMSMapView*)map then:(void(^)(void)) block {
    
    double lat = [[gs.geocode objectForKey:@"lat"] doubleValue];
    double lng = [[gs.geocode objectForKey:@"lng"] doubleValue];
    
    CLLocationCoordinate2D geolocation = CLLocationCoordinate2DMake(lat,lng);
    self.marker.position = geolocation;
    self.marker.title = [gs.geocode objectForKey:@"address"];
    
    NSLog(@"%@", self.marker.title);
    NSLog(@"%f, %f", lat, lng);
    
    self.marker.map = map;
    
    block;
    
}

- (void) updateLocation:(CLLocationCoordinate2D)currentCoordinate withMap:(GMSMapView*)map
{    
    //[_nmv.map clear];
    
    NSLog(@"New location");
    NSLog(@"Long: %f", currentCoordinate.longitude);
    NSLog(@"Lat: %f", currentCoordinate.latitude);
    //NSLog(@"%@", [LocationController sharedLocationController].location.coordinate);
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:currentCoordinate.latitude + 0.003
                                                            longitude:currentCoordinate.longitude
                                                                 zoom:15];
    //[_nmv.map setCamera:camera];
    
    self.marker.position = currentCoordinate;
    self.marker.title = @"Here";
    self.marker.snippet = @"My location";
    self.marker.animated = YES;
    self.marker.map = map;
}


@end
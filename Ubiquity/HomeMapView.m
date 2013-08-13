//
//  HomeMapView.m
//  Ubiquity
//
//  Created by Winnie Wu on 8/9/13.
//  Copyright (c) 2013 Team Ubi. All rights reserved.
//

#import "HomeMapView.h"
#import "AppDelegate.h"
#import "LocationController.h"


@interface HomeMapView ()


@end
@implementation HomeMapView


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        int const SCREEN_WIDTH = frame.size.width;
        int const SCREEN_HEIGHT = frame.size.height;

        [self setUpMapWithWidth: SCREEN_WIDTH andHeight: SCREEN_HEIGHT];
    }
    return self;
}

- (void) setUpMapWithWidth: (int) w andHeight: (int) h
{
    LocationController* locationController = [LocationController sharedLocationController];
    CLLocationCoordinate2D currentCoordinate = locationController.location.coordinate;
    
    NSLog(@"Long: %f", currentCoordinate.longitude);
    NSLog(@"Lat: %f", currentCoordinate.latitude);
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:currentCoordinate.latitude
                                                            longitude:currentCoordinate.longitude
                                                                 zoom:15];
    self.map = [GMSMapView mapWithFrame: CGRectMake(0, 0, w, h) camera:camera];
    GMSMarker *marker = [[GMSMarker alloc] init];
    marker.position = currentCoordinate;
    marker.animated = YES;
    marker.map = self.map;
    [self addSubview:self.map];
    
}
@end

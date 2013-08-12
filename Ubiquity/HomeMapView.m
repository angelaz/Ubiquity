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


#define SCREEN_WIDTH self.frame.size.width;
#define SCREEN_HEIGHT self.frame.size.height;
int const LEFT_PADDING = 30;
int const LINE_HEIGHT = 30;

@interface HomeMapView ()

@property (nonatomic, strong) GMSMapView *map;

@end
@implementation HomeMapView


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

- (void) setUpMap
{
    LocationController* locationController = [LocationController sharedLocationController];
    CLLocationCoordinate2D currentCoordinate = locationController.location.coordinate;
    
    NSLog(@"Long: %f", currentCoordinate.longitude);
    NSLog(@"Lat: %f", currentCoordinate.latitude);
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:currentCoordinate.latitude + 2
                                                            longitude:currentCoordinate.longitude
                                                                 zoom:6];
    self.map = [GMSMapView mapWithFrame: self.frame camera:camera];
    GMSMarker *marker = [[GMSMarker alloc] init];
    marker.position = currentCoordinate;
    marker.animated = YES;
    marker.map = self.map;
    [self addSubview:self.map];
    
}

@end

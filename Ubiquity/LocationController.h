//
//  LocationController.h
//  Ubiquity
//
//  Created by Ada Taylor on 7/29/13.
//  Copyright (c) 2013 Team Ubi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

// protocol for sending location updates to another view controller
@protocol LocationControllerDelegate
@required
- (void)locationUpdate:(CLLocation*)location;
@end

@interface LocationController : NSObject <CLLocationManagerDelegate> {
    
    CLLocationManager* locationManager;
    __weak id delegate;
}

@property (nonatomic, strong) CLLocationManager* locationManager;
@property (nonatomic, strong) CLLocation* location;
@property CLLocationAccuracy filterDistance;

@property (nonatomic, strong) UIAlertView *av;

@property (nonatomic, weak) id  delegate;

+ (LocationController*)sharedLocationController;

@end
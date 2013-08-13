//
//  HomeMapViewController.h
//  Ubiquity
//
//  Created by Winnie Wu on 8/9/13.
//  Copyright (c) 2013 Team Ubi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GoogleMaps/GoogleMaps.h>

@interface HomeMapViewController : UIViewController <CLLocationManagerDelegate, UIGestureRecognizerDelegate, GMSMapViewDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong) UISegmentedControl *segmentedControl;
@property (nonatomic, strong) UIButton *optionsButton;
@end

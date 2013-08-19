//
//  HomeMapViewController.h
//  Ubiquity
//
//  Created by Winnie Wu on 8/9/13.
//  Copyright (c) 2013 Team Ubi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GoogleMaps/GoogleMaps.h>
#import <QuartzCore/QuartzCore.h>
#import "Geocoding.h"
#import "TutorialViewController.h"

@interface HomeMapViewController : UIViewController <CLLocationManagerDelegate, UIGestureRecognizerDelegate, GMSMapViewDelegate, UINavigationControllerDelegate, UITextFieldDelegate, TutorialViewControllerDelegate>

@property (nonatomic, strong) UISegmentedControl *segmentedControl;
@property (nonatomic, strong) UIButton *optionsButton;
@property (nonatomic, strong) NSMutableArray *objects;
@property (strong,nonatomic) Geocoding *gs;

@end

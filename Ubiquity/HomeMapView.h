//
//  HomeMapView.h
//  Ubiquity
//
//  Created by Winnie Wu on 8/9/13.
//  Copyright (c) 2013 Team Ubi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <GoogleMaps/GoogleMaps.h>

@interface HomeMapView : UIView <UIGestureRecognizerDelegate>

@property (nonatomic, strong) GMSMapView *map;

@property (nonatomic, strong) UIGestureRecognizer *tapRecognizer;

@property (nonatomic, strong) UITextField *locationSearchTextField;
@property (nonatomic, strong) UIButton *locationSearchButton;

@end

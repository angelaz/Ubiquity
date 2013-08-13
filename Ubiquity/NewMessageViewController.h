//
//  NewMessageViewController.h
//  Ubiquity
//
//  Created by Winnie Wu on 7/24/13.
//  Copyright (c) 2013 Team Ubi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <GoogleMaps/GoogleMaps.h>
#import "Geocoding.h"
#import "NewMessageView.h"
#import "AppDelegate.h"
#import "CustomFBFriendPickerViewController.h"

@interface NewMessageViewController : UIViewController <UITextFieldDelegate, UITextViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource, MKMapViewDelegate, CLLocationManagerDelegate, UIGestureRecognizerDelegate, GMSMapViewDelegate, UISearchBarDelegate, FBFriendPickerDelegate, UIScrollViewDelegate>

{
    GMSMapView *mapView;
    NSMutableArray *recipientsList;
    NSMutableDictionary *readReceipts;
}

@property (retain, nonatomic) FBFriendPickerViewController *friendPickerController;
@property (nonatomic, strong) NSArray *repeatOptions;
@property (nonatomic, strong) NSArray *friendsOnApp;
@property (nonatomic, strong) NewMessageView *nmv;

- (void) updateLocation:(CLLocationCoordinate2D)currentCoordinate;

- (void) sendMessage: (id) sender;

- (void) sendInvitesViaFacebook:(NSMutableArray *)facebookFriends atAddress:(NSString *)address;


@property (strong,nonatomic) Geocoding *gs;
@end

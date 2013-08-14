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
#import "AddMusicViewController.h"

@interface NewMessageViewController : UIViewController <UITextViewDelegate, CLLocationManagerDelegate, UIGestureRecognizerDelegate, GMSMapViewDelegate, UISearchBarDelegate, FBFriendPickerDelegate, UIScrollViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, AddMusicViewControllerDelegate>

{
    GMSMapView *mapView;
    NSMutableArray *recipientsList;
    NSMutableDictionary *readReceipts;
}

@property (retain, nonatomic) FBFriendPickerViewController *friendPickerController;
@property (nonatomic, strong) NSArray *repeatOptions;
@property (nonatomic, strong) NSArray *friendsOnApp;
@property (nonatomic, strong) NewMessageView *nmv;

- (void) sendMessage: (id) sender;

- (void) sendInvitesViaFacebook:(NSMutableArray *)facebookFriends atAddress:(NSString *)address;


@property (strong,nonatomic) Geocoding *gs;
@end

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

@interface NewMessageViewController : UIViewController <UITextViewDelegate, CLLocationManagerDelegate, UIGestureRecognizerDelegate, GMSMapViewDelegate, UISearchBarDelegate, FBFriendPickerDelegate, UIScrollViewDelegate, UIImagePickerControllerDelegate>

{
    GMSMapView *mapView;
    NSMutableArray *recipientsList;
    NSMutableDictionary *readReceipts;
}

@property (retain, nonatomic) FBFriendPickerViewController *friendPickerController;

//@property (nonatomic, strong) UITextField *toRecipientTextField;
//@property (nonatomic, strong) UILabel *toLabel;
//@property (nonatomic, strong) UITextField *messageTextField;
//@property (nonatomic, strong) UIButton *sendButton;
//@property (nonatomic, strong) UIPickerView *repeatTimesPicker;
//@property (nonatomic, strong) UIToolbar *pickerToolbar;
//@property (nonatomic, strong) UIButton *showRepeatPickerButton;
//@property (nonatomic, strong) UITextField *toRecipientTextField;
//@property (nonatomic, strong) UILabel *toLabel;
//@property (nonatomic, strong) UITextField *messageTextField;
//@property (nonatomic, strong) UIButton *sendButton;
//@property (nonatomic, strong) UIPickerView *repeatTimesPicker;
//@property (nonatomic, strong) UIToolbar *pickerToolbar;
//@property (nonatomic, strong) UIButton *showRepeatPickerButton;
@property (nonatomic, strong) NSArray *repeatOptions;
//@property (nonatomic, strong) UITextField *locationSearchTextField;
//@property (nonatomic, strong) UIButton *locationSearchButton;
//@property (nonatomic, strong) UIGestureRecognizer *tapRecognizer;

@property (nonatomic, strong) NSArray *friendsOnApp;

@property (nonatomic, strong) NewMessageView *nmv;

- (void) updateLocation:(CLLocationCoordinate2D)currentCoordinate;

- (void) sendMessage: (id) sender;
- (void) startSearch: (id) sender;



@property (strong,nonatomic) Geocoding *gs;
@end

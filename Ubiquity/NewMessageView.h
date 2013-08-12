//
//  NewMessageView.h
//  Ubiquity
//
//  Created by Winnie Wu on 7/26/13.
//  Copyright (c) 2013 Team Ubi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <GoogleMaps/GoogleMaps.h>

@interface NewMessageView : UIView
//@property (nonatomic, strong) UITextField *toRecipientTextField;
@property (nonatomic, strong) UIButton *addFriendsButton;
//
//@property (strong, nonatomic) UISearchBar *searchBar;
//@property (strong, nonatomic) NSString *searchText;
//
@property (nonatomic, strong) UILabel *toLabel;
@property (nonatomic, strong) UILabel *fromLabel;
@property (nonatomic, strong) UILabel *sentLabel;

@property (nonatomic, strong) UITextView *messageTextView;
//@property (nonatomic, strong) UITextField *messageTextFieldBg;
//@property (nonatomic, strong) UIButton *sendButton;
//@property (nonatomic, strong) UIPickerView *repeatTimesPicker;
//@property (nonatomic, strong) UIToolbar *pickerToolbar;
//@property (nonatomic, strong) UIButton *showRepeatPickerButton;
//@property (nonatomic, strong) UITextField *locationSearchTextField;
//@property (nonatomic, strong) UIButton *locationSearchButton;
@property (nonatomic, strong) GMSMapView *map;
@property (nonatomic, strong) UITextView *addressTitle;
@property (nonatomic, strong) UIImageView *envelope;
@property (nonatomic, strong) UIScrollView *friendScroller;

//@property (nonatomic, strong) UIBarButtonItem *doneButton;
//@property (nonatomic, strong) UIButton *closeButton;
//@property (nonatomic, strong) UIView *tapView;
@property (nonatomic, strong) UIButton *pictureButton;
@property (nonatomic, strong) UIImagePickerController *imagePicker;
@property (nonatomic, strong) UIImage *thumbnailImage;
@property (nonatomic, strong) UIImageView *thumbnailImageView;
@property (nonatomic, strong) UIGestureRecognizer *tapRecognizer;


@end

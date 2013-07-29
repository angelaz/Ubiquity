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
@property (nonatomic, strong) UITextField *toRecipientTextField;
@property (nonatomic, strong) UILabel *toLabel;
@property (nonatomic, strong) UITextField *messageTextField;
@property (nonatomic, strong) UIButton *sendButton;
@property (nonatomic, strong) UIPickerView *repeatTimesPicker;
@property (nonatomic, strong) UIToolbar *pickerToolbar;
@property (nonatomic, strong) UIButton *showRepeatPickerButton;
@property (nonatomic, strong) UITextField *locationSearchTextField;
@property (nonatomic, strong) UIButton *locationSearchButton;
@property (nonatomic, strong) GMSMapView *map;
@property (nonatomic, strong) UIBarButtonItem *doneButton;
@property (nonatomic, strong) UIButton *closeButton;
@end

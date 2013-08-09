//
//  NewMessageView.m
//  Ubiquity
//
//  Created by Winnie Wu on 7/26/13.
//  Copyright (c) 2013 Team Ubi. All rights reserved.
//

#import "NewMessageView.h"
#import "AppDelegate.h"
#import "LocationController.h"

@interface NewMessageView ()


@end

@implementation NewMessageView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        int const SCREEN_WIDTH = frame.size.width;
        int const SCREEN_HEIGHT = frame.size.height;
        int const LEFT_PADDING = 30;
        int const LINE_HEIGHT = 30;
        
         
        LocationController* locationController = [LocationController sharedLocationController];
        CLLocationCoordinate2D currentCoordinate = locationController.location.coordinate;
        
        NSLog(@"Long: %f", currentCoordinate.longitude);
        NSLog(@"Lat: %f", currentCoordinate.latitude);
        GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:currentCoordinate.latitude + 2
                                                                longitude:currentCoordinate.longitude
                                                                     zoom:6];
        self.map = [GMSMapView mapWithFrame: CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT) camera:camera];
        GMSMarker *marker = [[GMSMarker alloc] init];
        marker.position = currentCoordinate;
        marker.title = @"Here";
        marker.snippet = @"My location";
        //marker.animated = YES;
        marker.map = self.map;
        [self addSubview:self.map];
        
        
        UIImageView *speechBubbleBackground = [[UIImageView alloc] initWithFrame:CGRectMake(LEFT_PADDING-20, LEFT_PADDING-20, SCREEN_WIDTH - LEFT_PADDING + 10, 240)];
        speechBubbleBackground.image = [UIImage imageNamed:@"SpeechBubble"];
        [self addSubview:speechBubbleBackground];
        
        
        self.toLabel = [[UILabel alloc] initWithFrame:CGRectMake(LEFT_PADDING, LEFT_PADDING-5, 50, LINE_HEIGHT)];
        self.toLabel.text = @"To:";
        [self addSubview:self.toLabel];
        
        self.toRecipientButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        self.toRecipientButton.frame = CGRectMake(LEFT_PADDING + 30, LEFT_PADDING-5, 230.0, LINE_HEIGHT);
        [self.toRecipientButton setTitle: @"Select Recipients" forState: UIControlStateNormal];
        [self addSubview:self.toRecipientButton];
        
        
        
        
        self.messageTextFieldBg = [[UITextField alloc] initWithFrame:CGRectMake(LEFT_PADDING, 35.0+ LINE_HEIGHT, 260.0, 140.0)];
        self.messageTextFieldBg.allowsEditingTextAttributes = NO;
        self.messageTextFieldBg.borderStyle = UITextBorderStyleRoundedRect;
        [self addSubview:self.messageTextFieldBg];
        
        
        self.messageTextView = [[UITextView alloc] initWithFrame:CGRectMake(LEFT_PADDING+5, 40.0+ LINE_HEIGHT, 250.0, 130.0)];
        [self addSubview:self.messageTextView];
        
        
        self.locationSearchTextField = [[UITextField alloc] initWithFrame:CGRectMake(LEFT_PADDING - 20, SCREEN_HEIGHT - 125, 250.0, LINE_HEIGHT)];
        self.locationSearchTextField.placeholder = @"Search for a location";
        self.locationSearchTextField.borderStyle = UITextBorderStyleRoundedRect;
        [self addSubview:self.locationSearchTextField];
        
        
        
        self.locationSearchButton = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *btnImage = [UIImage imageNamed:@"searchbutton"];
        [self.locationSearchButton setBackgroundImage: btnImage forState: UIControlStateNormal];
        self.locationSearchButton.frame = CGRectMake(SCREEN_WIDTH - 50, SCREEN_HEIGHT - 130, LINE_HEIGHT*1.2, LINE_HEIGHT*1.2);
        
        [self addSubview:self.locationSearchButton];
        

        self.sendButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        self.sendButton.frame = CGRectMake(LEFT_PADDING, SCREEN_HEIGHT - 85, SCREEN_WIDTH - LEFT_PADDING * 2, LINE_HEIGHT+5);
        [self.sendButton setTitle: @"Send" forState:UIControlStateNormal];
        [self addSubview:self.sendButton];
        
        
        
        self.pictureButton = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *pictureButtonImage = [UIImage imageNamed:@"camera"];
        [self.pictureButton setBackgroundImage:pictureButtonImage forState:UIControlStateNormal];
        self.pictureButton.frame = CGRectMake(SCREEN_WIDTH - 55, 182, 20.0, 20.0);
        [self addSubview:self.pictureButton];
    }
    return self;
}


@end

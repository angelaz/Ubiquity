//
//  NewMessageView.m
//  Ubiquity
//
//  Created by Winnie Wu on 7/26/13.
//  Copyright (c) 2013 Team Ubi. All rights reserved.
//

static CGFloat const kHeaderFontSize = 20.f;


#import "NewMessageView.h"
#import "AppDelegate.h"
#import "LocationController.h"

@interface NewMessageView ()


@end

int const TOP_PADDING = 20;
int const LEFT_PADDING = 20;
int const HEADER_HEIGHT = 30;
int const LINE_HEIGHT = 30;

@implementation NewMessageView


- (void) setUpMapWithWidth: (int) w andHeight: (int) h atCoordinate: (CLLocationCoordinate2D) c
{
    
    NSLog(@"Long: %f", c.longitude);
    NSLog(@"Lat: %f", c.latitude);
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:c.latitude + 2
                                                            longitude:c.longitude
                                                                 zoom:6];
    self.map = [GMSMapView mapWithFrame: CGRectMake(0, 0, w, h) camera:camera];
    GMSMarker *marker = [[GMSMarker alloc] init];
    marker.position = c;
    marker.animated = YES;
    marker.map = self.map;
    [self addSubview:self.map];
    
}

- (void) createEnvelopeBackgroundWithWidth: (int)w andHeight: (int)h
{
    int imageWidth = w * 19 / 20;
    int imageHeight = h * 19 / 20;
    self.envelope = [[UIImageView alloc] initWithFrame:CGRectMake(w/2 - imageWidth / 2, h - imageHeight, imageWidth, imageHeight)];
    self.envelope.image = [UIImage imageNamed:@"envelope"];
    [self addSubview:self.envelope];
    
}

- (void) createAddressTitleBarWithWidth: (int)w andHeight: (int)h
{
    int addressWidth = w * 3 / 5;
    int addressHeight = HEADER_HEIGHT * 2;
    self.addressTitle = [[UITextView alloc] initWithFrame: CGRectMake(w/2 - addressWidth/2, h-self.envelope.frame.size.height+ TOP_PADDING, addressWidth, addressHeight)];
    self.addressTitle.textAlignment = NSTextAlignmentCenter;
    self.addressTitle.font = [UIFont systemFontOfSize: kHeaderFontSize];
    self.addressTitle.text = @"Address";
    self.addressTitle.scrollEnabled = NO;
    [self addSubview:self.addressTitle];
    
}

- (void) createToLabelWithWidth: (int) w andHeight: (int) h
{
    int innerFrameLeftMargin = w/2 - self.envelope.frame.size.width/2;
    int innerFrameTopMargin = h - self.envelope.frame.size.height + TOP_PADDING + HEADER_HEIGHT * 2;
    self.toLabel = [[UILabel alloc] initWithFrame:CGRectMake(innerFrameLeftMargin + LEFT_PADDING, innerFrameTopMargin + TOP_PADDING, 50, LINE_HEIGHT)];
    self.toLabel.text = @"To:";
    [self addSubview:self.toLabel];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        int const SCREEN_WIDTH = frame.size.width;
        int const SCREEN_HEIGHT = frame.size.height;
        
        
        LocationController* locationController = [LocationController sharedLocationController];
        CLLocationCoordinate2D currentCoordinate = locationController.location.coordinate;
        
        
        [self setUpMapWithWidth: SCREEN_WIDTH andHeight:SCREEN_HEIGHT atCoordinate:currentCoordinate];
        
        [self createEnvelopeBackgroundWithWidth: SCREEN_WIDTH andHeight:SCREEN_HEIGHT];
        
        [self createAddressTitleBarWithWidth:SCREEN_WIDTH andHeight:SCREEN_HEIGHT];
        
        //
        //        UIImageView *speechBubbleBackground = [[UIImageView alloc] initWithFrame:CGRectMake(LEFT_PADDING-20, LEFT_PADDING-20, SCREEN_WIDTH - LEFT_PADDING + 10, 240)];
        //        speechBubbleBackground.image = [UIImage imageNamed:@"SpeechBubble"];
        //        [self addSubview:speechBubbleBackground];
        //
        //
        
        //
        //        self.toRecipientButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        //        self.toRecipientButton.frame = CGRectMake(LEFT_PADDING + 30, LEFT_PADDING-5, 230.0, LINE_HEIGHT);
        //        [self.toRecipientButton setTitle: @"Select Recipients" forState: UIControlStateNormal];
        //        [self addSubview:self.toRecipientButton];
        //
        //
        //
        //
        //        self.messageTextFieldBg = [[UITextField alloc] initWithFrame:CGRectMake(LEFT_PADDING, 35.0+ LINE_HEIGHT, 260.0, 140.0)];
        //        self.messageTextFieldBg.allowsEditingTextAttributes = NO;
        //        self.messageTextFieldBg.borderStyle = UITextBorderStyleRoundedRect;
        //        [self addSubview:self.messageTextFieldBg];
        //
        //
        //        self.messageTextView = [[UITextView alloc] initWithFrame:CGRectMake(LEFT_PADDING+5, 40.0+ LINE_HEIGHT, 250.0, 130.0)];
        //        [self addSubview:self.messageTextView];
        //
        //
        //        self.locationSearchTextField = [[UITextField alloc] initWithFrame:CGRectMake(LEFT_PADDING - 20, SCREEN_HEIGHT - 125, 250.0, LINE_HEIGHT)];
        //        self.locationSearchTextField.placeholder = @"Search for a location";
        //        self.locationSearchTextField.borderStyle = UITextBorderStyleRoundedRect;
        //        [self addSubview:self.locationSearchTextField];
        //
        //
        //
        //        self.locationSearchButton = [UIButton buttonWithType:UIButtonTypeCustom];
        //        UIImage *btnImage = [UIImage imageNamed:@"searchbutton"];
        //        [self.locationSearchButton setBackgroundImage: btnImage forState: UIControlStateNormal];
        //        self.locationSearchButton.frame = CGRectMake(SCREEN_WIDTH - 50, SCREEN_HEIGHT - 130, LINE_HEIGHT*1.2, LINE_HEIGHT*1.2);
        //
        //        [self addSubview:self.locationSearchButton];
        //
        //
        //        self.sendButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        //        self.sendButton.frame = CGRectMake(LEFT_PADDING, SCREEN_HEIGHT - 85, SCREEN_WIDTH - LEFT_PADDING * 2, LINE_HEIGHT+5);
        //        [self.sendButton setTitle: @"Send" forState:UIControlStateNormal];
        //        [self addSubview:self.sendButton];
        //
        //
        //
        //        self.pictureButton = [UIButton buttonWithType:UIButtonTypeCustom];
        //        UIImage *pictureButtonImage = [UIImage imageNamed:@"camera"];
        //        [self.pictureButton setBackgroundImage:pictureButtonImage forState:UIControlStateNormal];
        //        self.pictureButton.frame = CGRectMake(SCREEN_WIDTH - 55, 182, 20.0, 20.0);
        //        [self addSubview:self.pictureButton];
    }
    return self;
}


@end

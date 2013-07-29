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
        self.map = [GMSMapView mapWithFrame: CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT+30) camera:camera];
        GMSMarker *marker = [[GMSMarker alloc] init];
        marker.position = currentCoordinate;
        marker.title = @"Here";
        marker.snippet = @"My location";
        marker.map = self.map;
        [self addSubview:self.map];
        
        UIImageView *speechBubbleBackground = [[UIImageView alloc] initWithFrame:CGRectMake(LEFT_PADDING-20, LEFT_PADDING + LINE_HEIGHT, SCREEN_WIDTH - LEFT_PADDING + 10, 240)];
        speechBubbleBackground.image = [UIImage imageNamed:@"SpeechBubble"];
        [self addSubview:speechBubbleBackground];
        
        self.toLabel = [[UILabel alloc] initWithFrame:CGRectMake(LEFT_PADDING, 45 + LINE_HEIGHT, 50, LINE_HEIGHT)];
        self.toLabel.text = @"To:";
        [self addSubview:self.toLabel];
        
        self.toRecipientTextField = [[UITextField alloc] initWithFrame:CGRectMake(LEFT_PADDING + 30, 45+ LINE_HEIGHT, 230.0, LINE_HEIGHT)];
        self.toRecipientTextField.borderStyle = UITextBorderStyleRoundedRect;
        [self addSubview:self.toRecipientTextField];
        
        self.messageTextField = [[UITextField alloc] initWithFrame:CGRectMake(LEFT_PADDING, 85.0+ LINE_HEIGHT, 260.0, 140.0)];
        self.messageTextField.borderStyle = UITextBorderStyleRoundedRect;
        [self addSubview:self.messageTextField];
        
        
        self.locationSearchTextField = [[UITextField alloc] initWithFrame:CGRectMake(LEFT_PADDING - 10, SCREEN_HEIGHT - 70, 250.0, LINE_HEIGHT)];
        self.locationSearchTextField.placeholder = @"Search for a location";
        self.locationSearchTextField.borderStyle = UITextBorderStyleRoundedRect;
        [self addSubview:self.locationSearchTextField];
        
        
        
        self.locationSearchButton = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *btnImage = [UIImage imageNamed:@"searchbutton"];
        [self.locationSearchButton setBackgroundImage: btnImage forState: UIControlStateNormal];
        self.locationSearchButton.frame = CGRectMake(SCREEN_WIDTH - 40, SCREEN_HEIGHT - 68, LINE_HEIGHT-5, LINE_HEIGHT-5);
        
        [self addSubview:self.locationSearchButton];
        
        
        self.closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *closeButtonImage = [UIImage imageNamed:@"CloseButton"];
        [self.closeButton setBackgroundImage:closeButtonImage forState:UIControlStateNormal];
        self.closeButton.frame = CGRectMake(SCREEN_WIDTH - 40, 25, LINE_HEIGHT, LINE_HEIGHT);
        [self addSubview:self.closeButton];
        
        self.sendButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        self.sendButton.frame = CGRectMake(SCREEN_WIDTH - 60, SCREEN_HEIGHT - 28, 50, LINE_HEIGHT);
        [self.sendButton setTitle: @"Send" forState:UIControlStateNormal];
        [self addSubview:self.sendButton];
        
        
        self.repeatTimesPicker = [[UIPickerView alloc] initWithFrame: CGRectMake(LEFT_PADDING-10, SCREEN_HEIGHT - 130, 280, LINE_HEIGHT)];
        self.repeatTimesPicker.backgroundColor = [UIColor whiteColor];
        self.repeatTimesPicker.showsSelectionIndicator = YES;
        
        
        
        self.showRepeatPickerButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        self.showRepeatPickerButton.frame = CGRectMake(LEFT_PADDING-10, SCREEN_HEIGHT - 28, SCREEN_WIDTH - 100, 30.0);
        [self addSubview:self.showRepeatPickerButton];
        
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end

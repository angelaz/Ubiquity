//
//  NewMessageView.m
//  Ubiquity
//
//  Created by Winnie Wu on 7/26/13.
//  Copyright (c) 2013 Team Ubi. All rights reserved.
//

#import "NewMessageView.h"
#import "AppDelegate.h"

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
        
        
        AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        CLLocationCoordinate2D currentCoordinate = appDelegate.currentLocation.coordinate;
        NSLog(@"Long: %f", currentCoordinate.longitude);
        NSLog(@"Lat: %f", currentCoordinate.latitude);
        GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:currentCoordinate.latitude + 2
                                                                longitude:currentCoordinate.longitude
                                                                     zoom:6];
        self.map = [GMSMapView mapWithFrame: CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT+30) camera:camera];
        [self addSubview:self.map];
        
        UIImageView *speechBubbleBackground = [[UIImageView alloc] initWithFrame:CGRectMake(LEFT_PADDING-20, LEFT_PADDING, SCREEN_WIDTH - LEFT_PADDING + 10, 240)];
        speechBubbleBackground.image = [UIImage imageNamed:@"SpeechBubble"];
        [self addSubview:speechBubbleBackground];
        
        self.toLabel = [[UILabel alloc] initWithFrame:CGRectMake(LEFT_PADDING, 45, 50, LINE_HEIGHT)];
        self.toLabel.text = @"To:";
        [self addSubview:self.toLabel];
        
        self.toRecipientTextField = [[UITextField alloc] initWithFrame:CGRectMake(LEFT_PADDING + 30, 45, 230.0, LINE_HEIGHT)];
        self.toRecipientTextField.borderStyle = UITextBorderStyleRoundedRect;
        [self addSubview:self.toRecipientTextField];
        
        self.messageTextField = [[UITextField alloc] initWithFrame:CGRectMake(LEFT_PADDING, 85.0, 260.0, 140.0)];
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
//        [self.locationSearchButton addTarget:self action:@selector(startSearch:) forControlEvents:UIControlEventTouchUpInside];
        //  [self.locationSearchButton setTitle: @"Go" forState:UIControlStateNormal]; // replace with mag glass later
        
        [self addSubview:self.locationSearchButton];
        
        
        
        
        self.sendButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        //self.sendButton.backgroundColor = [UIColor whiteColor];
        self.sendButton.frame = CGRectMake(SCREEN_WIDTH - 60, SCREEN_HEIGHT - 28, 50, LINE_HEIGHT);
//        [self.sendButton addTarget:self action:@selector(sendMessage:) forControlEvents:UIControlEventTouchUpInside];
        [self.sendButton setTitle: @"Send" forState:UIControlStateNormal];
        [self addSubview:self.sendButton];
        
        
        self.repeatTimesPicker = [[UIPickerView alloc] initWithFrame: CGRectMake(LEFT_PADDING-10, SCREEN_HEIGHT - 130, 280, LINE_HEIGHT)];
//        self.repeatTimesPicker.delegate = self;
        self.repeatTimesPicker.backgroundColor = [UIColor whiteColor];
//        self.repeatTimesPicker.dataSource = self;
        self.repeatTimesPicker.showsSelectionIndicator = YES;
        
        self.pickerToolbar = [[UIToolbar alloc] init];
        self.pickerToolbar.barStyle = UIBarStyleDefault;
        self.pickerToolbar.translucent = NO;
        [self.pickerToolbar sizeToFit];
        UIBarButtonItem* doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                       style:UIBarButtonItemStyleBordered target:nil
                                                                      action:nil];
        
        [self.pickerToolbar setItems:[NSArray arrayWithObjects:doneButton, nil]];
        
        
        self.showRepeatPickerButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        //self.showRepeatPickerButton.backgroundColor = [UIColor whiteColor];
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

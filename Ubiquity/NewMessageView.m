//
//  NewMessageView.m
//  Ubiquity
//
//  Created by Winnie Wu on 7/26/13.
//  Copyright (c) 2013 Team Ubi. All rights reserved.
//

static CGFloat const kHeaderFontSize = 20.f;
static CGFloat const kFromFontSize = 15.f;
static CGFloat const kSentLabelFontSize = 12.f;
static CGFloat const kMessageFontSize = 11.f;




#import "NewMessageView.h"
#import "AppDelegate.h"
#import "LocationController.h"

@interface NewMessageView ()


@end

int const TOP_PADDING = 20;
int const ADDRESS_PADDING = 10;
int const LEFT_PADDING = 50;
int const HEADER_HEIGHT = 30;
int const LINE_HEIGHT = 30;
#define WIDEST_POINT self.envelope.frame.size.width * 7/10;

@implementation NewMessageView


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
        
        [self createToLabelWithWidth:SCREEN_WIDTH andHeight:SCREEN_HEIGHT];
        
        [self createMessageWithWidth:SCREEN_WIDTH andHeight:SCREEN_HEIGHT];
        
        [self createFromLabelWithWidth:SCREEN_WIDTH andHeight:SCREEN_HEIGHT];
        
        [self createSentLabelWithWidth:SCREEN_WIDTH andHeight:SCREEN_HEIGHT];
        
        [self createPictureButtonWithWidth:SCREEN_WIDTH andHeight:SCREEN_HEIGHT];
        
         [self createAddFriendsButtonWithWidth:SCREEN_WIDTH andHeight:SCREEN_HEIGHT];
        
        [self createScrollViewWithWidth:SCREEN_WIDTH andHeight:SCREEN_HEIGHT];
        
    }
    return self;
}


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
    int addressWidth = WIDEST_POINT;
    int addressHeight = HEADER_HEIGHT;
    self.addressTitle = [[UITextView alloc] initWithFrame: CGRectMake(w/2 - addressWidth/2, h-self.envelope.frame.size.height+ ADDRESS_PADDING, addressWidth, addressHeight)];
    self.addressTitle.textAlignment = NSTextAlignmentCenter;
    self.addressTitle.font = [UIFont systemFontOfSize: kHeaderFontSize];
    self.addressTitle.text = @"<INSERT ADDRESS>";
    self.addressTitle.scrollEnabled = NO;
    // self.addressTitle.backgroundColor = [UIColor greenColor];
    self.addressTitle.backgroundColor = [UIColor clearColor];
    [self addSubview:self.addressTitle];
    
}

- (void) createToLabelWithWidth: (int) w andHeight: (int) h
{
    int innerFrameLeftMargin = w/2 - self.envelope.frame.size.width/2 + LEFT_PADDING;
    int innerFrameTopMargin = h - self.envelope.frame.size.height + HEADER_HEIGHT + TOP_PADDING * 0.5;
    self.toLabel = [[UILabel alloc] initWithFrame:CGRectMake(innerFrameLeftMargin, innerFrameTopMargin, 50, LINE_HEIGHT)];
    self.toLabel.font = [UIFont systemFontOfSize: kFromFontSize];
    self.toLabel.text = @"To:";
    [self addSubview:self.toLabel];
}

- (void) createMessageWithWidth: (int) w andHeight: (int) h
{
    int innerFrameTopMargin = h - self.envelope.frame.size.height + HEADER_HEIGHT + TOP_PADDING * 2.5;
    int width = WIDEST_POINT;
    int height = h * 2 / 5 ;
    int innerFrameLeftMargin = w/2 - width/2;
    self.messageTextView = [[UITextView alloc] initWithFrame:CGRectMake(innerFrameLeftMargin, innerFrameTopMargin, width, height)];
    //  self.messageTextView.backgroundColor = [UIColor greenColor];
    self.messageTextView.text = @"Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.";
    self.messageTextView.font = [UIFont systemFontOfSize: kMessageFontSize];
    self.messageTextView.backgroundColor = [UIColor clearColor];
    [self addSubview:self.messageTextView];
    
}

- (void) createFromLabelWithWidth: (int) w andHeight: (int) h
{
    int width = WIDEST_POINT;
    int innerFrameLeftMargin = w/2 - width/2;
    int innerFrameTopMargin = h - TOP_PADDING * 9.5;
    self.fromLabel = [[UILabel alloc] initWithFrame:CGRectMake(innerFrameLeftMargin, innerFrameTopMargin, width, LINE_HEIGHT)];
    self.fromLabel.text = @"<INSERT SENDERS NAME>";
    self.fromLabel.textAlignment = NSTextAlignmentRight;
    self.fromLabel.font = [UIFont systemFontOfSize: kFromFontSize];
    [self addSubview:self.fromLabel];
}

- (void) createSentLabelWithWidth: (int) w andHeight: (int) h
{
    int width = WIDEST_POINT;
    int innerFrameLeftMargin = w/2 - width/2;
    int innerFrameTopMargin = h - TOP_PADDING * 8;
    self.sentLabel = [[UILabel alloc] initWithFrame:CGRectMake(innerFrameLeftMargin, innerFrameTopMargin, width, LINE_HEIGHT)];
    self.sentLabel.text = @"10:20 AM, 03 August 2013";
    // self.sentLabel.backgroundColor = [UIColor greenColor];
    self.sentLabel.backgroundColor = [UIColor clearColor];
    
    self.sentLabel.textAlignment = NSTextAlignmentCenter;
    self.sentLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.sentLabel.numberOfLines = 2;
    self.sentLabel.font = [UIFont systemFontOfSize: kSentLabelFontSize];
    [self addSubview:self.sentLabel];
}

- (void) createPictureButtonWithWidth: (int) w andHeight: (int) h
{
    self.pictureButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *pictureButtonImage = [UIImage imageNamed:@"camera"];
    [self.pictureButton setBackgroundImage:pictureButtonImage forState:UIControlStateNormal];
    int width = WIDEST_POINT;
    int innerFrameLeftMargin = w/2 + width/2 - 20.0;
    int innerFrameTopMargin = h - TOP_PADDING * 10.5;
    self.pictureButton.frame = CGRectMake(innerFrameLeftMargin, innerFrameTopMargin, 20.0, 20.0);
    [self addSubview:self.pictureButton];
}

- (void) createAddFriendsButtonWithWidth: (int)w andHeight: (int) h
{
    int iconDimensions = 30 ;
    self.addFriendsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.addFriendsButton setBackgroundImage: [UIImage imageNamed:@"addFriend"] forState:UIControlStateNormal];
    int innerFrameLeftMargin = w/2 - self.envelope.frame.size.width/2 + LEFT_PADDING + 30;
    int innerFrameTopMargin = h - self.envelope.frame.size.height + HEADER_HEIGHT + TOP_PADDING * 0.75;
    self.addFriendsButton.frame = CGRectMake(innerFrameLeftMargin, innerFrameTopMargin, iconDimensions, iconDimensions);
    [self addSubview: self.addFriendsButton];
}

- (void) createScrollViewWithWidth: (int)w andHeight:(int)h
{
    int innerFrameLeftMargin = w/2 - self.envelope.frame.size.width/2 + LEFT_PADDING + 65;
    int innerFrameTopMargin = h - self.envelope.frame.size.height + HEADER_HEIGHT + TOP_PADDING * 0.75;
    self.friendScroller = [[UIScrollView alloc] initWithFrame: CGRectMake(innerFrameLeftMargin, innerFrameTopMargin, w * 5/11, 30)];
    self.friendScroller.contentSize = self.friendScroller.frame.size;
  //  self.friendScroller.backgroundColor = [UIColor greenColor];
    [self.friendScroller setScrollEnabled:YES];
    [self addSubview: self.friendScroller];
}



@end

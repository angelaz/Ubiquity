//
//  NoteView.m
//  Ubiquity
//
//  Created by Winnie Wu on 8/13/13.
//  Copyright (c) 2013 Team Ubi. All rights reserved.
//

static CGFloat const kHeaderFontSize = 20.f;
static CGFloat const kFromFontSize = 15.f;
static CGFloat const kSentLabelFontSize = 12.f;
static CGFloat const kMessageFontSize = 11.f;


#import "NoteView.h"
#import "NewMessageView.h"


@implementation NoteView
#define WIDEST_POINT self.envelope.frame.size.width * 7/10;


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        int const SCREEN_WIDTH = frame.size.width;
        int const SCREEN_HEIGHT = frame.size.height;
        
        
        [self createEnvelopeBackgroundWithWidth: SCREEN_WIDTH andHeight:SCREEN_HEIGHT];
        
        [self createAddressTitleBarWithWidth:SCREEN_WIDTH andHeight:SCREEN_HEIGHT];
        
        [self createReceivedLabelWithWidth:SCREEN_WIDTH andHeight:SCREEN_HEIGHT];
        
        [self createMessageWithWidth:SCREEN_WIDTH andHeight:SCREEN_HEIGHT];
        
        [self createFromLabelWithWidth:SCREEN_WIDTH andHeight:SCREEN_HEIGHT];
        
        [self createSentLabelWithWidth:SCREEN_WIDTH andHeight:SCREEN_HEIGHT];
        
    }
    return self;
}



- (void) createEnvelopeBackgroundWithWidth: (int)w andHeight: (int)h
{
    int imageWidth = w * 19 / 20;
    int imageHeight = h * 19 / 20;
    self.envelope = [[UIImageView alloc] initWithFrame:CGRectMake(w/2 - imageWidth / 2, h - imageHeight, imageWidth, imageHeight)];
    self.envelope.image = [UIImage imageNamed:@"envelope"];
    [self addSubview:self.envelope];
    
}

- (void) createSentLabelWithWidth: (int) w andHeight: (int) h
{
    int width = WIDEST_POINT;
    int innerFrameLeftMargin = w/2 - width/2;
    int innerFrameTopMargin = h-self.envelope.frame.size.height+ ADDRESS_PADDING/2;
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

- (void) createAddressTitleBarWithWidth: (int)w andHeight: (int)h
{
    int addressWidth = WIDEST_POINT;
    int addressHeight = HEADER_HEIGHT;
    self.addressTitle = [[UILabel alloc] initWithFrame: CGRectMake(w/2 - addressWidth/2, h-self.envelope.frame.size.height+ ADDRESS_PADDING*3, addressWidth, addressHeight)];
    self.addressTitle.textAlignment = NSTextAlignmentCenter;
    self.addressTitle.font = [UIFont systemFontOfSize: kHeaderFontSize];
    self.addressTitle.text = @"<INSERT ADDRESS>";
    // self.addressTitle.backgroundColor = [UIColor greenColor];
    self.addressTitle.backgroundColor = [UIColor clearColor];
    [self addSubview:self.addressTitle];
    
}


- (void) createMessageWithWidth: (int) w andHeight: (int) h
{
    int innerFrameTopMargin = h - self.envelope.frame.size.height + HEADER_HEIGHT + TOP_PADDING * 1.5;
    int width = WIDEST_POINT;
    int height = h * 2 / 5 ;
    int innerFrameLeftMargin = w/2 - width/2;
    self.textScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(innerFrameLeftMargin, innerFrameTopMargin, width, height)];
    self.messageTextView.backgroundColor = [UIColor greenColor];
    self.messageTextView = [[UILabel alloc] initWithFrame: CGRectMake(0, 0, width, height)];
    self.messageTextView.lineBreakMode = NSLineBreakByWordWrapping;
    self.messageTextView.numberOfLines = 0;
    self.messageTextView.text = @"Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.";
    [self.textScroll addSubview: self.messageTextView];
    self.messageTextView.font = [UIFont systemFontOfSize: kMessageFontSize];
    self.messageTextView.backgroundColor = [UIColor clearColor];
    [self addSubview:self.textScroll];
    
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



- (void) createReceivedLabelWithWidth: (int) w andHeight: (int) h
{
    int width = WIDEST_POINT;
    int innerFrameLeftMargin = w/2 - width/2;
    int innerFrameTopMargin = h - TOP_PADDING * 8;
    self.receivedLabel = [[UILabel alloc] initWithFrame:CGRectMake(innerFrameLeftMargin, innerFrameTopMargin, width, LINE_HEIGHT)];
    self.receivedLabel.text = @"10:20 AM, 08 August 2013";
    // self.sentLabel.backgroundColor = [UIColor greenColor];
    self.receivedLabel.backgroundColor = [UIColor clearColor];
    
    self.receivedLabel.textAlignment = NSTextAlignmentCenter;
    self.receivedLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.receivedLabel.numberOfLines = 2;
    self.receivedLabel.font = [UIFont systemFontOfSize: kSentLabelFontSize];
    [self addSubview:self.receivedLabel];
}



@end

//
//  NoteView.m
//  Ubiquity
//
//  Created by Winnie Wu on 8/13/13.
//  Copyright (c) 2013 Team Ubi. All rights reserved.
//

static CGFloat const kHeaderFontSize = 16.f;
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
        [self createPagingLabelWithWidth:SCREEN_WIDTH andHeight:SCREEN_HEIGHT];
        [self createImageViewWithWidth:SCREEN_WIDTH andHeight:SCREEN_HEIGHT];
        [self createPictureButtonWithWidth:SCREEN_WIDTH andHeight:SCREEN_HEIGHT];

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

- (void) createPagingLabelWithWidth: (int) w andHeight: (int) h
{
    int width = WIDEST_POINT;
    int innerFrameLeftMargin = w/2 + width/2 - LEFT_PADDING*1.1;
    int innerFrameTopMargin = h-self.envelope.frame.size.height+ ADDRESS_PADDING/2;
    self.pagingLabel = [[UILabel alloc] initWithFrame:CGRectMake(innerFrameLeftMargin, innerFrameTopMargin, width/3.5, LINE_HEIGHT)];
    self.pagingLabel.text = @"1 of 2";
    // self.sentLabel.backgroundColor = [UIColor greenColor];
    self.pagingLabel.backgroundColor = [UIColor clearColor];
    
    self.pagingLabel.textAlignment = NSTextAlignmentRight;
    self.pagingLabel.font = [UIFont systemFontOfSize: kSentLabelFontSize];
    [self addSubview:self.pagingLabel];
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
    self.messageTextView = [[UILabel alloc] initWithFrame: CGRectMake(0, 0, width, height)];
    self.messageTextView.lineBreakMode = NSLineBreakByWordWrapping;
    self.messageTextView.numberOfLines = 0;

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

- (void) createImageViewWithWidth: (int) w andHeight: (int) h
{
    int width = WIDEST_POINT;
    int height = self.textScroll.frame.size.height;
    int innerFrameTopMargin = self.textScroll.frame.origin.y;
    int innerFrameLeftMargin = self.textScroll.frame.origin.x;

    self.image = [[UIImageView alloc] initWithFrame:CGRectMake(innerFrameLeftMargin, innerFrameTopMargin, width, height)];
    self.image.backgroundColor = [UIColor clearColor];

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
}



@end

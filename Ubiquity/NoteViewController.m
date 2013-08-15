//
//  NoteViewController.m
//  Ubiquity
//
//  Created by Winnie Wu on 8/13/13.
//  Copyright (c) 2013 Team Ubi. All rights reserved.
//

#import "NoteViewController.h"
#import "NoteView.h"
#import <Parse/Parse.h>
#import "TextMessage.h"

@interface NoteViewController()
{
    UISwipeGestureRecognizer *swipeLeft;
    UISwipeGestureRecognizer *swipeRight;
    BOOL swipedLeft;
    BOOL showingImage;
    int currentNote;
}

@property (nonatomic, strong) NoteView *nv;

@end

@implementation NoteViewController



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    // Do any additional setup after loading the view.
    
    _nv = [[NoteView alloc] initWithFrame: [UIScreen mainScreen].bounds];
    [self setView: _nv];
    
    
    UIBarButtonItem *doneButton= [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                               target:self
                                                                               action:@selector(closeNote:)];
    [[self navigationItem] setRightBarButtonItem:doneButton];
    
    
    currentNote = 0;
    swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(nextTab:)];
    [swipeLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
    [self.view addGestureRecognizer:swipeLeft];
    
    swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(nextTab:)];
    [swipeRight setDirection:UISwipeGestureRecognizerDirectionRight];
    [self.view addGestureRecognizer:swipeRight];
    
    
    [self loadNotesText: currentNote];
    
    
    
    
    
}

- (void)nextTab:(id)sender
{
    if (sender == swipeLeft && (currentNote + 1) < self.notes.count)
    {
        swipedLeft = true;
        currentNote++;
    }
    else if (sender == swipeRight && currentNote > 0)
    {
        swipedLeft = false;
        currentNote --;
    } else {
        return;
    }
    self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height);
    
    CGFloat newXOrigin = self.view.frame.origin.x;
    if (swipedLeft)
        newXOrigin -= self.view.frame.size.width;
    else
        newXOrigin += self.view.frame.size.width;
    
    [UIView animateWithDuration:0.25
                     animations:^{
                         self.view.frame = CGRectMake(newXOrigin, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height);
                         
                     }];
    
    [self performSelector:@selector(moveNote) withObject:self afterDelay:0.25];
    
    
    
    
    
}
- (void) moveNote
{
    CGFloat newXOrigin;
    if (swipedLeft)
        newXOrigin = self.view.frame.size.width;
    else
        newXOrigin = -self.view.frame.size.width;
    
    self.view.frame = CGRectMake(newXOrigin, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height);
    if (swipedLeft)
        newXOrigin -= self.view.frame.size.width;
    else
        newXOrigin += self.view.frame.size.width;
    
    [self loadNotesText: currentNote];
    
    [UIView animateWithDuration:0.25
                     animations:^{
                         self.view.frame = CGRectMake(newXOrigin, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height);
                     }];
    
}


- (void) loadNotesText: (int) i
{
    showingImage = false;
    [_nv.leftArrow removeFromSuperview];
    [_nv.rightArrow removeFromSuperview];
    
    
    [self loadDates: i];
    [self loadText: i];
    [self loadImages: i];
    [self loadName: i];
    
    if (i > 0)
        [_nv addSubview:_nv.leftArrow];
    if (i+1 < self.notes.count)
        [_nv addSubview:_nv.rightArrow];
    
    _nv.addressTitle.text = [self.notes[i] objectForKey:@"locationAddress"];
    
    _nv.pagingLabel.text = [NSString stringWithFormat: @"%d of %d", i + 1, self.notes.count];
    
    
}

- (void) loadText: (int) i
{
    CGSize textSize = [[self.notes[i] objectForKey:@"text"] sizeWithFont: _nv.messageTextView.font constrainedToSize:CGSizeMake(_nv.messageTextView.frame.size.width, FLT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
    _nv.textScroll.contentSize = textSize;
    if (textSize.height > _nv.messageTextView.frame.size.height)
    {
        CGRect newFrame = _nv.messageTextView.frame;
        newFrame.size.height = textSize.height;
        _nv.messageTextView.frame = newFrame;
    }
    _nv.messageTextView.text = [self.notes[i] objectForKey:@"text"];
    
}

- (void) loadName: (int) i
{
    TextMessage *postFromObject = [[TextMessage alloc] initWithPFObject:self.notes[i]];
	NSString *name = [postFromObject.sender objectForKey:@"profile"][@"name"];
    _nv.fromLabel.text = name;
}

- (void) loadDates: (int) i
{
    // PROBLEM: showing up as (null) because createdAt field is not included in parse query return. How to work around? Will come back to this later.
    
    NSDate *date = [self.notes[i] objectForKey:@"createdAt"];
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"hh:mm a 'on' dd MMMM yyyy"];
    NSString *sentAtString = [df stringFromDate:date];
    _nv.sentLabel.text = [NSString stringWithFormat: @"Sent at: %@", sentAtString];
    
}

- (void) loadImages: (int) i
{
    [_nv.image setImage:nil];
    [_nv.pictureButton removeFromSuperview];
    
    PFFile *photoData = [self.notes[i] objectForKey:@"photo"];
    [photoData getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        UIImage *photo = [[UIImage alloc] initWithData:data];
        _nv.image.contentMode = UIViewContentModeScaleAspectFit;
        [_nv.image setImage:photo];
        [_nv addSubview:_nv.pictureButton];
        [_nv.pictureButton addTarget:self action:@selector(toggleImage:) forControlEvents:UIControlEventTouchUpInside];
        
    }];
    
    
}

- (void) toggleImage: (id) sender
{
    if (!showingImage)
    {
        [_nv addSubview:_nv.image];
        [_nv.textScroll removeFromSuperview];
        [_nv.pictureButton setImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
    } else {
        [_nv.image removeFromSuperview];
        [_nv addSubview: _nv.textScroll];
        [_nv.pictureButton setImage:[UIImage imageNamed:@"camera"] forState:UIControlStateNormal];
        
    }
    
    showingImage = !showingImage;
    
}


-(void) closeNote: (id) sender
{
    self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height);
    [UIView animateWithDuration:0.25
                     animations:^{
                         self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height);
                     }];
    
    
    [self performSelector:@selector(dismissNoteView) withObject:self afterDelay:0.25];
    
}

- (void) dismissNoteView
{
    [self dismissViewControllerAnimated:NO completion:nil];
}



@end

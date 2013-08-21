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
#import <MediaPlayer/MediaPlayer.h>

@interface NoteViewController()
{
    UISwipeGestureRecognizer *swipeLeft;
    UISwipeGestureRecognizer *swipeRight;
    BOOL swipedLeft;
    BOOL showingImage;
    int currentNote;
    
    RDPlayer* _player;
    BOOL _playing;
    BOOL _paused;
    NSString *_trackKey;
    NSMutableArray *_trackKeys;
    
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
    
    
    [_nv.leftArrow addTarget:self action:@selector(swipeController:) forControlEvents:UIControlEventTouchUpInside];
    [_nv.rightArrow addTarget:self action:@selector(swipeController:) forControlEvents:UIControlEventTouchUpInside];

    
    currentNote = 0;
    swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeController:)];
    [swipeLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
    [self.view addGestureRecognizer:swipeLeft];
    
    swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeController:)];
    [swipeRight setDirection:UISwipeGestureRecognizerDirectionRight];
    [self.view addGestureRecognizer:swipeRight];
    
    _trackKeys = [[NSMutableArray alloc] init];
    
    [self loadNotesText: currentNote];

    
    
}


- (void) swipeController: (id) sender
{
    if (sender == swipeLeft || sender == _nv.rightArrow)
        swipedLeft = true;
    else if (sender == swipeRight || sender ==_nv.leftArrow)
        swipedLeft = false;
    [self nextTab];
}

- (void) nextTab
{
    if (swipedLeft && (currentNote + 1) < self.notes.count)
    {
        currentNote++;
    }
    else if (!swipedLeft && currentNote > 0)
    {
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
    [self loadRdioMusic:i];
    
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
    PFObject *object = self.notes[i];
    NSDate *date = object.createdAt;
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"h:mm a 'on' dd MMM yyyy"];
    NSString *sentAtString = [df stringFromDate:date];
    _nv.sentLabel.text = [NSString stringWithFormat: @"Sent at: %@", sentAtString];
    
}

- (void) loadImages: (int) i
{
    
    for (id subview in [_nv.image subviews])
        [subview removeFromSuperview];
    [_nv.pictureButton removeFromSuperview];


    if([self.notes[i] objectForKey:@"mediaHeight"] > 0) {
        [_nv addSubview:_nv.pictureButton];
        [_nv.pictureButton addTarget:self action:@selector(toggleImage:) forControlEvents:UIControlEventTouchUpInside];
        _nv.image.contentMode = UIViewContentModeScaleAspectFit;
        PFFile *mediaData = [self.notes[i] objectForKey:@"media"];
        [mediaData getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            UIImage *photo = [[UIImage alloc] initWithData: data];
            if (photo) {
                UIImageView *photoView = [[UIImageView alloc] initWithImage:photo];
                [photoView setFrame:CGRectMake(0, 0, _nv.image.frame.size.width, _nv.image.frame.size.height)];
                [_nv.image addSubview:photoView];
            } else { //photo will be null if mediaData is not valid image data, so movie
                NSLog(@"look this post has a movie :O");
                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                NSString *documentsDirectory = [paths objectAtIndex:0];
                NSString *path = [documentsDirectory stringByAppendingPathComponent:@"postVideo.m4v"];
                [data writeToFile:path atomically:YES];
                NSURL *videoURL = [NSURL fileURLWithPath:path];
                MPMoviePlayerController *player = [[MPMoviePlayerController alloc] init];
                [player setContentURL:videoURL];
                [player prepareToPlay];
                [player.view setFrame:CGRectMake(0, 0, _nv.image.frame.size.width, _nv.image.frame.size.height)];
                [_nv.image addSubview:player.view];
                [player play];
            }
        }];

    }
    
}

- (void) loadRdioMusic: (int) i
{
    [_trackKeys removeAllObjects];
    _trackKey = @"";
    [_nv.musicButton removeFromSuperview];
    _trackKey = [self.notes[i] objectForKey:@"trackKey"];
    if (_trackKey)
    {
        [_nv addSubview:_nv.musicButton];
        [ _nv.musicButton setImage: [UIImage imageNamed:@"musicNote"] forState:UIControlStateNormal];
        [_nv.musicButton addTarget:self action:@selector(playMusic) forControlEvents:UIControlEventTouchUpInside];
    }
    
    
}

//rdio player
- (BOOL)rdioIsPlayingElsewhere
{
    return NO;
}
- (void)rdioPlayerChangedFromState:(RDPlayerState)fromState toState:(RDPlayerState)state
{
    _playing = (state != RDPlayerStateInitializing && state != RDPlayerStateStopped && state != RDPlayerStatePaused);
    _paused = (state == RDPlayerStatePaused);
}
- (RDPlayer*)getPlayer
{
    if (_player == nil) {
        _player = [AppDelegate rdioInstance].player;
    }
    return _player;
}

- (void)playMusic
{
        [[self getPlayer] playSource: _trackKey];
    
        [ _nv.musicButton setImage: [UIImage imageNamed:@"musicNoteRed"] forState:UIControlStateNormal];
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

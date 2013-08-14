//
//  NoteViewController.m
//  Ubiquity
//
//  Created by Winnie Wu on 8/13/13.
//  Copyright (c) 2013 Team Ubi. All rights reserved.
//

#import "NoteViewController.h"
#import "NoteView.h"

@interface NoteViewController()
{
    UISwipeGestureRecognizer *swipeLeft;
    UISwipeGestureRecognizer *swipeRight;
    BOOL swipedLeft;
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
    _nv.messageTextView.text = [self.notes[i] objectForKey:@"text"];
    _nv.addressTitle.text = [self.notes[i] objectForKey:@"locationAddress"];
    
    NSDate *date = [self.notes[i] objectForKey:@"createdAt"];
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"hh:mm a 'on' dd MMMM yyyy"];
    NSString *sentAtString = [df stringFromDate:date];
    _nv.sentLabel.text = [NSString stringWithFormat: @"Sent at: %@", sentAtString];
    
    _nv.pagingLabel.text = [NSString stringWithFormat: @"%d of %d", i + 1, self.notes.count];

    
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

//
//  NoteViewController.m
//  Ubiquity
//
//  Created by Winnie Wu on 8/13/13.
//  Copyright (c) 2013 Team Ubi. All rights reserved.
//

#import "NoteViewController.h"
#import "NoteView.h"

@implementation NoteViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    // Do any additional setup after loading the view.
    
    NoteView *nv = [[NoteView alloc] initWithFrame: [UIScreen mainScreen].bounds];
    [self setView: nv];
    
    
    UIBarButtonItem *doneButton= [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                               target:self
                                                                               action:@selector(closeNote:)];
    [[self navigationItem] setRightBarButtonItem:doneButton];
    
    
    
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

//
//  TutorialViewController.m
//  Ubiquity
//
//  Created by Catherine Morrison on 8/19/13.
//  Copyright (c) 2013 Team Ubi. All rights reserved.
//

#import "TutorialViewController.h"
#import "ArrowView.h"
#import "AppDelegate.h"
#import "NewMessageView.h"


@interface TutorialViewController ()
{
    CGFloat SCREEN_WIDTH;
    CGFloat SCREEN_HEIGHT;
    
    CGFloat BUTTON_WIDTH;
    CGFloat BUTTON_HEIGHT;
    
    int bubbleCount;
    
    ArrowView *welcomeBubble;
    ArrowView *introBubble;
    ArrowView *selfBubble;
    ArrowView *friendsBubble;
    ArrowView *publicBubble;
    ArrowView *listBubble;
    ArrowView *searchBarBubble;
    ArrowView *newMessageBubble;
    ArrowView *thankYouBubble;
    
    NewMessageView *nmv;
    UIView *cover;
}

@end

@implementation TutorialViewController

- (id)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        NSLog(@"tutorial view initialized");
    }
    return self;
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"tutorial view loaded");
	// Do any additional setup after loading the view.
    _bubbleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(nextBubble:)];
    [self.view addGestureRecognizer:_bubbleTapRecognizer];
    bubbleCount = 0;

  //  self.delegate = self;
    
    SCREEN_WIDTH = self.view.frame.size.width;
    SCREEN_HEIGHT = self.view.frame.size.height;
    
    BUTTON_WIDTH = 240;
    BUTTON_HEIGHT = 38;
    
    self.view.opaque = NO;
    self.view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5f];
    
    [self firstBubble];

}

- (void) firstBubble {
    welcomeBubble = [[ArrowView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2 - BUTTON_WIDTH/2, SCREEN_HEIGHT-300, BUTTON_WIDTH, BUTTON_HEIGHT*2.3)];
    [welcomeBubble setPointY:0.0];
    [welcomeBubble setPointHeight:0.0];
    [welcomeBubble setPointWidth:0.0];
    welcomeBubble.label.text = @"Welcome to Breadcrumbs! Tap to get started.";
    [self.view addSubview:welcomeBubble];
}

- (void) loadIntroBubble {
    
    welcomeBubble.label.text = @"Breadcrumbs are notes you can leave your friends or yourself at chosen locations.";
}


- (void) loadLongTapInstructions {
    welcomeBubble.label.text = @"To choose a location, hold your finger on the map until the location bead shifts.";
}




-(void) nextBubble: (id) sender
{
    bubbleCount++;
    switch (bubbleCount)
    {
        case 1:
            [self loadIntroBubble];
            break;
        case 2:
            [self loadLongTapInstructions];
            break;
        case 3:
            [self loadSearchBarBubble];
            break;

        case 4:
            [self loadNewMessageBubble];
            break;
        case 5:
            [self openNewMessageView];
            break;

        case 6:
            [self loadMessageViewTut1];
            break;

        case 7:
            [self loadMessageViewTut2];
            break;

        case 8:
            [self loadMessageViewTut3];
            break;
        case 9:
            [self loadMessageViewTut4];
            break;
        case 10:
            [self loadBarBubble];
            break;
        case 11:
            [self loadSelfBubble];
            break;
        case 12:
            [self loadFriendsBubble];
            break;
        case 13:
            [self loadPublicBubble];
            break;
        case 14:
            [self loadListBubble];
            break;
        case 15:
            [self loadThankYouBubble];
            break;
        case 16:
            [self didFinishTutorial];
            break;
        
    }
    
    
}

- (void)loadSearchBarBubble {
    welcomeBubble.frame = CGRectMake(SCREEN_WIDTH/8, SCREEN_HEIGHT/7, BUTTON_WIDTH, BUTTON_HEIGHT*2.3);
    [welcomeBubble setPointY:10.0];
    [welcomeBubble setPointHeight:20.0];
    [welcomeBubble setPointWidth:10.0];
    [welcomeBubble setNeedsDisplay];
    
    welcomeBubble.label.text = @"Or, you can look for an address using the search bar";
    welcomeBubble.label.numberOfLines = 3;
}


- (void)loadNewMessageBubble {
    welcomeBubble.frame = CGRectMake(SCREEN_WIDTH*29/30 - BUTTON_WIDTH, SCREEN_HEIGHT/11, BUTTON_WIDTH, BUTTON_HEIGHT*2.3);
    [welcomeBubble setPointY:210.0];
    [welcomeBubble setPointHeight:20.0];
    [welcomeBubble setPointWidth:10.0];
    [welcomeBubble setNeedsDisplay];
    
    welcomeBubble.label.text = @"When you've picked the location you want, click here to leave a Breadcrumb!";
    
    welcomeBubble.label.numberOfLines = 3;
}


- (void) openNewMessageView {
    nmv = [[NewMessageView alloc] initWithFrame: self.view.bounds];
    [self.view addSubview:nmv];
    [welcomeBubble.layer setZPosition:1.0];

    cover = [[UIView alloc] initWithFrame: self.view.bounds];
    cover.backgroundColor = [[UIColor alloc] initWithWhite: 0.0 alpha: 0.5];
    [self.view addSubview:cover];
    
    welcomeBubble.frame = CGRectMake(SCREEN_WIDTH/2 - BUTTON_WIDTH/2, SCREEN_HEIGHT/2 - BUTTON_HEIGHT*2.3, BUTTON_WIDTH, BUTTON_HEIGHT*2.3);
    [welcomeBubble setPointY:0.0];
    [welcomeBubble setPointHeight:0.0];
    [welcomeBubble setPointWidth:0.0];
    [welcomeBubble setNeedsDisplay];
    
    welcomeBubble.label.text = @"This is what you'll see when you want to leave a new Breadcrumb.";
    
    welcomeBubble.label.numberOfLines = 3;

    

}

- (void) loadMessageViewTut1 {
    [welcomeBubble setPointY:60.0];
    [welcomeBubble setPointHeight:20.0];
    [welcomeBubble setPointWidth:10.0];
    [welcomeBubble setNeedsDisplay];
    welcomeBubble.label.text = @"Start typing here to leave a note!";

    

}
- (void) loadMessageViewTut2 {
    welcomeBubble.frame = CGRectMake(SCREEN_WIDTH/2 - BUTTON_WIDTH/2, SCREEN_HEIGHT*2/3+10, BUTTON_WIDTH, BUTTON_HEIGHT*2);
    [welcomeBubble setPointY:0.0];
    [welcomeBubble setPointHeight:0.0];
    [welcomeBubble setPointWidth:0.0];
    [welcomeBubble setNeedsDisplay];
    
    welcomeBubble.label.text = @"You can also attach a song or a picture to your Breadcrumb";
    
    welcomeBubble.label.numberOfLines = 2;
    
}

- (void) loadMessageViewTut3 {
    welcomeBubble.frame = CGRectMake(SCREEN_WIDTH/2 - BUTTON_WIDTH/2, SCREEN_HEIGHT/5, BUTTON_WIDTH, BUTTON_HEIGHT*2.3);
    [welcomeBubble setPointY:60.0];
    [welcomeBubble setPointHeight:20.0];
    [welcomeBubble setPointWidth:10.0];
    [welcomeBubble setNeedsDisplay];
    
    welcomeBubble.label.text = @"And finally, you can change who you want to see your Breadcrumb!";
    
    welcomeBubble.label.numberOfLines = 3;
    
}

- (void) loadMessageViewTut4 {
    [nmv removeFromSuperview];
    [cover removeFromSuperview];
    welcomeBubble.frame = CGRectMake(SCREEN_WIDTH/2 - BUTTON_WIDTH/2, SCREEN_HEIGHT/2 - BUTTON_HEIGHT*2.3, BUTTON_WIDTH, BUTTON_HEIGHT*2.3);
    [welcomeBubble setPointY:0.0];
    [welcomeBubble setPointHeight:0.0];
    [welcomeBubble setPointWidth:0.0];
    
    welcomeBubble.label.text = @"Leave lots of Breadcrumbs for friends to find! When you're in an area with Breadcrumbs around, they'll appear on the map!";
    
    welcomeBubble.label.numberOfLines = 6;
    [welcomeBubble setNeedsDisplay];

}

- (void)loadBarBubble {
    welcomeBubble.frame = CGRectMake(SCREEN_WIDTH/4, SCREEN_HEIGHT/11, BUTTON_WIDTH, BUTTON_HEIGHT*2.3);
    [welcomeBubble setPointY:20.0];
    [welcomeBubble setPointHeight:20.0];
    [welcomeBubble setPointWidth:10.0];
    [welcomeBubble setNeedsDisplay];
    
    welcomeBubble.label.text = @"This bar controls what kinds of Breadcrumbs you want to see on the map.";
    welcomeBubble.label.numberOfLines = 5;
}


- (void)loadSelfBubble {
    welcomeBubble.frame = CGRectMake(SCREEN_WIDTH/4, SCREEN_HEIGHT/11, BUTTON_WIDTH, BUTTON_HEIGHT*2.3);
    [welcomeBubble setPointY:20.0];
    [welcomeBubble setPointHeight:20.0];
    [welcomeBubble setPointWidth:10.0];
    [welcomeBubble setNeedsDisplay];

        welcomeBubble.label.text = @"This option shows all the notes you left yourself.";
    welcomeBubble.label.numberOfLines = 5;
    }
- (void)loadFriendsBubble {
    welcomeBubble.frame = CGRectMake(SCREEN_WIDTH/4, SCREEN_HEIGHT/11, BUTTON_WIDTH, BUTTON_HEIGHT*2);
    [welcomeBubble setPointY:70.0];
    [welcomeBubble setPointHeight:20.0];
    [welcomeBubble setPointWidth:10.0];
    [welcomeBubble setNeedsDisplay];

    welcomeBubble.label.text = @"To see Breadcrumbs your friends left you, click here";
    welcomeBubble.label.numberOfLines = 2;
}

- (void)loadPublicBubble {
    welcomeBubble.frame = CGRectMake(SCREEN_WIDTH/4, SCREEN_HEIGHT/11, BUTTON_WIDTH, BUTTON_HEIGHT*2.3);
    [welcomeBubble setPointY:120.0];
    [welcomeBubble setPointHeight:20.0];
    [welcomeBubble setPointWidth:10.0];
    [welcomeBubble setNeedsDisplay];

        welcomeBubble.label.text = @"Or if you're a social butterfly, you can choose to see public notes, from everyone around you!";
    welcomeBubble.label.numberOfLines = 3;
}

- (void)loadListBubble {
    welcomeBubble.frame= CGRectMake(SCREEN_WIDTH/20, SCREEN_HEIGHT/11, BUTTON_WIDTH, BUTTON_HEIGHT*2);
    [welcomeBubble setPointY:20.0];
    [welcomeBubble setPointHeight:20.0];
    [welcomeBubble setPointWidth:10.0];
    [welcomeBubble setNeedsDisplay];

    welcomeBubble.label.text = @"If you're more of a list kind of person, you can see all your notes at once here";
    welcomeBubble.label.numberOfLines = 3;
}



- (void)loadThankYouBubble {
    welcomeBubble.frame = CGRectMake(SCREEN_WIDTH/2 - BUTTON_WIDTH/2, SCREEN_HEIGHT-300, BUTTON_WIDTH, BUTTON_HEIGHT*2.3);
    [welcomeBubble setPointY:0.0];
    [welcomeBubble setPointHeight:0.0];
    [welcomeBubble setPointWidth:0.0];
    [welcomeBubble setNeedsDisplay];

    welcomeBubble.label.text = @"Thanks for using Breadcrumbs! Tap to end the tutorial.";
    welcomeBubble.label.numberOfLines = 5;

}

- (void) didFinishTutorial {
    AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    delegate.firstLaunch = NO;
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

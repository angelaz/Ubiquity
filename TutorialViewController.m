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



@interface TutorialViewController ()
{
    CGFloat SCREEN_WIDTH;
    CGFloat SCREEN_HEIGHT;
    
    CGFloat BUTTON_WIDTH;
    CGFloat BUTTON_HEIGHT;
    
    int bubbleCount;
    
    ArrowView *welcomeBubble;
    ArrowView *selfBubble;
    ArrowView *friendsBubble;
    ArrowView *publicBubble;
    ArrowView *listBubble;
    ArrowView *searchBarBubble;
    ArrowView *newMessageBubble;
    ArrowView *thankYouBubble;
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

    self.delegate = self;
    
    SCREEN_WIDTH = self.view.frame.size.width;
    SCREEN_HEIGHT = self.view.frame.size.height;
    
    BUTTON_WIDTH = 180;
    BUTTON_HEIGHT = 38;
    
    self.view.opaque = NO;
    self.view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5f];
    
    [self firstBubble];

}

- (void) firstBubble {
    welcomeBubble = [[ArrowView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/4, SCREEN_HEIGHT-300, BUTTON_WIDTH, BUTTON_HEIGHT*2.3)];
    [welcomeBubble setPointY:0.0];
    [welcomeBubble setPointHeight:0.0];
    [welcomeBubble setPointWidth:0.0];
    [welcomeBubble setNeedsDisplay];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(welcomeBubble.bounds.origin.x, welcomeBubble.bounds.origin.y, welcomeBubble.bounds.size.width, welcomeBubble.bounds.size.height + (welcomeBubble.pointWidth/2))];
    
    
    label.text = @"Welcome to Ubiquity! Tap to get started.";
    label.numberOfLines = 3;
    label.textColor = [UIColor darkGrayColor];
    label.backgroundColor = [UIColor clearColor];
    label.opaque = NO;
    label.layer.cornerRadius = 8;
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize: 16.f];
    //[label sizeToFit];
    [welcomeBubble addSubview:label];
    
    [self.view addSubview:welcomeBubble];
    [self.view setNeedsDisplay];
}

-(void) nextBubble: (id) sender
{
    bubbleCount = bubbleCount + 1;
    if (bubbleCount == 1) {
        [welcomeBubble removeFromSuperview];
        [self.view setNeedsDisplay];
        [self loadSelfBubble];
    } else if (bubbleCount == 2) {
        [selfBubble removeFromSuperview];
        [self.view setNeedsDisplay];
        [self loadFriendsBubble];
    } else if (bubbleCount == 3) {
        [friendsBubble removeFromSuperview];
        [self.view setNeedsDisplay];
        [self loadPublicBubble];
    } else if (bubbleCount == 4) {
        [publicBubble removeFromSuperview];
        [self.view setNeedsDisplay];
        [self loadListBubble];
    } else if (bubbleCount == 5) {
        [listBubble removeFromSuperview];
        [self.view setNeedsDisplay];
        [self loadSearchBarBubble];
    } else if (bubbleCount == 6) {
        [searchBarBubble removeFromSuperview];
        [self.view setNeedsDisplay];
        [self loadNewMessageBubble];
    } else if (bubbleCount == 7) {
        [newMessageBubble removeFromSuperview];
        [self.view setNeedsDisplay];
        [self loadThankYouBubble];
    } else if (bubbleCount == 8) {
        [thankYouBubble removeFromSuperview];
        [self.view setNeedsDisplay];
        [self didFinishTutorial];
    }
    
}

- (void)loadSelfBubble {
    selfBubble = [[ArrowView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/4, SCREEN_HEIGHT-520, BUTTON_WIDTH, BUTTON_HEIGHT*2)];
    [selfBubble setPointY:20.0];
    [selfBubble setPointHeight:20.0];
    [selfBubble setPointWidth:10.0];
    [selfBubble setNeedsDisplay];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(selfBubble.bounds.origin.x, selfBubble.bounds.origin.y, selfBubble.bounds.size.width, selfBubble.bounds.size.height + (selfBubble.pointWidth/2))];
    
    
    label.text = @"Click here to see notes from yourself";
    label.numberOfLines = 2;
    label.textColor = [UIColor darkGrayColor];
    label.backgroundColor = [UIColor clearColor];
    label.opaque = NO;
    label.layer.cornerRadius = 8;
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize: 16.f];
    //[label sizeToFit];
    [selfBubble addSubview:label];
    
    [self.view addSubview:selfBubble];
    [self.view setNeedsDisplay];
}

- (void)loadFriendsBubble {
    friendsBubble = [[ArrowView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/4, SCREEN_HEIGHT-520, BUTTON_WIDTH, BUTTON_HEIGHT*2)];
    [friendsBubble setPointY:70.0];
    [friendsBubble setPointHeight:20.0];
    [friendsBubble setPointWidth:10.0];
    [friendsBubble setNeedsDisplay];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(friendsBubble.bounds.origin.x, friendsBubble.bounds.origin.y, friendsBubble.bounds.size.width, friendsBubble.bounds.size.height + (friendsBubble.pointWidth/2))];
    
    
    label.text = @"Click here to see notes from your friends";
    label.numberOfLines = 2;
    label.textColor = [UIColor darkGrayColor];
    label.backgroundColor = [UIColor clearColor];
    label.opaque = NO;
    label.layer.cornerRadius = 8;
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize: 16.f];
    //[label sizeToFit];
    [friendsBubble addSubview:label];
    
    [self.view addSubview:friendsBubble];
    [self.view setNeedsDisplay];
}

- (void)loadPublicBubble {
    publicBubble = [[ArrowView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/4, SCREEN_HEIGHT-520, BUTTON_WIDTH, BUTTON_HEIGHT*2.3)];
    [publicBubble setPointY:120.0];
    [publicBubble setPointHeight:20.0];
    [publicBubble setPointWidth:10.0];
    [publicBubble setNeedsDisplay];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(publicBubble.bounds.origin.x, publicBubble.bounds.origin.y, publicBubble.bounds.size.width, publicBubble.bounds.size.height + (publicBubble.pointWidth/2))];
    
    
    label.text = @"Click here to see public notes from everyone around you";
    label.numberOfLines = 3;
    label.textColor = [UIColor darkGrayColor];
    label.backgroundColor = [UIColor clearColor];
    label.opaque = NO;
    label.layer.cornerRadius = 8;
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize: 16.f];
    //[label sizeToFit];
    [publicBubble addSubview:label];
    
    [self.view addSubview:publicBubble];
    [self.view setNeedsDisplay];
}

- (void)loadListBubble {
    listBubble = [[ArrowView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/20, SCREEN_HEIGHT-520, BUTTON_WIDTH, BUTTON_HEIGHT*2)];
    [listBubble setPointY:20.0];
    [listBubble setPointHeight:20.0];
    [listBubble setPointWidth:10.0];
    [listBubble setNeedsDisplay];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(listBubble.bounds.origin.x, listBubble.bounds.origin.y, listBubble.bounds.size.width, listBubble.bounds.size.height + (listBubble.pointWidth/2))];
    
    
    label.text = @"Click here to see all your notes in a list";
    label.numberOfLines = 2;
    label.textColor = [UIColor darkGrayColor];
    label.backgroundColor = [UIColor clearColor];
    label.opaque = NO;
    label.layer.cornerRadius = 8;
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize: 16.f];
    //[label sizeToFit];
    [listBubble addSubview:label];
    
    [self.view addSubview:listBubble];
    [self.view setNeedsDisplay];
}

- (void)loadSearchBarBubble {
    searchBarBubble = [[ArrowView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/8, SCREEN_HEIGHT-485, BUTTON_WIDTH, BUTTON_HEIGHT*2.3)];
    [searchBarBubble setPointY:10.0];
    [searchBarBubble setPointHeight:20.0];
    [searchBarBubble setPointWidth:10.0];
    [searchBarBubble setNeedsDisplay];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(searchBarBubble.bounds.origin.x, searchBarBubble.bounds.origin.y, searchBarBubble.bounds.size.width, searchBarBubble.bounds.size.height + (searchBarBubble.pointWidth/2))];
    
    
    label.text = @"Search addresses here before posting a note at that location";
    label.numberOfLines = 3;
    label.textColor = [UIColor darkGrayColor];
    label.backgroundColor = [UIColor clearColor];
    label.opaque = NO;
    label.layer.cornerRadius = 8;
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize: 16.f];
    //[label sizeToFit];
    [searchBarBubble addSubview:label];
    
    [self.view addSubview:searchBarBubble];
    [self.view setNeedsDisplay];
}

- (void)loadNewMessageBubble {
    newMessageBubble = [[ArrowView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2.4, SCREEN_HEIGHT-520, BUTTON_WIDTH, BUTTON_HEIGHT*2.3)];
    [newMessageBubble setPointY:150.0];
    [newMessageBubble setPointHeight:20.0];
    [newMessageBubble setPointWidth:10.0];
    [newMessageBubble setNeedsDisplay];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(newMessageBubble.bounds.origin.x, newMessageBubble.bounds.origin.y, newMessageBubble.bounds.size.width, newMessageBubble.bounds.size.height + (newMessageBubble.pointWidth/2))];
    
    
    label.text = @"Click here to post a new note at the chosen location";
    label.numberOfLines = 3;
    label.textColor = [UIColor darkGrayColor];
    label.backgroundColor = [UIColor clearColor];
    label.opaque = NO;
    label.layer.cornerRadius = 8;
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize: 16.f];
    //[label sizeToFit];
    [newMessageBubble addSubview:label];
    
    [self.view addSubview:newMessageBubble];
    [self.view setNeedsDisplay];
}

- (void)loadThankYouBubble {
    thankYouBubble = [[ArrowView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/4, SCREEN_HEIGHT-300, BUTTON_WIDTH, BUTTON_HEIGHT*2.3)];
    [thankYouBubble setPointY:0.0];
    [thankYouBubble setPointHeight:0.0];
    [thankYouBubble setPointWidth:0.0];
    [thankYouBubble setNeedsDisplay];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(thankYouBubble.bounds.origin.x, thankYouBubble.bounds.origin.y, thankYouBubble.bounds.size.width, thankYouBubble.bounds.size.height + (thankYouBubble.pointWidth/2))];
    
    
    label.text = @"Thanks for using Ubiquity! Tap to end tutorial.";
    label.numberOfLines = 3;
    label.textColor = [UIColor darkGrayColor];
    label.backgroundColor = [UIColor clearColor];
    label.opaque = NO;
    label.layer.cornerRadius = 8;
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize: 16.f];
    //[label sizeToFit];
    [thankYouBubble addSubview:label];
    
    [self.view addSubview:thankYouBubble];
    [self.view setNeedsDisplay];
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

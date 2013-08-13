//
//  HomeMapViewController.m
//  Ubiquity
//
//  Created by Winnie Wu on 8/9/13.
//  Copyright (c) 2013 Team Ubi. All rights reserved.
//

#import "HomeMapViewController.h"
#import "HomeMapView.h"
#import "AppDelegate.h"
#import "NewMessageViewController.h"
#import "WallPostsViewController.h"
#import "OptionsViewController.h"

@interface HomeMapViewController ()
@property (nonatomic, strong) HomeMapView *hmv;
@end

@implementation HomeMapViewController


- (void)viewDidLoad
{
    _hmv = [[HomeMapView alloc] initWithFrame: [UIScreen mainScreen].bounds];
    [self setView: _hmv];
    
    [self initNewMessageButton];

    
}


- (void) openNewMessageView
{
    NewMessageViewController *nmvc = [[NewMessageViewController alloc] init];
    UINavigationController *newMessageNavController = [[UINavigationController alloc]
                                                       initWithRootViewController:nmvc];
    [self.navigationController presentViewController:newMessageNavController animated:YES completion:nil];
}

- (void) initNewMessageButton
{
    UIImage *image = [UIImage imageNamed:@"newMessage"];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setBackgroundImage: [image stretchableImageWithLeftCapWidth:7.0 topCapHeight:0.0] forState:UIControlStateNormal];
    
    button.frame = CGRectMake(0.0, 0.0, image.size.width, image.size.height);
    
    [button addTarget:self action:@selector(openNewMessageView)    forControlEvents:UIControlEventTouchUpInside];
    
    UIView *v= [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, image.size.width, image.size.height) ];
    
    [v addSubview:button];
    
    UIBarButtonItem *newMessage = [[UIBarButtonItem alloc] initWithCustomView:v];
    
    self.navigationItem.rightBarButtonItem = newMessage;
    
    
}

- (id)init{
    self = [super init];
    if (self) {
        [self initButtons];
        [self initSegmentedControl];
        [self initOptionsButton];
    }
    return self;
}



- (void)initSegmentedControl
{
    
    NSArray *itemArray = [NSArray arrayWithObjects: [UIImage imageNamed:@"public"], [UIImage imageNamed:@"friends"], [UIImage imageNamed:@"me"], nil];
    self.segmentedControl = [[UISegmentedControl alloc] initWithItems:itemArray];
    self.segmentedControl.frame = CGRectMake(0,0,150,30);
        self.segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
    [self.segmentedControl setSelectedSegmentIndex:0];
    [self.segmentedControl addTarget:self
                              action:@selector(changeSegment:)
                    forControlEvents:UIControlEventValueChanged];
    [[self navigationItem] setTitleView:self.segmentedControl];
}
- (void)changeSegment:(UISegmentedControl *)sender
{
    NSInteger value = [sender selectedSegmentIndex];
    if (value == 0) {
        NSLog(@"Changed value to 0");
    } else if (value == 1) {
        NSLog(@"Changed value to 1");
    } else if (value == 2) {
        NSLog(@"Changed value to 2");
    }
}

- (void)initButtons
{
    UIBarButtonItem *mapList = [[UIBarButtonItem alloc] initWithTitle:@"List"
                                                                style:UIBarButtonItemStylePlain
                                                               target:self
                                                               action:@selector(launchPostsView)];
    UIBarButtonItem *newMessage = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose
                                                                                target:self
                                                                                action:@selector(launchNewMessage)];
    [[self navigationItem] setLeftBarButtonItem:mapList];
    [[self navigationItem] setRightBarButtonItem:newMessage];
}
- (void)launchPostsView
{
    WallPostsViewController *wpvc = [[WallPostsViewController alloc] init];
    UINavigationController *wallPostsNavController = [[UINavigationController alloc]
                                                      initWithRootViewController:wpvc];
    [self.navigationController presentViewController:wallPostsNavController animated:NO completion:nil];
}
- (void)launchNewMessage
{
    NewMessageViewController *nmvc = [[NewMessageViewController alloc] init];
    UINavigationController *newMessageNavController = [[UINavigationController alloc]
                                                       initWithRootViewController:nmvc];
    [self.navigationController presentViewController:newMessageNavController animated:YES completion:nil];
}


- (void)initOptionsButton
{
    int const SCREEN_WIDTH = self.view.frame.size.width;
    int const SCREEN_HEIGHT = self.view.frame.size.height;
    self.optionsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *pictureButtonImage = [UIImage imageNamed:@"gear"];
    [self.optionsButton setBackgroundImage:pictureButtonImage forState:UIControlStateNormal];
    self.optionsButton.frame = CGRectMake(SCREEN_WIDTH - 25, SCREEN_HEIGHT - 70, 20.0, 20.0);
    [self.optionsButton addTarget:self action:@selector(launchOptionsMenu) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.optionsButton];
}
- (void)launchOptionsMenu
{
    OptionsViewController *ovc = [[OptionsViewController alloc] init];
    UINavigationController *optionsNavController = [[UINavigationController alloc] initWithRootViewController:ovc];
    [self.navigationController presentViewController:optionsNavController animated:YES completion:nil];
}
@end

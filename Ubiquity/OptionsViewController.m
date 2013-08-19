//
//  OptionsViewController.m
//  Ubiquity
//
//  Created by Catherine Morrison on 7/24/13.
//  Copyright (c) 2013 Team Ubi. All rights reserved.
//

#import "OptionsViewController.h"
#import <Parse/Parse.h>
#import "AppDelegate.h"
@interface OptionsViewController ()
@property (nonatomic, strong) UIButton *optionsButton;

@end

@implementation OptionsViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (id)init
{
    self = [super init];
    if (self) {
        [self initOptionsButton];
    }
    
    return self;
}

- (void) loadView
{
    UINavigationItem *nav = [self navigationItem];
    [nav setTitle:@"Options"];
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                target:self
                                                                                action:@selector(closeOptions:)];
    CGRect appFrame = [UIScreen mainScreen].applicationFrame;
    int w = appFrame.size.width;
    int h = appFrame.size.height;
    
    UIView *view = [[UIView alloc] initWithFrame: appFrame];
    [view setBackgroundColor:[UIColor clearColor]];
    self.view = view;
    
    [self setUpBackgroundWithWidth:w andHeight: h];
    [self setUpButtonsWithWidth: w andHeight: h];
    
    
    [[self navigationItem] setLeftBarButtonItem:backButton];

}

- (void)initOptionsButton
{
    int const SCREEN_WIDTH = self.view.frame.size.width;
    int const SCREEN_HEIGHT = self.view.frame.size.height;
    self.optionsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *pictureButtonImage = [UIImage imageNamed:@"gear"];
    [self.optionsButton setBackgroundImage:pictureButtonImage forState:UIControlStateNormal];
    self.optionsButton.frame = CGRectMake(SCREEN_WIDTH - 25, SCREEN_HEIGHT - 70, 20.0, 20.0);
    [self.optionsButton addTarget:self action:@selector(closeOptions:) forControlEvents:UIControlEventTouchUpInside];
}


- (void) setUpBackgroundWithWidth: (int) w andHeight: (int) h
{
    int imageWidth = w * 4/5;
    int imageHeight = h * 3/5;
    UIImageView *frame = [[UIImageView alloc] initWithFrame:CGRectMake(w/2 - imageWidth / 2, h/2 - imageHeight/2 - 22, imageWidth, imageHeight)];
    frame.image = [UIImage imageNamed:@"OptionsFrame"];
    [self.view addSubview:frame];

}

- (void) setUpButtonsWithWidth: (int) w andHeight: (int) h
{
    UIColor *color = mainThemeColor;
    
    CGFloat buttonHeight = 40.0;
    CGFloat buttonWidth = 160.0;
    
    UIButton *twitterButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [twitterButton addTarget:self
                      action:@selector(loginToTwitter)
            forControlEvents:UIControlEventTouchDown];
    
    [twitterButton setTitle:@"Twitter" forState:UIControlStateNormal];
    twitterButton.titleLabel.textColor = [UIColor whiteColor];
    twitterButton.frame = CGRectMake(w/2-buttonWidth/2, h/2-buttonHeight-32, buttonWidth, buttonHeight);
    twitterButton.layer.cornerRadius = 5.0f;
    [self.view addSubview:twitterButton];
    twitterButton.backgroundColor = color;
    
    UIButton *logoutButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [logoutButton addTarget:self
                     action:@selector(logoutButtonTouchHandler:)
           forControlEvents:UIControlEventTouchDown];
    [logoutButton setTitle:@"Logout" forState:UIControlStateNormal];
    logoutButton.titleLabel.textColor = [UIColor whiteColor];
    logoutButton.frame = CGRectMake(w/2-buttonWidth/2, h/2-12, buttonWidth, buttonHeight);
    logoutButton.layer.cornerRadius = 5.0f;
    [self.view addSubview: logoutButton];
    logoutButton.backgroundColor = color;

}
- (void)logoutButtonTouchHandler:(id)sender {
    
    [PFUser logOut];
    if ([PFUser currentUser] == nil)
    {
        NSLog(@"Successfully Logged out");
        //[self.navigationController pushViewController:[[RecentViewController alloc] init] animated:YES];
        LoginViewController *loginViewController = [[LoginViewController alloc] init];
        UINavigationController *loginNavController = [[UINavigationController alloc] initWithRootViewController:loginViewController];
        [self presentViewController:loginNavController animated:YES completion:nil];
        
    }
}


- (void)dismissOptions
{
    [self dismissViewControllerAnimated:NO completion:nil];
}

-(void) closeOptions: (id) sender
{
    [self.optionsButton removeFromSuperview];
    
    self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height);
    [UIView animateWithDuration:0.25
                     animations:^{
                         self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height);
                     }];
    
    
    [self performSelector:@selector(dismissOptions) withObject:self afterDelay:0.25];
    
}

- (void) changeBackground
{
    [UIView animateWithDuration:0.1
                     animations:^{
                         
                         [self.view setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:0.5]];
                         [self.view addSubview:self.optionsButton];

                     }];
}



- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self performSelector:@selector(changeBackground) withObject:self afterDelay:0.25];


}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) loginToTwitter {
//    [PFTwitterUtils logInWithBlock:^(PFUser *user, NSError *error) {
//        if (!user) {
//            NSLog(@"Uh oh. The user cancelled the Twitter login.");
//            return;
//        } else if (user.isNew) {
//            NSLog(@"User signed up and logged in with Twitter!");
//        } else {
//            NSLog(@"User logged in with Twitter!");
//        }    
//    }];
    
    if (![PFTwitterUtils isLinkedWithUser:[PFUser currentUser]]) {
        [PFTwitterUtils linkUser:[PFUser currentUser] block:^(BOOL succeeded, NSError *error) {
            if ([PFTwitterUtils isLinkedWithUser:[PFUser currentUser]]) {
                NSLog(@"Woohoo, user logged in with Twitter!");
            }
        }];
    }
}

@end

//
//  HomeMapViewController.m
//  Ubiquity
//
//  Created by Winnie Wu on 8/9/13.
//  Copyright (c) 2013 Team Ubi. All rights reserved.
//

#import "HomeMapViewController.h"
#import "HomeMapView.h"
#import "NewMessageViewController.h"

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

@end

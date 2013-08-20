//
//  LoginView.m
//  Ubiquity
//
//  Created by Winnie Wu on 8/7/13.
//  Copyright (c) 2013 Team Ubi. All rights reserved.
//

#import "LoginView.h"
#import "AppDelegate.h"

@implementation LoginView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        CGFloat const SCREEN_WIDTH = frame.size.width;
        CGFloat const SCREEN_HEIGHT = frame.size.height;
        CGFloat const BUTTON_WIDTH = 120;
        CGFloat const BUTTON_HEIGHT = 35;
        
        CGFloat offset = 25.0;

        [self setBackgroundColor: [UIColor colorWithPatternImage: [UIImage imageNamed:@"LoginBg"]]];
        self.loginButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2 - BUTTON_WIDTH/2, SCREEN_HEIGHT*5/7 - offset*2, BUTTON_WIDTH, BUTTON_HEIGHT)];
        [self.loginButton setImage: [UIImage imageNamed:@"login-button-small"] forState:UIControlStateNormal];
        [self.loginButton setTitle: @"Login" forState:UIControlStateNormal];
        [self addSubview: self.loginButton];
        
        UIImageView *image = [[UIImageView alloc] initWithImage: [UIImage imageNamed:@"ubi"]];
        
        
        CGFloat imageWidth = 300;
        CGFloat imageHeight = 250;
        [image setFrame: CGRectMake (SCREEN_WIDTH/2 - imageWidth / 2, SCREEN_HEIGHT/2 - imageHeight * 4/5, imageWidth, imageHeight)];
        [self addSubview:image ];

    }
    
    return self;
}

@end

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

        [self setBackgroundColor: [UIColor colorWithPatternImage: [UIImage imageNamed:@"LoginBg"]]];
        self.loginButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2 - BUTTON_WIDTH/2, SCREEN_HEIGHT*4/7, BUTTON_WIDTH, BUTTON_HEIGHT)];
        [self.loginButton setImage: [UIImage imageNamed:@"login-button-small"] forState:UIControlStateNormal];
        [self.loginButton setTitle: @"Login" forState:UIControlStateNormal];
        [self addSubview: self.loginButton];
        
        
        UILabel *loginText = [[UILabel alloc] init];
        loginText.text = @"Login with Facebook";
        loginText.lineBreakMode = NSLineBreakByWordWrapping;
        loginText.numberOfLines = 0;
        loginText.font = [UIFont systemFontOfSize: 10.f];
        loginText.textColor = [UIColor whiteColor];
        loginText.backgroundColor = [UIColor clearColor];
        CGSize textSize = [[loginText text] sizeWithFont:[UIFont systemFontOfSize:10.f] constrainedToSize:CGSizeMake(SCREEN_WIDTH, FLT_MAX) lineBreakMode:NSLineBreakByWordWrapping];

        [loginText setFrame:CGRectMake(SCREEN_WIDTH/2 - textSize.width/2, SCREEN_HEIGHT*4/7 - textSize.height*1.5, textSize.width, textSize.height)];

        [self addSubview:loginText];
        UIImageView *image = [[UIImageView alloc] initWithImage: [UIImage imageNamed:@"ubi"]];
        
        [image setFrame: CGRectMake (SCREEN_WIDTH/2 - BUTTON_WIDTH * 0.75, SCREEN_HEIGHT / 4, BUTTON_WIDTH * 1.5, BUTTON_HEIGHT * 4)];
        [self addSubview:image ];

    }
    
    return self;
}

@end

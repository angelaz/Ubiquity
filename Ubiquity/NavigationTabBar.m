//
//  NavigationTabBar.m
//  Ubiquity
//
//  Created by Winnie Wu on 7/30/13.
//  Copyright (c) 2013 Team Ubi. All rights reserved.
//

#import "NavigationTabBar.h"
#import "RecentViewController.h"
#import "NewMessageViewController.h"
#import "FriendsViewController.h"
#import "OptionsViewController.h"

@implementation NavigationTabBar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        
        
        RecentViewController *rvc = [[RecentViewController alloc] init];
        UINavigationController *recentNavController = [[UINavigationController alloc]
                                                       initWithRootViewController:rvc];
        [UIView  beginAnimations: @"Showinfo"context: nil];
        
        NewMessageViewController *nmvc = [[NewMessageViewController alloc] init];
      //  [nmvc setModalPresentationStyle: UIModalPresentationFullScreen];
      //  UINavigationController *newMessageNavController = [[UINavigationController alloc]                                                         initWithRootViewController:nmvc];
        
        
        FriendsViewController *fvc = [[FriendsViewController alloc] init];
        UINavigationController *friendsNavController = [[UINavigationController alloc]
                                                        initWithRootViewController:fvc];
        
        OptionsViewController *ovc = [[OptionsViewController alloc] init];
        UINavigationController *optionsNavController = [[UINavigationController alloc]
                                                        initWithRootViewController:ovc];
        
        
        UITabBar *tabBar = [[UITabBar alloc] init];
        [tabBar addSubview: [recentNavController tabBarItem]];
        [self.window.viewForBaselineLayout addSubview: tabBar];
        
        
        
        
        
        
        UITabBarController *tabBarController = [[UITabBarController alloc] init];
        [tabBarController setViewControllers:@[recentNavController, nmvc,
                                               friendsNavController, optionsNavController]];
        UITabBarItem *recentTab = [recentNavController tabBarItem];
        [recentTab setTitle:@"Recent Items"];
        UITabBarItem *newMessageTab = [nmvc
                                       tabBarItem];
        [newMessageTab setTitle:@"New Message"];
        [newMessageTab setImage:[UIImage imageNamed:@"newMessage.png"]];
        UITabBarItem *friendsTab = [friendsNavController tabBarItem];
        [friendsTab setTitle:@"Friends"];
        UITabBarItem *optionsTab = [optionsNavController tabBarItem];
        [optionsTab setTitle:@"Options"];
        [optionsTab setImage:[UIImage imageNamed:@"options.png"]];

    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end

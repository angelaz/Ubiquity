//
//  HomeMapViewController.m
//  Ubiquity
//
//  Created by Winnie Wu on 8/9/13.
//  Copyright (c) 2013 Team Ubi. All rights reserved.
//

#import "HomeMapViewController.h"
#import "HomeMapView.h"

@interface HomeMapViewController ()
@property (nonatomic, strong) HomeMapView *hmv;
@end

@implementation HomeMapViewController


- (void)viewDidLoad
{
    _hmv = [[HomeMapView alloc] init];
    [self setView: _hmv];
}

@end

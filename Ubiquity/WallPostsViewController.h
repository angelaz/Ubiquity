//
//  WallPostsViewController.h
//  Ubiquity
//
//  Created by Catherine Morrison on 7/25/13.
//  Copyright (c) 2013 Team Ubi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface WallPostsViewController : PFQueryTableViewController

@property (nonatomic) int indexing;
@property (nonatomic, strong) UISegmentedControl *segmentedControl;

@property (nonatomic, copy) NSString *className;

@end

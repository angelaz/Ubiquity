//
//  WallPostsViewController.h
//  Ubiquity
//
//  Created by Catherine Morrison on 7/25/13.
//  Copyright (c) 2013 Team Ubi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "Rdio/Rdio.h"

@interface WallPostsViewController : PFQueryTableViewController <RdioDelegate, RDPlayerDelegate>

@property (nonatomic) int indexing;
@property (nonatomic, strong) UISegmentedControl *segmentedControl;
@property (nonatomic, strong) UIButton *optionsButton;
@property (nonatomic, strong) UIButton *rdioButton;
@property (nonatomic, copy) NSString *className;

@end

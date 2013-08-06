//
//  CustomFBFriendPickerViewController.h
//  Ubiquity
//
//  Created by Winnie Wu on 7/31/13.
//  Copyright (c) 2013 Team Ubi. All rights reserved.
//

#import <FacebookSDK/FacebookSDK.h>

@interface CustomFBFriendPickerViewController : FBFriendPickerViewController

@property (nonatomic, strong) NSMutableArray *selection;
@property (retain, nonatomic) UISearchBar *searchBar;
@property (retain, nonatomic) NSString *searchText;

- (void)addSearchBarToFriendPickerView;
@end

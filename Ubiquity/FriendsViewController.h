//
//  FriendsViewController.h
//  Ubiquity
//
//  Created by Angela Zhang on 7/24/13.
//  Copyright (c) 2013 Team Ubi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>
#import <Parse/Parse.h>

@interface FriendsViewController :  UITableViewController <NSURLConnectionDelegate>
{
    //Model objects
    FBFriendPickerViewController *friendPickerController;
    NSArray* selectedFriends;
    PFObject *ubiquityFriends;
    
    //View objects
    __weak IBOutlet UITableView *menuTableView;
}
@property (strong, nonatomic) FBProfilePictureView *profilePictureView;
@property (nonatomic, strong) NSArray *allFriends;
- (UIImage*) getSubImageFrom: (UIImage*) img WithRect: (CGRect) rect;
@end

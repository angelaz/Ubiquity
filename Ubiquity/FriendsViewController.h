//
//  FriendsViewController.h
//  Ubiquity
//
//  Created by Angela Zhang on 7/24/13.
//  Copyright (c) 2013 Team Ubi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomFBFriendPickerViewController.h"
#import <FacebookSDK/FacebookSDK.h>
#import <Parse/Parse.h>

@interface FriendsViewController :  UITableViewController <NSURLConnectionDelegate>
{
    //Model objects
<<<<<<< Updated upstream
    CustomFBFriendPickerViewController *friendPickerController;
    NSMutableArray* selectedFriends;
=======
    FBFriendPickerViewController *friendPickerController;
>>>>>>> Stashed changes
    PFObject *ubiquityFriends;
    
    //View objects
    __weak IBOutlet UITableView *menuTableView;
    
    BOOL userLoggedIn; //needed because fvc is init-ed before user actually logs in (for navigation)

}

@property (nonatomic, strong) NSArray* selectedFriends;

- (UIImage*) getSubImageFrom: (UIImage*) img WithRect: (CGRect) rect;
@end

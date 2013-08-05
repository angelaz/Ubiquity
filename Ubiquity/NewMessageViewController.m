//
// NewMessageViewController.m
// Ubiquity
//
// Created by Winnie Wu on 7/24/13.
// Copyright (c) 2013 Team Ubi. All rights reserved.
//

#import "NewMessageViewController.h"
#import "AppDelegate.h"
#import <Parse/Parse.h>
#import "NewMessageView.h"
#import "RecentViewController.h"
#import "LocationController.h"
#import "Geocoding.h"

#define kOFFSET_FOR_KEYBOARD 190.0

@interface NewMessageViewController ()

@property (retain, nonatomic) FBFriendPickerViewController *friendPickerController;

//@property (nonatomic, strong) UITextField *toRecipientTextField;
//@property (nonatomic, strong) UILabel *toLabel;
//@property (nonatomic, strong) UITextField *messageTextField;
//@property (nonatomic, strong) UIButton *sendButton;
//@property (nonatomic, strong) UIPickerView *repeatTimesPicker;
//@property (nonatomic, strong) UIToolbar *pickerToolbar;
//@property (nonatomic, strong) UIButton *showRepeatPickerButton;
@property (nonatomic, strong) UITextField *toRecipientTextField;
@property (nonatomic, strong) UILabel *toLabel;
@property (nonatomic, strong) UITextField *messageTextField;
@property (nonatomic, strong) UIButton *sendButton;
@property (nonatomic, strong) UIPickerView *repeatTimesPicker;
@property (nonatomic, strong) UIToolbar *pickerToolbar;
@property (nonatomic, strong) UIButton *showRepeatPickerButton;
@property (nonatomic, strong) NSArray *repeatOptions;
//@property (nonatomic, strong) UITextField *locationSearchTextField;
//@property (nonatomic, strong) UIButton *locationSearchButton;
//@property (nonatomic, strong) UIGestureRecognizer *tapRecognizer;

@property (nonatomic, strong) NSArray *friendsOnApp;

@end

@implementation NewMessageViewController {
    NewMessageView *nmv;
    GMSMapView *mapView;
    NSMutableArray *recipientsList;
}

@synthesize gs;

- (void) viewWillAppear:(BOOL)animated
{
    [self hideTabBar];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    [super viewWillAppear:animated];

}


-(void) viewWillDisappear:(BOOL)animated
{
    [self showTabBar];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
    
    [super viewWillDisappear:animated];

}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(locationDidChange:)
                                                     name:kPAWLocationChangeNotification
                                                   object:nil];
        recipientsList = [[NSMutableArray alloc] init];
        
             }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    // Do any additional setup after loading the view.
    self.repeatOptions = [[NSArray alloc] initWithObjects:kNMNever, kNMDaily, kNMWeekly, kNMMonthy, nil];
    
    nmv = [[NewMessageView alloc] initWithFrame: [UIScreen mainScreen].bounds];
    [self setView: nmv];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(locationDidChange:)
                                                 name:kPAWLocationChangeNotification
                                               object:nil];
    
    nmv.toRecipientTextField.delegate = self;
    
    nmv.messageTextView.delegate = self;
    nmv.locationSearchTextField.delegate = self;
    
    [nmv.locationSearchButton addTarget:self action:@selector(startSearch:) forControlEvents:UIControlEventTouchUpInside];
    [nmv.closeButton addTarget:self action:@selector(closeNewMessage:) forControlEvents:UIControlEventTouchUpInside];
    
    [nmv.sendButton addTarget:self action:@selector(sendMessage:) forControlEvents:UIControlEventTouchUpInside];

    nmv.repeatTimesPicker.delegate = self;
    nmv.repeatTimesPicker.dataSource = self;
    
    
    
    [nmv.showRepeatPickerButton addTarget:self action:@selector(showPicker:) forControlEvents:UIControlEventTouchUpInside];
    [self setPickedValueForPickerButton];
    
    [nmv.toRecipientButton addTarget:self action:@selector(selectFriendsButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    LocationController* locationController = [LocationController sharedLocationController];
    [self updateLocation:locationController.location.coordinate];
    
    nmv.tapRecognizer = [[UITapGestureRecognizer alloc]  initWithTarget:self action:@selector(hideKeyboard:)];
    [nmv addGestureRecognizer:nmv.tapRecognizer];

    
    nmv.pickerToolbar = [[UIToolbar alloc] init];
    nmv.pickerToolbar.barStyle = UIBarStyleDefault;
    nmv.pickerToolbar.translucent = NO;
    [nmv.pickerToolbar sizeToFit];
    UIBarButtonItem* doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                   style:UIBarButtonItemStyleBordered target:self
                                                                  action:@selector(pickerDoneClicked:)];
    [nmv.pickerToolbar setItems:[NSArray arrayWithObjects:doneButton, nil]];
    
    nmv.map.delegate = self;
    
    self.friendPickerController = nil;
    nmv.searchBar = nil;
    
}

- (void)addSearchBarToFriendPickerView
{
    if (nmv.searchBar == nil) {
        CGFloat searchBarHeight = 44.0;
        nmv.searchBar =
        [[UISearchBar alloc]
         initWithFrame:
         CGRectMake(0,0,
                    self.view.bounds.size.width,
                    searchBarHeight)];
        nmv.searchBar.autoresizingMask = nmv.searchBar.autoresizingMask |
        UIViewAutoresizingFlexibleWidth;
        nmv.searchBar.delegate = self;
        nmv.searchBar.showsCancelButton = YES;
        
        [self.friendPickerController.canvasView addSubview:nmv.searchBar];
        CGRect newFrame = self.friendPickerController.view.bounds;
        newFrame.size.height -= searchBarHeight;
        newFrame.origin.y = searchBarHeight;
        self.friendPickerController.tableView.frame = newFrame;
    }
}






-(void) mapView:(GMSMapView *)mv didLongPressAtCoordinate:(CLLocationCoordinate2D)coord
{
    NSLog(@"New pin please!");
    [self updateLocation:coord];
//    GMSMarker *marker3 = [[GMSMarker alloc] init];
//    marker3.position = coord;
//    marker3.title = @"New coordinate!";
//    marker3.snippet = @"US";
//    marker3.animated = YES;
//    marker3.map = nmv.map;
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    [nmv.map setUserInteractionEnabled:NO];
}


-(void) hideKeyboard: (id) sender
{
    NSLog(@"I sense a touch!");
    
    [nmv.messageTextView resignFirstResponder];
    [nmv.locationSearchTextField resignFirstResponder];
    [nmv.toRecipientTextField resignFirstResponder];
    [nmv.map setUserInteractionEnabled:YES];

    
}



-(void)keyboardWillHide {
    if (self.view.frame.origin.y > 0)
    {
        [self setViewMovedUp:YES];
    }
    else if (self.view.frame.origin.y < 0)
    {
        [self setViewMovedUp:NO];
    }
}

-(void)textFieldDidBeginEditing:(UITextField *)sender
{
    if ([sender isEqual:nmv.locationSearchTextField])
    {
        //move the main view, so that the keyboard does not hide it.
        if  (self.view.frame.origin.y >= 0)
        {
            [self setViewMovedUp:YES];
        }
    }
    [nmv.map setUserInteractionEnabled:NO];

    
}

//method to move the view up/down whenever the keyboard is shown/dismissed
-(void)setViewMovedUp:(BOOL)movedUp
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3]; // if you want to slide up the view
    
    CGRect rect = self.view.frame;
    if (movedUp)
    {
        // 1. move the view's origin up so that the text field that will be hidden come above the keyboard
        // 2. increase the size of the view so that the area behind the keyboard is covered up.
        rect.origin.y -= kOFFSET_FOR_KEYBOARD;
        rect.size.height += kOFFSET_FOR_KEYBOARD;
    }
    else
    {
        // revert back to the normal state.
        rect.origin.y += kOFFSET_FOR_KEYBOARD;
        rect.size.height -= kOFFSET_FOR_KEYBOARD;
    }
    self.view.frame = rect;
    
    [UIView commitAnimations];
}

-(void) closeNewMessage: (id) sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.tabBarController setSelectedIndex: 0];

}

- (void)addMarker{
    
    double lat = [[gs.geocode objectForKey:@"lat"] doubleValue];
    double lng = [[gs.geocode objectForKey:@"lng"] doubleValue];
    
    GMSMarker *marker = [[GMSMarker alloc] init];
    CLLocationCoordinate2D geolocation = CLLocationCoordinate2DMake(lat,lng);
    marker.position = geolocation;
    marker.title = [gs.geocode objectForKey:@"address"];
    NSLog(@"%@", marker.title);
    NSLog(@"%f, %f", lat, lng);
    
    marker.map = nmv.map;
    
    GMSCameraUpdate *geoLocateCam = [GMSCameraUpdate setTarget:geolocation];
    [nmv.map animateWithCameraUpdate:geoLocateCam];
    
}

- (void) startSearch: (id) sender
{
    NSLog(@"searching for: %@", nmv.locationSearchTextField.text);
    LocationController* locationController = [LocationController sharedLocationController];
    CLLocationCoordinate2D currentCoordinate = locationController.location.coordinate;
    NSDictionary *curLocation = [[NSDictionary alloc]initWithObjectsAndKeys:[NSNumber numberWithDouble:currentCoordinate.latitude],@"lat",[NSNumber numberWithDouble:currentCoordinate.longitude],@"lng",@"",@"address",nil];
    //Not a perfect solution for keeping the map at the same place
    gs = [[Geocoding alloc] initWithCurLocation:curLocation];
   [gs geocodeAddress:nmv.locationSearchTextField.text withCallback:@selector(addMarker) withDelegate:self];
}


- (void) setPickedValueForPickerButton
{
    NSString *selectedTitle = [self pickerView:nmv.repeatTimesPicker titleForRow:[nmv.repeatTimesPicker selectedRowInComponent:0] forComponent:0];
    [nmv.showRepeatPickerButton setTitle: selectedTitle forState:UIControlStateNormal];
}

- (void) pickerDoneClicked : (id) sender
{
    [nmv.pickerToolbar removeFromSuperview];
    [nmv.repeatTimesPicker removeFromSuperview];
    [nmv addSubview:nmv.sendButton];
    [self setPickedValueForPickerButton];
    [nmv addSubview:nmv.showRepeatPickerButton];
    [nmv.tapRecognizer setEnabled:YES];

    
    
}

- (void) showPicker: (id) sender
{
    NSLog(@"show picker!");
    [sender removeFromSuperview];
    [nmv.sendButton removeFromSuperview];
    [nmv addSubview:nmv.pickerToolbar];
    [nmv addSubview: nmv.repeatTimesPicker];
    [nmv.tapRecognizer setEnabled:NO];

}

- (void) sendMessage: (id) sender
{
    // Dismiss keyboard and capture any auto-correct
    [nmv.messageTextView resignFirstResponder];
    
    // Get user's current location
    LocationController* locationController = [LocationController sharedLocationController];
    CLLocationCoordinate2D currentCoordinate = locationController.location.coordinate;
    
    // Get the post's message
    NSString *postMessage = nmv.messageTextView.text;
    
    //Get the currently logged in PFUser
    PFUser *user = [PFUser currentUser];
    
    // Create a PFGeoPoint using the user's location
    PFGeoPoint *currentPoint = [PFGeoPoint geoPointWithLatitude:currentCoordinate.latitude
                                                      longitude:currentCoordinate.longitude];
    
    // Create a PFObject using the Post class and set the values we extracted above
    PFObject *postObject = [PFObject objectWithClassName:kPAWParsePostsClassKey];
    [postObject setObject:postMessage forKey:kPAWParseTextKey];
    [postObject setObject:user forKey:@"sender"];
    [postObject setObject:currentPoint forKey:kPAWParseLocationKey];
    [postObject setObject: [NSString stringWithFormat: @"%@", nmv.showRepeatPickerButton.titleLabel] forKey:kNMFrequencyKey];
    
    //For each person we are sending to
    for (id<FBGraphUser> user in recipientsList) {
        NSLog(@"Adding somebody");
        
        //Add the relation that they are a receiver of the message
        PFRelation *relation = [postObject relationforKey:@"receivers"];
        
        //Query for thulkcefvgelhucljkllnfibnrlrgduuekem, if they already exist or not
        PFQuery *findUsers = [PFQuery queryWithClassName:@"_User"];
        [findUsers whereKey:@"fbId" equalTo:[user id]];
        [findUsers findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if(!error) {
                //This is an existing user (temp, or actual user)
                if([objects count] > 0) {
                    //Should only be one
                    for(PFObject *obj in objects) {
                        [relation addObject:obj];
                        [postObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
                         {
                             if(!error) {
                                 NSLog(@"Yay");
                             } else {
                                 NSLog(@"Boo hiss");
                             }
                         }];
                        NSLog(@"Sent to existing user");
                    }
                    
                } else {
                    //They are not in our db (yet)
                    //TODO Make this a function, instead of fully typed out. Ick.
     
                    [PFAnonymousUtils logInWithBlock:^(PFUser *newGuy, NSError *e) {
                        if(!e) {
                            [newGuy setObject:user.id forKey:@"fbId"];
                            [newGuy setObject:user    forKey:@"profile"];
                            [relation addObject:newGuy];
                            [newGuy saveInBackgroundWithBlock:nil];
                            [postObject saveInBackgroundWithBlock:nil];
                            NSLog(@"Added the new guy");
                        } else {
                            NSLog(@"%@", e);
                        }
                    }];
                    
//                    [newGuy signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *e) {
//                        if(!e) {
//                            [relation addObject:newGuy];
//                            [newGuy saveInBackgroundWithBlock:nil];
//                            NSLog(@"Added the new guy");
//                        } else {
//                            NSLog(@"%@", e);
//                        }
//                    }];
                }
                
            } else {
                //Something went wrong (weird) :-(
                NSLog(@"%@", error);
            }
        }];
    }
    
    
    // Set the access control list on the postObject to restrict future modifications
    // to this object
    PFACL *readOnlyACL = [PFACL ACL];
    [readOnlyACL setPublicReadAccess:YES]; // Create read-only permissions
    [readOnlyACL setPublicWriteAccess:YES];
    
    [postObject setACL:readOnlyACL]; // Set the permissions on the postObject
    
    [postObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
     {
         if (error) // Failed to save, show an alert view with the error message
         {
             UIAlertView *alertView =
             [[UIAlertView alloc] initWithTitle:[[error userInfo] objectForKey:@"error"]
                                        message:nil
                                       delegate:self
                              cancelButtonTitle:nil
                              otherButtonTitles:@"Ok", nil];
             [alertView show];
             return;
         }
         if (succeeded) // Successfully saved, post a notification to tell other view controllers
         {
             dispatch_async(dispatch_get_main_queue(), ^{
                 [[NSNotificationCenter defaultCenter] postNotificationName:kPAWPostCreatedNotification
                                                                     object:nil];
             });
         }
     }];
    
    
    NSLog(@"Message sent!");
    
    [self closeNewMessage:self];
}

- (BOOL)textFieldShouldReturn: (UITextField *)textField {
    
    [textField resignFirstResponder];
    return NO;
}

/* Start Picker Methods */
- (void)pickerView:(UIPickerView *)pickerView didSelectRow: (NSInteger)row inComponent:(NSInteger)component {
    // Handle the selection
}

// tell the picker how many rows are available for a given component
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    
    
    return [self.repeatOptions count];
}

// tell the picker how many components it will have
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

// tell the picker the title for a given component
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    
    return [self.repeatOptions objectAtIndex: row];
}

// tell the picker the width of each row for a given component
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    int sectionWidth = 300;
    
    return sectionWidth;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)hideTabBar {
    UITabBar *tabBar = self.tabBarController.tabBar;
    UIView *parent = tabBar.superview; // UILayoutContainerView
    UIView *content = [parent.subviews objectAtIndex:0];  // UITransitionView
    UIView *window = parent.superview;
    
    [UIView animateWithDuration:0.5
                     animations:^{
                         CGRect tabFrame = tabBar.frame;
                         tabFrame.origin.y = CGRectGetMaxY(window.bounds);
                         tabBar.frame = tabFrame;
                         content.frame = window.bounds;
                     }];
    
}


- (void)showTabBar {
    UITabBar *tabBar = self.tabBarController.tabBar;
    UIView *parent = tabBar.superview; // UILayoutContainerView
    UIView *content = [parent.subviews objectAtIndex:0];  // UITransitionView
    UIView *window = parent.superview;
    
    [UIView animateWithDuration:0.5
                     animations:^{
                         CGRect tabFrame = tabBar.frame;
                         tabFrame.origin.y = CGRectGetMaxY(window.bounds) - CGRectGetHeight(tabBar.frame);
                         tabBar.frame = tabFrame;
                         
                         CGRect contentFrame = content.frame;
                         contentFrame.size.height -= tabFrame.size.height;
                     }];
}


- (void) updateLocation:(CLLocationCoordinate2D)currentCoordinate {
    
    [nmv.map clear];
    
    NSLog(@"New location");
    NSLog(@"Long: %f", currentCoordinate.longitude);
    NSLog(@"Lat: %f", currentCoordinate.latitude);
    
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:currentCoordinate.latitude + 0.003
                                                            longitude:currentCoordinate.longitude
                                                                 zoom:15];
    [nmv.map setCamera:camera];
    // Creates a marker in the center of the map.
    GMSMarker *marker = [[GMSMarker alloc] init];
    marker.position = currentCoordinate;
    marker.title = @"Here";
    marker.snippet = @"My location";
    marker.animated = YES;
    marker.map = nmv.map;
    
    
    
    
}


- (void)locationDidChange:(NSNotification *)note{
    LocationController* locationController = [LocationController sharedLocationController];
    NSLog(@"Did update locations");
    [self updateLocation:locationController.location.coordinate];
    
    [locationController.av dismissWithClickedButtonIndex:0 animated:YES];
    locationController.av = nil;
}

- (void) handlePickerDone
{
    [self dismissModalViewControllerAnimated:YES];
}

//ADA
- (IBAction)selectFriendsButtonAction:(id)sender {
    if (self.friendPickerController == nil) {
        // Create friend picker, and get data loaded into it.
        self.friendPickerController = [[FBFriendPickerViewController alloc] init];
        self.friendPickerController.title = @"Select Friends";
        self.friendPickerController.delegate = self;
    }
    [self.friendPickerController loadData];
    [self.friendPickerController clearSelection];
    [self presentViewController:self.friendPickerController
                       animated:YES
                     completion:^(void){
                         [self addSearchBarToFriendPickerView];
                     }
     ];
    
}
- (void)facebookViewControllerCancelWasPressed:(id)sender
{
    NSLog(@"Friend selection cancelled.");
    [self handlePickerDone];
}

- (void)facebookViewControllerDoneWasPressed:(id)sender
{
    [recipientsList removeAllObjects];
    
    for (id<FBGraphUser> user in self.friendPickerController.selection) {
        [recipientsList addObject:user];
        NSLog(@"Person is %@", user);
    }
    [self handlePickerDone];
}

- (void) handleSearch:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    nmv.searchText = searchBar.text;
    [self.friendPickerController updateView];
}

- (void)searchBarSearchButtonClicked:(UISearchBar*)searchBar
{
    [self handleSearch:searchBar];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar {
    nmv.searchText = nil;
    [searchBar resignFirstResponder];
}

- (BOOL)friendPickerViewController:(FBFriendPickerViewController *)friendPicker
                 shouldIncludeUser:(id<FBGraphUser>)user
{
    //TODO: Trim this list to just show FB friends who are members of this app
    if (nmv.searchText && ![nmv.searchText isEqualToString:@""]) {
        NSRange result = [user.name
                          rangeOfString:nmv.searchText
                          options:NSCaseInsensitiveSearch];
        
        if (result.location != NSNotFound) {
            return YES;
        } else {
            return NO;
        }
    } else {
        return YES;
    }
    return YES;
}

@end

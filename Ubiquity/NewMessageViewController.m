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
@property (nonatomic, strong) NSArray *repeatOptions;
//@property (nonatomic, strong) UITextField *locationSearchTextField;
//@property (nonatomic, strong) UIButton *locationSearchButton;
//@property (nonatomic, strong) UIGestureRecognizer *tapRecognizer;

@end

@implementation NewMessageViewController {
    NewMessageView *nmv;
    GMSMapView *mapView;
}

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

    self.friendPickerController = nil;
    
    
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

- (void) startSearch: (id) sender
{
    NSLog(@"Searching for location");
    // append to code
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


//ANYWALL
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
    
    // Set the access control list on the postObject to restrict future modifications
    // to this object
    PFACL *readOnlyACL = [PFACL ACL];
    [readOnlyACL setPublicReadAccess:YES]; // Create read-only permissions
    [readOnlyACL setPublicWriteAccess:NO];
    
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


- (BOOL) textFieldShouldReturn: (UITextField *)textField {
    
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
    marker.map = nmv.map;
    
    
}


- (void)locationDidChange:(NSNotification *)note{
    LocationController* locationController = [LocationController sharedLocationController];
    NSLog(@"Did update locations");
    [self updateLocation:locationController.location.coordinate];
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
    [self presentModalViewController:self.friendPickerController animated:YES];
    
}
- (void)facebookViewControllerCancelWasPressed:(id)sender
{
    NSLog(@"Friend selection cancelled.");
    [self handlePickerDone];
}

- (void)facebookViewControllerDoneWasPressed:(id)sender
{
    for (id<FBGraphUser> user in self.friendPickerController.selection) {
        NSLog(@"Friend selected: %@", user.name);
    }
    [self handlePickerDone];
}




@end

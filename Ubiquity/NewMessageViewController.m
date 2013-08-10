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
#import "WallPostsViewController.h"
#import "LocationController.h"
#import "Geocoding.h"

#define kOFFSET_FOR_KEYBOARD 190.0
#define kNAV_OFFSET self.navigationController.navigationBar.bounds.size.height;


@interface NewMessageViewController ()
{
    BOOL imagePicked;
    PFFile *photoFile;
    GMSMarker *marker;;
}
@end

@implementation NewMessageViewController

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
        
        self.title = @"New Message";

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(locationDidChange:)
                                                     name:kPAWLocationChangeNotification
                                                   object:nil];
        recipientsList = [[NSMutableArray alloc] init];
        
        UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                    target:self
                                                                                    action:@selector(closeNewMessage:)];
        [[self navigationItem] setLeftBarButtonItem:backButton];
        marker = [[GMSMarker alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    // Do any additional setup after loading the view.
    self.repeatOptions = [[NSArray alloc] initWithObjects:kNMNever, kNMDaily, kNMWeekly, kNMMonthy, nil];
    
    _nmv = [[NewMessageView alloc] initWithFrame: [UIScreen mainScreen].bounds];
    [self setView: _nmv];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(locationDidChange:)
                                                 name:kPAWLocationChangeNotification
                                               object:nil];
    
    _nmv.toRecipientTextField.delegate = self;
    
    _nmv.messageTextView.delegate = self;
    _nmv.locationSearchTextField.delegate = self;
    
    [_nmv.locationSearchButton addTarget:self action:@selector(startSearch:) forControlEvents:UIControlEventTouchUpInside];
    
    [_nmv.sendButton addTarget:self action:@selector(sendMessage:) forControlEvents:UIControlEventTouchUpInside];
    
    
    [_nmv.toRecipientButton addTarget:self action:@selector(selectFriendsButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    LocationController* locationController = [LocationController sharedLocationController];
    [self updateLocation:locationController.location.coordinate];
    
    _nmv.tapRecognizer = [[UITapGestureRecognizer alloc]  initWithTarget:self action:@selector(hideKeyboard:)];
    [_nmv addGestureRecognizer:_nmv.tapRecognizer];

    
    
    [_nmv.pictureButton addTarget:self action:@selector(choosePicture:) forControlEvents:UIControlEventTouchUpInside];
    
    _nmv.map.delegate = self;
    
    self.friendPickerController = nil;
    _nmv.searchBar = nil;
    
    UISwipeGestureRecognizer *swipeDown = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(closeNewMessage:)];
    [swipeDown setDirection:UISwipeGestureRecognizerDirectionDown];
    [self.view addGestureRecognizer:swipeDown];

    _nmv.imagePicker = [[UIImagePickerController alloc] init];
    _nmv.imagePicker.delegate = self;
    
}

- (void)addSearchBarToFriendPickerView
{
    if (_nmv.searchBar == nil) {
        CGFloat searchBarHeight = 44.0;
        _nmv.searchBar =
        [[UISearchBar alloc]
         initWithFrame:
         CGRectMake(0,0,
                    self.view.bounds.size.width,
                    searchBarHeight)];
        _nmv.searchBar.autoresizingMask = _nmv.searchBar.autoresizingMask |
        UIViewAutoresizingFlexibleWidth;
        _nmv.searchBar.delegate = self;
        _nmv.searchBar.showsCancelButton = YES;
        
        [self.friendPickerController.canvasView addSubview:_nmv.searchBar];
        CGRect newFrame = self.friendPickerController.view.bounds;
        newFrame.size.height -= searchBarHeight;
        newFrame.origin.y = searchBarHeight;
        self.friendPickerController.tableView.frame = newFrame;
    }
}

-(void) mapView:(GMSMapView *)mv didLongPressAtCoordinate:(CLLocationCoordinate2D)coord
{
    [self updateLocation:coord];
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    [_nmv.map setUserInteractionEnabled:NO];
}

-(void) hideKeyboard: (id) sender
{
    [_nmv.messageTextView resignFirstResponder];
    [_nmv.locationSearchTextField resignFirstResponder];
    [_nmv.toRecipientTextField resignFirstResponder];
    [_nmv.map setUserInteractionEnabled:YES];

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
    if ([sender isEqual:_nmv.locationSearchTextField])
    {
        //move the main view, so that the keyboard does not hide it.
        if  (self.view.frame.origin.y >= 0)
        {
            [self setViewMovedUp:YES];
        }
    }
    [_nmv.map setUserInteractionEnabled:NO];

    
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
    if (imagePicked == YES) {
        [_nmv.thumbnailImageView removeFromSuperview];
    }
    [_nmv.messageTextView setText: @""];
    [_nmv.toRecipientButton setTitle: @"Select Recipient" forState:UIControlStateNormal];
    imagePicked = NO;
    LocationController* locationController = [LocationController sharedLocationController];
    [self updateLocation:locationController.location.coordinate];
    
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.tabBarController setSelectedIndex: 0];
}

- (void)addMarker{
    
    double lat = [[gs.geocode objectForKey:@"lat"] doubleValue];
    double lng = [[gs.geocode objectForKey:@"lng"] doubleValue];
    
    CLLocationCoordinate2D geolocation = CLLocationCoordinate2DMake(lat,lng);
    marker.position = geolocation;
    marker.title = [gs.geocode objectForKey:@"address"];
    NSLog(@"%@", marker.title);
    NSLog(@"%f, %f", lat, lng);
    
    marker.map = _nmv.map;
    
    GMSCameraUpdate *geoLocateCam = [GMSCameraUpdate setTarget:geolocation];
    [_nmv.map animateWithCameraUpdate:geoLocateCam];
    
}

- (void) startSearch: (id) sender
{
    NSLog(@"searching for: %@", _nmv.locationSearchTextField.text);
    LocationController* locationController = [LocationController sharedLocationController];
    CLLocationCoordinate2D currentCoordinate = locationController.location.coordinate;
    NSDictionary *curLocation = [[NSDictionary alloc]initWithObjectsAndKeys:[NSNumber numberWithDouble:currentCoordinate.latitude],@"lat",[NSNumber numberWithDouble:currentCoordinate.longitude],@"lng",@"",@"address",nil];
    //Not a perfect solution for keeping the map at the same place
    //TODO: Fix it so map doesn't shift at all when search for invalid address
    gs = [[Geocoding alloc] initWithCurLocation:curLocation];
   [gs geocodeAddress:_nmv.locationSearchTextField.text withCallback:@selector(addMarker) withDelegate:self];
}


- (void) setPickedValueForPickerButton
{
    NSString *selectedTitle = [self pickerView:_nmv.repeatTimesPicker titleForRow:[_nmv.repeatTimesPicker selectedRowInComponent:0] forComponent:0];
    [_nmv.showRepeatPickerButton setTitle: selectedTitle forState:UIControlStateNormal];
}

- (void) pickerDoneClicked : (id) sender
{
    [_nmv.pickerToolbar removeFromSuperview];
    [_nmv.repeatTimesPicker removeFromSuperview];
    [_nmv addSubview:_nmv.sendButton];
    [self setPickedValueForPickerButton];
    [_nmv addSubview:_nmv.showRepeatPickerButton];
    [_nmv.tapRecognizer setEnabled:YES];
}

- (void) showPicker: (id) sender
{
    [sender removeFromSuperview];
    [_nmv.sendButton removeFromSuperview];
    [_nmv addSubview:_nmv.pickerToolbar];
    [_nmv addSubview: _nmv.repeatTimesPicker];
    [_nmv.tapRecognizer setEnabled:NO];

}

- (void) sendMessage: (id) sender
{
    // Dismiss keyboard and capture any auto-correct
    [_nmv.messageTextView resignFirstResponder];

    // Get the post's message
    NSString *postMessage = _nmv.messageTextView.text;
    
    [_nmv.messageTextView setText: @""];
    [_nmv.toRecipientButton setTitle: @"Select Recipient" forState:UIControlStateNormal];

    
    //Get the currently logged in PFUser
    PFUser *user = [PFUser currentUser];
    
    //Get and set the marker's location as where the post should be
    CLLocationCoordinate2D postLocation = marker.position;
    PFGeoPoint *currentPoint = [PFGeoPoint geoPointWithLatitude:postLocation.latitude
                                                      longitude:postLocation.longitude];
    
    
    // Create a PFObject using the Post class and set the values we extracted above
    PFObject *postObject = [PFObject objectWithClassName:kPAWParsePostsClassKey];
    [postObject setObject:postMessage forKey:kPAWParseTextKey];
    [postObject setObject:[user objectForKey:@"userData"] forKey:kPAWParseSenderKey];
    [postObject setObject:currentPoint forKey:kPAWParseLocationKey];
    [postObject setObject: [NSString stringWithFormat: @"%@", _nmv.showRepeatPickerButton.titleLabel] forKey:kNMFrequencyKey];
    if (imagePicked == YES) { //There's an image to be included with this post!
        [postObject setObject:photoFile forKey:@"photo"];
        [_nmv.thumbnailImageView removeFromSuperview];
    }
    imagePicked = NO;
    [postObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        //For each person we are sending to
        for (id<FBGraphUser> user in recipientsList) {
            
            
            [AppDelegate linkOrStoreUserDetails:user
                                           toId:[user id]
                                         toUser:nil
                          andStoreUnderRelation:@"receivers"
                                       toObject:postObject
                                     finalBlock:^(PFObject *made){}];
        }
    }];
    
    // Set the access control list on the postObject to restrict future modifications
    // to this object
    PFACL *readOnlyACL = [PFACL ACL];
    [readOnlyACL setPublicReadAccess:YES]; // Create read-only permissions
    [readOnlyACL setWriteAccess:YES forUser:[PFUser currentUser]];
    
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

- (void) choosePicture: (id) sender
{
    NSLog(@"Trying to attach a picture!");
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [_nmv.imagePicker setSourceType:UIImagePickerControllerSourceTypeCamera];
    } else {
        [_nmv.imagePicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    }
    
    [self presentViewController:_nmv.imagePicker animated:YES completion:nil];
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    imagePicked = NO;
}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    UIImage *newImage = [info valueForKey:UIImagePickerControllerOriginalImage];
    NSData *imageData = UIImageJPEGRepresentation(newImage, 1.0f);
    photoFile = [PFFile fileWithData:imageData];
    imagePicked = YES;
    //Make a thumbnail appear so user can see the image they attached!
    _nmv.thumbnailImage = [self getThumbnailFromImage:newImage];
    _nmv.thumbnailImageView = [[UIImageView alloc] initWithImage:_nmv.thumbnailImage];
    float x = _nmv.messageTextView.frame.origin.x + 230 - _nmv.thumbnailImage.size.width;
    float y = _nmv.messageTextView.frame.origin.y + 130 - _nmv.thumbnailImage.size.height;
    _nmv.thumbnailImageView.frame = CGRectMake(x, y, _nmv.thumbnailImage.size.width, _nmv.thumbnailImage.size.height);
    [_nmv addSubview:_nmv.thumbnailImageView];
}

- (UIImage *)getThumbnailFromImage:(UIImage *)image {
    CGRect newRect = CGRectIntegral(CGRectMake(0, 0, 20, 20));
    CGImageRef imageRef = image.CGImage;
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(20.0f, 20.0f), NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetInterpolationQuality(context, kCGInterpolationHigh);
    CGAffineTransform flipVertical = CGAffineTransformMake(1, 0, 0, -1, 0, 20.0f);
    CGContextConcatCTM(context, flipVertical);
    // Draw into the context; this scales the image
    CGContextDrawImage(context, newRect, imageRef);
    CGImageRef newImageRef = CGBitmapContextCreateImage(context);
    UIImage *newImage = [UIImage imageWithCGImage:newImageRef];
    
    CGImageRelease(newImageRef);
    UIGraphicsEndImageContext();
    
    return newImage;
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
                         content.frame = parent.bounds;
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
    
    [_nmv.map clear];
    
    NSLog(@"New location");
    NSLog(@"Long: %f", currentCoordinate.longitude);
    NSLog(@"Lat: %f", currentCoordinate.latitude);
    //NSLog(@"%@", [LocationController sharedLocationController].location.coordinate);
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:currentCoordinate.latitude + 0.003
                                                            longitude:currentCoordinate.longitude
                                                                 zoom:15];
    [_nmv.map setCamera:camera];
    
    marker.position = currentCoordinate;
    marker.title = @"Here";
    marker.snippet = @"My location";
    marker.animated = YES;
    marker.map = _nmv.map;
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
    [self dismissViewControllerAnimated:NO completion:nil];
    [self hideTabBar];

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
        [recipientsList addObject: user];

        NSLog(@"Person is %@", user);
    }
    NSMutableString *names = [[NSMutableString alloc] initWithString:@" "];
    
    for (id <FBGraphUser> user in recipientsList)
    {
        names = [names stringByAppendingString: (@"%@", [user name])];
        names = [names stringByAppendingString: (@", ")];
    }
    [_nmv.toRecipientButton setTitle:names forState: UIControlStateNormal];

    
    [self handlePickerDone];
}

- (void) handleSearch:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    _nmv.searchText = searchBar.text;
    [self.friendPickerController updateView];
}

- (void)searchBarSearchButtonClicked:(UISearchBar*)searchBar
{
    [self handleSearch:searchBar];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar {
    _nmv.searchText = nil;
    [searchBar resignFirstResponder];
}

- (BOOL)friendPickerViewController:(FBFriendPickerViewController *)friendPicker
                 shouldIncludeUser:(id<FBGraphUser>)user
{
    //TODO: Trim this list to just show FB friends who are members of this app
    if (_nmv.searchText && ![_nmv.searchText isEqualToString:@""]) {
        NSRange result = [user.name
                          rangeOfString:_nmv.searchText
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

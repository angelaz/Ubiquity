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

@interface NewMessageViewController ()

@property (nonatomic, strong) UITextField *toRecipientTextField;
@property (nonatomic, strong) UILabel *toLabel;
@property (nonatomic, strong) UITextField *messageTextField;
@property (nonatomic, strong) UIButton *sendButton;
@property (nonatomic, strong) UIPickerView *repeatTimesPicker;
@property (nonatomic, strong) UIToolbar *pickerToolbar;
@property (nonatomic, strong) UIButton *showRepeatPickerButton;
@property (nonatomic, strong) NSArray *repeatOptions;
@property (nonatomic, strong) UITextField *locationSearchTextField;
@property (nonatomic, strong) UIButton *locationSearchButton;

@end

@implementation NewMessageViewController {
    NewMessageView *nmv;
    GMSMapView *mapView;
}

- (void) viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [self.tabBarController.tabBar setHidden: YES];
    [super viewWillAppear:animated];
}

-(void) viewWillDisappear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [self.tabBarController.tabBar setHidden: NO];
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
    
    nmv = [[NewMessageView alloc] initWithFrame: self.view.frame];
    [self setView: nmv];
    
    nmv.toRecipientTextField.delegate = self;
    
    nmv.messageTextField.delegate = self;
    nmv.locationSearchTextField.delegate = self;
    
    [nmv.locationSearchButton addTarget:self action:@selector(startSearch:) forControlEvents:UIControlEventTouchUpInside];
    [nmv.closeButton addTarget:self action:@selector(closeNewMessage:) forControlEvents:UIControlEventTouchUpInside];
    
    [nmv.sendButton addTarget:self action:@selector(sendMessage:) forControlEvents:UIControlEventTouchUpInside];

    nmv.repeatTimesPicker.delegate = self;
    nmv.repeatTimesPicker.dataSource = self;
    
    
    self.pickerToolbar = [[UIToolbar alloc] init];
    self.pickerToolbar.barStyle = UIBarStyleDefault;
    self.pickerToolbar.translucent = NO;
    [self.pickerToolbar sizeToFit];
    UIBarButtonItem* doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                   style:UIBarButtonItemStyleBordered target:self
                                                                  action:@selector(pickerDoneClicked:)];
    [self.pickerToolbar setItems:[NSArray arrayWithObjects:doneButton, nil]];
    
    [nmv.showRepeatPickerButton addTarget:self action:@selector(showPicker:) forControlEvents:UIControlEventTouchUpInside];
    [self setPickedValueForPickerButton];
    
    
    LocationController* locationController = [LocationController sharedLocationController];
    [self updateLocation:locationController.location.coordinate];
    
}

-(void) closeNewMessage: (id) sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
    RecentViewController *rvc = [[RecentViewController alloc] init];
    [self.navigationController pushViewController: rvc animated: YES];

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
    [self.pickerToolbar removeFromSuperview];
    [nmv.repeatTimesPicker removeFromSuperview];
    [nmv addSubview:nmv.sendButton];
    [self setPickedValueForPickerButton];
    [nmv addSubview:nmv.showRepeatPickerButton];
    
    
}

- (void) showPicker: (id) sender
{
    NSLog(@"show picker!");
    [sender removeFromSuperview];
    [nmv.sendButton removeFromSuperview];
    [nmv addSubview:self.pickerToolbar];
    [nmv addSubview: nmv.repeatTimesPicker];
}


//ANYWALL
- (void) sendMessage: (id) sender
{
    // Dismiss keyboard and capture any auto-correct
    [nmv.messageTextField resignFirstResponder];
    
    // Get user's current location
    LocationController* locationController = [LocationController sharedLocationController];
    CLLocationCoordinate2D currentCoordinate = locationController.location.coordinate;
    
    // Get the post's message
    NSString *postMessage = nmv.messageTextField.text;
    
    //Get the currently logged in PFUser
    PFUser *user = [PFUser currentUser];
    
    // Create a PFGeoPoint using the user's location
    PFGeoPoint *currentPoint = [PFGeoPoint geoPointWithLatitude:currentCoordinate.latitude
                                                      longitude:currentCoordinate.longitude];
    
    // Create a PFObject using the Post class and set the values we extracted above
    PFObject *postObject = [PFObject objectWithClassName:kPAWParsePostsClassKey];
    [postObject setObject:postMessage forKey:kPAWParseTextKey];
    [postObject setObject:user forKey:kPAWParseUserKey];
    [postObject setObject:currentPoint forKey:kPAWParseLocationKey];
    [postObject setObject: [NSString stringWithFormat: @"%@", self.showRepeatPickerButton.titleLabel] forKey:kNMFrequencyKey];
    
    // Set the access control list on the postObject to restrict future modifications
    // to this object
    PFACL *readOnlyACL = [PFACL ACL];
    [readOnlyACL setPublicReadAccess:YES]; // Create read-only permissions
    [readOnlyACL setPublicWriteAccess:NO];
    
    [postObject setACL:readOnlyACL]; // Set the permissions on the postObject
    
    //https://www.parse.com/docs/osx/api/Classes/PFACL.html
    //The above link will become helpful when we want individual users to be able to see things
    //(Or not)
    
    
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
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    RecentViewController *rvc = [[RecentViewController alloc] init];
    [self.navigationController pushViewController: rvc animated: YES];
    
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

- (void) updateLocation:(CLLocationCoordinate2D)currentCoordinate {
    
    NSLog(@"New location");
    
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:currentCoordinate.latitude + 2
                                                            longitude:currentCoordinate.longitude
                                                                 zoom:6];
    CGRect mapRect = CGRectMake(0, 0, mapView.frame.size.width, mapView.frame.size.height);
    mapView = [GMSMapView mapWithFrame:mapRect camera:camera];
    mapView.myLocationEnabled = YES;
    [self.view addSubview:mapView];
    
    // Creates a marker in the center of the map.
    GMSMarker *marker = [[GMSMarker alloc] init];
    marker.position = currentCoordinate;
    marker.title = @"Here";
    marker.snippet = @"My location";
    marker.map = mapView;
    
}

//- (void)locationManager:(CLLocationManager *)manager
//
//     didUpdateLocations:(NSArray *)locations {
//    
//    // If it's a relatively recent event, turn off updates to save power
//    
//    //CLLocation* location = [locations lastObject];
//    
//    LocationController* locationController = [LocationController sharedLocationController];
//    CLLocation *location = locationController.location;
//    
//    NSDate* eventDate = location.timestamp;
//    
//    NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
//    
//    if (abs(howRecent) < 15.0) {
//        
//        // If the event is recent, do something with it.
//        
//        NSLog(@"latitude %+.6f, longitude %+.6f\n",
//              
//              location.coordinate.latitude,
//              
//              location.coordinate.longitude);
//        
//        [self updateLocation:location.coordinate];
//        NSLog(@"Updated map");
//        
//    }
//    
//}



- (void)locationDidChange:(NSNotification *)note{
    LocationController* locationController = [LocationController sharedLocationController];
    NSLog(@"Did update locations");
    [self updateLocation:locationController.location.coordinate];
}



@end

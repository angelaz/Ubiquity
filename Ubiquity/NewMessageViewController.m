//
//  NewMessageViewController.m
//  Ubiquity
//
//  Created by Winnie Wu on 7/24/13.
//  Copyright (c) 2013 Team Ubi. All rights reserved.
//

#import "NewMessageViewController.h"
#import "AppDelegate.h"
#import <Parse/Parse.h>

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

@property (nonatomic, strong) CLLocationManager *locationManager;
@end

@implementation NewMessageViewController {
    GMSMapView *mapView;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        _locationManager = [[CLLocationManager alloc] init];
        
        _locationManager.delegate = self;
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        
        // Set a movement threshold for new events
        _locationManager.distanceFilter = kCLLocationAccuracyNearestTenMeters;
        
        [_locationManager startUpdatingLocation];
        
        // Set initial location if available
        CLLocation *currentLocation = _locationManager.location;
        if (currentLocation) {
            AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
            appDelegate.currentLocation = currentLocation;
        }
        
//        [[NSNotificationCenter defaultCenter] addObserver:self
//                                                 selector:@selector(locationDidChange:)
//                                                     name:kPAWLocationChangeNotification
//                                                   object:nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    int const SCREEN_WIDTH = [UIScreen mainScreen].bounds.size.width;
    int const SCREEN_HEIGHT = [UIScreen mainScreen].bounds.size.height;
    int const LEFT_PADDING = 30;
    int const LINE_HEIGHT = 30;
    
    self.repeatOptions = [[NSArray alloc] initWithObjects:kNMNever, kNMDaily, kNMWeekly, kNMMonthy, nil];

    
    //dummy mapview
    
//    
//    MKMapView * map = [[MKMapView alloc] initWithFrame: CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT+30)];
//    map.delegate = self;
//    [self.view addSubview:map];

    [self setupMapWithWidth:SCREEN_WIDTH andHeight:SCREEN_HEIGHT - 35];
    
    UIImageView *speechBubbleBackground = [[UIImageView alloc] initWithFrame:CGRectMake(LEFT_PADDING-20, LEFT_PADDING, SCREEN_WIDTH - LEFT_PADDING + 10, 240)];
    speechBubbleBackground.image = [UIImage imageNamed:@"SpeechBubble"];
    [self.view addSubview:speechBubbleBackground];
    
    self.toLabel = [[UILabel alloc] initWithFrame:CGRectMake(LEFT_PADDING, 45, 50, LINE_HEIGHT)];
    self.toLabel.text = @"To:";
    [self.view addSubview:self.toLabel];
    
    self.toRecipientTextField = [[UITextField alloc] initWithFrame:CGRectMake(LEFT_PADDING + 30, 45, 230.0, LINE_HEIGHT)];
    self.toRecipientTextField.delegate = self;
    self.toRecipientTextField.borderStyle = UITextBorderStyleRoundedRect;
    [self.view addSubview:self.toRecipientTextField];
    
    self.messageTextField = [[UITextField alloc] initWithFrame:CGRectMake(LEFT_PADDING, 85.0, 260.0, 140.0)];
    self.messageTextField.delegate = self;
    self.messageTextField.borderStyle = UITextBorderStyleRoundedRect;
    [self.view addSubview:self.messageTextField];
    
    
    self.locationSearchTextField = [[UITextField alloc] initWithFrame:CGRectMake(LEFT_PADDING - 10, SCREEN_HEIGHT - 70, 250.0, LINE_HEIGHT)];
    self.locationSearchTextField.delegate = self;
    self.locationSearchTextField.placeholder = @"Search for a location";
    self.locationSearchTextField.borderStyle = UITextBorderStyleRoundedRect;
    [self.view addSubview:self.locationSearchTextField];

    
    
    self.locationSearchButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *btnImage = [UIImage imageNamed:@"searchbutton"];
    [self.locationSearchButton setBackgroundImage: btnImage forState: UIControlStateNormal];
    self.locationSearchButton.frame = CGRectMake(SCREEN_WIDTH - 40, SCREEN_HEIGHT - 68, LINE_HEIGHT-5, LINE_HEIGHT-5);
    [self.locationSearchButton addTarget:self action:@selector(startSearch:) forControlEvents:UIControlEventTouchUpInside];
  //  [self.locationSearchButton setTitle: @"Go" forState:UIControlStateNormal]; // replace with mag glass later
    
    [self.view addSubview:self.locationSearchButton];

    
    
    
    self.sendButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    //self.sendButton.backgroundColor = [UIColor whiteColor];
    self.sendButton.frame = CGRectMake(SCREEN_WIDTH - 60, SCREEN_HEIGHT - 28, 50, LINE_HEIGHT);
    [self.sendButton addTarget:self action:@selector(sendMessage:) forControlEvents:UIControlEventTouchUpInside];
    [self.sendButton setTitle: @"Send" forState:UIControlStateNormal];
    [self.view addSubview:self.sendButton];
    
    
    self.repeatTimesPicker = [[UIPickerView alloc] initWithFrame: CGRectMake(LEFT_PADDING-10, SCREEN_HEIGHT - 130, 280, LINE_HEIGHT)];
    self.repeatTimesPicker.delegate = self;
    self.repeatTimesPicker.backgroundColor = [UIColor whiteColor];
    self.repeatTimesPicker.dataSource = self;
    self.repeatTimesPicker.showsSelectionIndicator = YES;
    
    self.pickerToolbar = [[UIToolbar alloc] init];
    self.pickerToolbar.barStyle = UIBarStyleDefault;
    self.pickerToolbar.translucent = NO;
    [self.pickerToolbar sizeToFit];
    UIBarButtonItem* doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                   style:UIBarButtonItemStyleBordered target:self
                                                                  action:@selector(pickerDoneClicked:)];
    
    [self.pickerToolbar setItems:[NSArray arrayWithObjects:doneButton, nil]];
    
    
    self.showRepeatPickerButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    //self.showRepeatPickerButton.backgroundColor = [UIColor whiteColor];
    self.showRepeatPickerButton.frame = CGRectMake(LEFT_PADDING-10, SCREEN_HEIGHT - 28, SCREEN_WIDTH - 100, 30.0);
    [self.showRepeatPickerButton addTarget:self action:@selector(showPicker:) forControlEvents:UIControlEventTouchUpInside];
    [self setPickedValueForPickerButton];
    
    [self.view addSubview:self.showRepeatPickerButton];
    
    
    
}

- (void) startSearch: (id) sender
{
    NSLog(@"Searching for location");
    // append to code
}


- (void) setPickedValueForPickerButton
{
    NSString *selectedTitle = [self pickerView:self.repeatTimesPicker titleForRow:[self.repeatTimesPicker selectedRowInComponent:0] forComponent:0];
    [self.showRepeatPickerButton setTitle: selectedTitle forState:UIControlStateNormal];
}

- (void) pickerDoneClicked : (id) sender
{
    [self.pickerToolbar removeFromSuperview];
    [self.repeatTimesPicker removeFromSuperview];
    [self.view addSubview:self.sendButton];
    [self setPickedValueForPickerButton];
    [self.view addSubview:self.showRepeatPickerButton];

    
}

- (void) showPicker: (id) sender
{
    NSLog(@"show picker!");
    [sender removeFromSuperview];
    [self.sendButton removeFromSuperview];
    [self.view addSubview:self.pickerToolbar];
    [self.view addSubview: self.repeatTimesPicker];
}

- (void) setupMapWithWidth: (int) width andHeight: (int) height {
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    CLLocationCoordinate2D currentCoordinate = appDelegate.currentLocation.coordinate;
    
    NSLog(@"Long: %f", currentCoordinate.longitude);
    NSLog(@"Lat: %f", currentCoordinate.latitude);

    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:currentCoordinate.latitude + 2
                                                            longitude:currentCoordinate.longitude
                                                                 zoom:6];
    CGRect mapRect = CGRectMake(0, 0, width, height);
    mapView = [GMSMapView mapWithFrame:mapRect camera:camera];
    mapView.myLocationEnabled = YES;
    [self.view addSubview:mapView];
    
    // Creates a marker in the center of the map.
    GMSMarker *marker = [[GMSMarker alloc] init];
    //marker.icon = [UIImage imageNamed:@"PinMarker"]; needs to find better graphics
    marker.position = currentCoordinate;
    marker.title = @"Here";
    marker.snippet = @"My location";
    marker.map = mapView;
}

//ANYWALL
- (void) sendMessage: (id) sender
{
    // Dismiss keyboard and capture any auto-correct
    [_messageTextField resignFirstResponder];
    
    // Get user's current location
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    CLLocationCoordinate2D currentCoordinate = appDelegate.currentLocation.coordinate;
    
    // Get the post's message
    NSString *postMessage = _messageTextField.text;
    
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
    
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (BOOL) textFieldShouldReturn: (UITextField *)textField {
    [textField resignFirstResponder];
    return  NO;
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

//ANYWALL
- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    // This is where the post happens
    [appDelegate setCurrentLocation:newLocation];
    
    CLLocationCoordinate2D currentCoordinate = appDelegate.currentLocation.coordinate;
    
    [self updateLocation:currentCoordinate];
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

- (void)locationManager:(CLLocationManager *)manager

     didUpdateLocations:(NSArray *)locations {
    
    // If it's a relatively recent event, turn off updates to save power
    
    CLLocation* location = [locations lastObject];
    
    NSDate* eventDate = location.timestamp;
    
    NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
    
    if (abs(howRecent) < 15.0) {
        
        // If the event is recent, do something with it.
        
        NSLog(@"latitude %+.6f, longitude %+.6f\n",
              
              location.coordinate.latitude,
              
              location.coordinate.longitude);
        
        AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        appDelegate.currentLocation = location;
        [self updateLocation:location.coordinate];
        NSLog(@"Updated map");
        
    }
    
}


@end

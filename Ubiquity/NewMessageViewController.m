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

@end

@implementation NewMessageViewController {
    GMSMapView *mapView;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    int const SCREEN_WIDTH = [UIScreen mainScreen].applicationFrame.size.width;
    int const SCREEN_HEIGHT = [UIScreen mainScreen].applicationFrame.size.height;
    
    //dummy mapview
//    MKMapView * map = [[MKMapView alloc] initWithFrame: CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT+30)];
//    map.delegate = self;
//    [self.view addSubview:map];

    [self setupMap];
    
    self.toLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 30, 50, 30)];
    self.toLabel.text = @"To:";
    [self.view addSubview:self.toLabel];
    
    self.toRecipientTextField = [[UITextField alloc] initWithFrame:CGRectMake(40.0, 30.0, 270.0, 30.0)];
    self.toRecipientTextField.delegate = self;
    self.toRecipientTextField.borderStyle = UITextBorderStyleRoundedRect;
    [self.view addSubview:self.toRecipientTextField];
    
    self.messageTextField = [[UITextField alloc] initWithFrame:CGRectMake(10.0, 70.0, 300.0, 150.0)];
    self.messageTextField.delegate = self;
    self.messageTextField.borderStyle = UITextBorderStyleRoundedRect;
    [self.view addSubview:self.messageTextField];
    
    
    self.sendButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.sendButton.frame = CGRectMake(SCREEN_WIDTH - 60, SCREEN_HEIGHT - 20, 50, 30);
    [self.sendButton addTarget:self action:@selector(sendMessage:) forControlEvents:UIControlEventTouchUpInside];
    [self.sendButton setTitle: @"Send" forState:UIControlStateNormal];
    [self.view addSubview:self.sendButton];
    
    
    self.repeatTimesPicker = [[UIPickerView alloc] initWithFrame: CGRectMake(10, SCREEN_HEIGHT - 80, SCREEN_WIDTH, 30.0)];
    self.repeatTimesPicker.delegate = self;
    self.repeatTimesPicker.dataSource = self;
    self.repeatTimesPicker.showsSelectionIndicator = YES;
    
    //[self.view addSubview:repeatTimesPicker];
    
    self.pickerToolbar = [[UIToolbar alloc] init];
    self.pickerToolbar.barStyle = UIBarStyleBlack;
    self.pickerToolbar.translucent = YES;
    self.pickerToolbar.tintColor = nil;
    [self.pickerToolbar sizeToFit];
    UIBarButtonItem* doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                    style:UIBarButtonItemStyleBordered target:self
                                                                   action:@selector(pickerDoneClicked:)];
    
    [self.pickerToolbar setItems:[NSArray arrayWithObjects:doneButton, nil]];
    
    
    self.showRepeatPickerButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.showRepeatPickerButton.frame = CGRectMake(10, SCREEN_HEIGHT - 20, SCREEN_WIDTH - 100, 30.0);
    [self.showRepeatPickerButton addTarget:self action:@selector(showPicker:) forControlEvents:UIControlEventTouchUpInside];
    NSString *selectedTitle = [self pickerView:self.repeatTimesPicker titleForRow:[self.repeatTimesPicker selectedRowInComponent:0] forComponent:0];
    [self.showRepeatPickerButton setTitle: selectedTitle forState:UIControlStateNormal];
    [self.view addSubview:self.showRepeatPickerButton];
    
    
}

- (void) pickerDoneClicked : (id) sender
{
    [self.pickerToolbar removeFromSuperview];
    [self.repeatTimesPicker removeFromSuperview];
    [self.view addSubview:self.sendButton];
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

- (void) setupMap {
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    CLLocationCoordinate2D currentCoordinate = appDelegate.currentLocation.coordinate;

    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:currentCoordinate.latitude
                                                            longitude:currentCoordinate.longitude
                                                                 zoom:6];
    mapView = [GMSMapView mapWithFrame:CGRectZero camera:camera];
    mapView.myLocationEnabled = YES;
    self.view = mapView;
    
    // Creates a marker in the center of the map.
    GMSMarker *marker = [[GMSMarker alloc] init];
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
    NSUInteger numRows = 10;
    
    return numRows;
}

// tell the picker how many components it will have
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

// tell the picker the title for a given component
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    NSString *title;
    title = [NSString stringWithFormat:@"%d",row];
    
    return title;
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
}

@end

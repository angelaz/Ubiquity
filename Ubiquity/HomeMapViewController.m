//
//  HomeMapViewController.m
//  Ubiquity
//
//  Created by Winnie Wu on 8/9/13.
//  Copyright (c) 2013 Team Ubi. All rights reserved.
//

#import "HomeMapViewController.h"
#import "HomeMapView.h"
#import "AppDelegate.h"
#import "NewMessageViewController.h"
#import "WallPostsViewController.h"
#import "OptionsViewController.h"
#import "NoteViewController.h"
#import "LocationController.h"

@interface HomeMapViewController ()
@property (nonatomic, strong) HomeMapView *hmv;
@property (nonatomic, strong) NSDictionary *markerNotearrayDict;
@end

@implementation HomeMapViewController


- (void)viewDidLoad
{
    _hmv = [[HomeMapView alloc] initWithFrame: [UIScreen mainScreen].bounds];
    [self setView: _hmv];
    _hmv.map.delegate = self;
    [self initNewMessageButton];
    self.objects = [[NSMutableArray alloc] init];
    [self loadPins];
    _hmv.tapRecognizer = [[UITapGestureRecognizer alloc]  initWithTarget:self action:@selector(doStuff)];
    [_hmv addGestureRecognizer:_hmv.tapRecognizer];
    
    _hmv.map.delegate = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loadPins)
                                                 name:KPAWInitialLocationFound
                                               object:nil];

    
}

- (void) loadPins
{
    PFQuery *getPosts = [self getParseQuery];
    [self deployParseQuery: getPosts];
    
    
    _hmv.tapRecognizer = [[UITapGestureRecognizer alloc]  initWithTarget:self action:@selector(doStuff)];
    [_hmv addGestureRecognizer:_hmv.tapRecognizer];

    _hmv.map.delegate = self;
}

- (BOOL)mapView:(GMSMapView*)mapView didTapMarker:(GMSMarker *)marker
{
    [self readNote: marker];
    return YES;
}

- (void) deployParseQuery: (PFQuery *) query
{
    [self.objects removeAllObjects];
    [_hmv.map clear];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            // The find succeeded.
            NSLog(@"Successfully retrieved %d scores.", objects.count);
            // Do something with the found objects
            
            PFGeoPoint *current = [[PFGeoPoint alloc] init];
            NSMutableArray *allNotes = [[NSMutableArray alloc] init];
            NSMutableArray *notesForMarker = [[NSMutableArray alloc] init];
            NSMutableArray *markers = [[NSMutableArray alloc] init];
            
            for (PFObject *object in objects) {
                NSLog(@"%@", object.objectId);
                PFGeoPoint *gp = [object objectForKey: @"location"];
                if (![self pointsAreEqualA:current andB:gp withinRange:0.0])
                {
                    if (markers.count != 0)
                        [allNotes addObject: [notesForMarker copy]];
                    [notesForMarker removeAllObjects];
                    CLLocationCoordinate2D pinLocation = CLLocationCoordinate2DMake (gp.latitude, gp.longitude);
                    GMSMarker *marker = [GMSMarker markerWithPosition: pinLocation];
                    marker.icon = [UIImage imageNamed: @"UnreadNote"];
                    marker.animated = YES;
                    marker.map = _hmv.map;
                    
                    NSLog(@"new pin!");
                    
                    [markers addObject: marker];
                    self.markerNotearrayDict = [[NSMutableDictionary alloc] initWithObjects: @[markers, allNotes] forKeys:@[@"markers", @"arrayOfNotes"]];
                }
                [notesForMarker addObject:object];
                
                current = gp;
            }
            [allNotes addObject: [notesForMarker copy]];

            
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}

- (BOOL) pointsAreEqualA: (PFGeoPoint *) p1 andB: (PFGeoPoint *) p2 withinRange: (double) d
{
    return (p1.latitude + d >= p2.latitude && p1.latitude - d <= p2.latitude && p1.longitude + d >= p2.longitude && p1.longitude - d <= p2.longitude);
}

- (PFQuery *) getParseQuery
{
    PFQuery *query = [PFQuery queryWithClassName: kPAWParsePostsClassKey];
    
    LocationController* locationController = [LocationController sharedLocationController];
    CLLocationCoordinate2D currentCoordinate = locationController.location.coordinate;
    
	CLLocationAccuracy filterDistance = 1000.0f;
    PFGeoPoint *point = [PFGeoPoint geoPointWithLatitude:currentCoordinate.latitude longitude:currentCoordinate.longitude];
	[query whereKey:kPAWParseLocationKey nearGeoPoint:point withinKilometers:filterDistance / kPAWMetersInAKilometer];
    [query includeKey:kPAWParseSenderKey];
    
    
    
    if ([self.segmentedControl selectedSegmentIndex] == 0) {
        NSLog(@"Only shows notes from self");
        [query whereKey:@"sender" equalTo:[[PFUser currentUser] objectForKey:@"userData"]];
        [query whereKey:@"receivers" equalTo:[[PFUser currentUser] objectForKey:@"userData"]];
    } else if ([self.segmentedControl selectedSegmentIndex] == 1) {
        NSLog(@"Shows notes from friends");
        [query whereKey:@"receivers" equalTo:[[PFUser currentUser] objectForKey:@"userData"]];
    } else if ([self.segmentedControl selectedSegmentIndex] == 2) {
        NSLog(@"Shows public notes");
        [query whereKey:@"receivers" equalTo:[NSNull null]];
    }
    
    return query;
}
- (void) openNewMessageView
{
    NewMessageViewController *nmvc = [[NewMessageViewController alloc] init];
    UINavigationController *newMessageNavController = [[UINavigationController alloc]
                                                       initWithRootViewController:nmvc];
    self.navigationController.modalPresentationStyle = UIModalPresentationCurrentContext;
    [self presentViewController:newMessageNavController animated:YES completion:nil];
    
    nmvc.view.frame = CGRectMake(nmvc.view.frame.origin.x, self.view.frame.size.height, nmvc.view.frame.size.width, nmvc.view.frame.size.height);
    [UIView animateWithDuration:0.25
                     animations:^{
                         nmvc.view.frame = CGRectMake(0, self.navigationController.navigationBar.frame.size.height, nmvc.view.frame.size.width, nmvc.self.view.frame.size.height);
                     }];
    
}

- (void) initNewMessageButton
{
    UIImage *image = [UIImage imageNamed:@"newMessage"];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setBackgroundImage: [image stretchableImageWithLeftCapWidth:7.0 topCapHeight:0.0] forState:UIControlStateNormal];
    
    button.frame = CGRectMake(0.0, 0.0, image.size.width, image.size.height);
    
    [button addTarget:self action:@selector(openNewMessageView)    forControlEvents:UIControlEventTouchUpInside];
    
    UIView *v= [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, image.size.width, image.size.height) ];
    
    [v addSubview:button];
    
    UIBarButtonItem *newMessage = [[UIBarButtonItem alloc] initWithCustomView:v];
    
    self.navigationItem.rightBarButtonItem = newMessage;
    
    
}

- (void) doStuff {
    NSLog(@"Did stuff");
}

- (void)initUnreadNoteButton
{
    int const SCREEN_WIDTH = self.view.frame.size.width;
    int const SCREEN_HEIGHT = self.view.frame.size.height;
    UIButton *newButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *pictureButtonImage = [UIImage imageNamed:@"UnreadNote"];
    [newButton setBackgroundImage:pictureButtonImage forState:UIControlStateNormal];
    newButton.frame = CGRectMake(SCREEN_WIDTH/2 - 25, SCREEN_HEIGHT/2 - 70, 50.0, 40.0);
    [newButton addTarget:self action:@selector(readNote:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:newButton];
}

- (void) readNote: (id) sender
{
    GMSMarker *marker = sender;
    NSArray *notesList = [self getNotesListForMarker:marker];
    if (notesList)
    {
        NSLog(@"%@", notesList);
        NoteViewController *nvc = [[NoteViewController alloc] init];
        nvc.notes = notesList;
        UINavigationController *noteViewNavController = [[UINavigationController alloc]
                                                         initWithRootViewController:nvc];
        self.navigationController.modalPresentationStyle = UIModalPresentationCurrentContext;
        [self presentViewController:noteViewNavController animated:YES completion:nil];
        
        nvc.view.frame = CGRectMake(nvc.view.frame.origin.x, self.view.frame.size.height, nvc.view.frame.size.width, nvc.view.frame.size.height);
        [UIView animateWithDuration:0.25
                         animations:^{
                             nvc.view.frame = CGRectMake(0, self.navigationController.navigationBar.frame.size.height, nvc.view.frame.size.width, nvc.self.view.frame.size.height);
                         }];
        

    }
    
    
}

- (NSArray *) getNotesListForMarker: (GMSMarker *) marker
{
    NSArray *markersArray = [self.markerNotearrayDict objectForKey:@"markers"];
    for (int i = 0; i<markersArray.count; i++)
    {
        if ([markersArray[i] isEqual: marker])
        {
            return [self.markerNotearrayDict objectForKey:@"arrayOfNotes"][i];
        }
        
    }
    return nil;
}

- (id)init{
    self = [super init];
    if (self) {
        [self initButtons];
        [self initSegmentedControl];
        [self initOptionsButton];
    }
    return self;
}

- (void)initSegmentedControl
{
    
    NSArray *itemArray = [NSArray arrayWithObjects: [UIImage imageNamed:@"me"], [UIImage imageNamed:@"friends"], [UIImage imageNamed:@"public"], nil];
    self.segmentedControl = [[UISegmentedControl alloc] initWithItems:itemArray];
    self.segmentedControl.frame = CGRectMake(0,0,150,30);
    self.segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
    [self.segmentedControl setSelectedSegmentIndex:0];
    [self.segmentedControl addTarget:self
                              action:@selector(changeSegment:)
                    forControlEvents:UIControlEventValueChanged];
    [[self navigationItem] setTitleView:self.segmentedControl];
}

- (void)changeSegment:(UISegmentedControl *)sender
{
    NSInteger value = [sender selectedSegmentIndex];
    if (value == 0) {
        NSLog(@"Changed value to 0");
        [self loadPins];
    } else if (value == 1) {
        NSLog(@"Changed value to 1");
        [self loadPins];
    } else if (value == 2) {
        NSLog(@"Changed value to 2");
        [self loadPins];
    }
}

- (void)initButtons
{
    UIBarButtonItem *mapList = [[UIBarButtonItem alloc] initWithTitle:@"List"
                                                                style:UIBarButtonItemStylePlain
                                                               target:self
                                                               action:@selector(launchPostsView)];
    [[self navigationItem] setLeftBarButtonItem:mapList];
    
    UIImage *image = [UIImage imageNamed:@"newMessage"];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setBackgroundImage: [image stretchableImageWithLeftCapWidth:7.0 topCapHeight:0.0] forState:UIControlStateNormal];
    button.frame = CGRectMake(0.0, 0.0, image.size.width, image.size.height);
    [button addTarget:self action:@selector(launchNewMessage)    forControlEvents:UIControlEventTouchUpInside];
    UIView *v= [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, image.size.width, image.size.height)];
    [v addSubview:button];
    UIBarButtonItem *newMessage = [[UIBarButtonItem alloc] initWithCustomView:v];
    [[self navigationItem] setRightBarButtonItem:newMessage];
}
- (void)launchPostsView
{
    WallPostsViewController *wpvc = [[WallPostsViewController alloc] init];
    UINavigationController *wallPostsNavController = [[UINavigationController alloc]
                                                      initWithRootViewController:wpvc];
    [self.navigationController presentViewController:wallPostsNavController animated:NO completion:nil];
}
- (void)launchNewMessage
{
    NewMessageViewController *nmvc = [[NewMessageViewController alloc] init];
    UINavigationController *newMessageNavController = [[UINavigationController alloc]
                                                       initWithRootViewController:nmvc];
    [self.navigationController presentViewController:newMessageNavController animated:YES completion:nil];
}


- (void)initOptionsButton
{
    int const SCREEN_WIDTH = self.view.frame.size.width;
    int const SCREEN_HEIGHT = self.view.frame.size.height;
    self.optionsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *pictureButtonImage = [UIImage imageNamed:@"gear"];
    [self.optionsButton setBackgroundImage:pictureButtonImage forState:UIControlStateNormal];
    self.optionsButton.frame = CGRectMake(SCREEN_WIDTH - 25, SCREEN_HEIGHT - 70, 20.0, 20.0);
    [self.optionsButton addTarget:self action:@selector(launchOptionsMenu) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.optionsButton];
}
- (void)launchOptionsMenu
{
    OptionsViewController *ovc = [[OptionsViewController alloc] init];
    UINavigationController *optionsNavController = [[UINavigationController alloc] initWithRootViewController:ovc];
    [self.navigationController presentViewController:optionsNavController animated:YES completion:nil];
}

-(void) mapView:(GMSMapView *)mv didLongPressAtCoordinate:(CLLocationCoordinate2D)coord
{
    NSLog(@"A long press!");
    LocationController *locationController = [LocationController sharedLocationController];
    [locationController moveMarkerToLocation:coord];
}

@end

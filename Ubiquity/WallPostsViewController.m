//
//  WallPostsViewController.m
//  Ubiquity
//
//  Created by Catherine Morrison on 7/25/13.
//  Copyright (c) 2013 Team Ubi. All rights reserved.
//

static CGFloat const nameFontSize = 20.f;
static CGFloat const textFontSize = 15.f;
static CGFloat const dateFontSize = 12.f;

static CGFloat const cellWidth = 280.f; // subject to change.
static CGFloat const cellMaxImageHeight = 300.f; // subject to change.


// Cell dimension and positioning constants
static CGFloat const cellPaddingTop = 10.0f;
static CGFloat const cellPaddingBottom = 10.0f;
static CGFloat const cellPaddingSides = 10.0f;
static CGFloat const cellTextPaddingTop = 10.0f;
static CGFloat const cellTextPaddingBottom = 5.0f;
static CGFloat const cellTextPaddingSides = 10.0f;

static CGFloat const cellUsernameHeight = 15.0f;
static CGFloat const cellBGHeight = 32.0f;
static CGFloat const cellBGOffset = cellBGHeight - cellUsernameHeight;

// TableViewCell ContentView tags
static NSInteger cellBackgroundTag = 2;
static NSInteger cellTextLabelTag = 3;
static NSInteger cellNameLabelTag = 4;
static NSInteger cellSentDateLabelTag = 5;
static NSInteger cellReceivedDateLabelTag = 6;
static NSInteger cellLocationLabelTag = 7;
static NSInteger cellAttachedMediaTag = 8;

#import <MediaPlayer/MediaPlayer.h>
#import <Parse/Parse.h>

#import "AppDelegate.h"
#import "Reachability.h"
#import "TextMessage.h"

#import "HomeMapViewController.h"
#import "LocationController.h"
#import "NewMessageViewController.h"
#import "OptionsViewController.h"
#import "WallPostsViewController.h"

@interface WallPostsViewController ()
{
    CGFloat additionalPhotoHeight;
    CGFloat additionalPhotoWidth;
    BOOL photoAttachmentExists;
    PFObject *publicUserObj;
    RDPlayer* _player;
    BOOL _playing;
    BOOL _paused;
    NSMutableArray *_trackKeys;
    PFQuery *pushQuery;
    NSString *_trackKey;
    NSMutableDictionary *songsToCell;
}


@end

@implementation WallPostsViewController



- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
}

- (id)init
{
    self = [super init];
    if (self) {
        [self initButtons];
        [self initSegmentedControl];
        [self initOptionsButton];
       // [self initRdioButton];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(loadObjects)
                                                     name:KPAWInitialLocationFound
                                                   object:nil];
        PFQuery *query = [PFQuery queryWithClassName:@"UserData"];
        [query whereKey:@"facebookId" equalTo:[NSString stringWithFormat:@"100006434632076"]];
        [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            publicUserObj = object;
        }];
        _trackKeys = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)initSegmentedControl
{
    NSArray *itemArray = [NSArray arrayWithObjects: [UIImage imageNamed:@"me"], [UIImage imageNamed:@"friends"], [UIImage imageNamed:@"public"], nil];
    self.segmentedControl = [[UISegmentedControl alloc] initWithItems:itemArray];
    self.segmentedControl.frame = CGRectMake(0,0,150,35);
    self.segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
    [self.segmentedControl setSelectedSegmentIndex:0];
    [self.segmentedControl addTarget:self
                              action:@selector(changeSegment:)
                    forControlEvents:UIControlEventValueChanged];
    [[self navigationItem] setTitleView:self.segmentedControl];
}

- (void)initButtons
{
    UIBarButtonItem *mapList = [[UIBarButtonItem alloc] initWithTitle:@"< Map"
                                                                style:UIBarButtonItemStylePlain
                                                               target:self
                                                               action:@selector(launchMapView)];
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

- (void)launchMapView
{
    [self dismissViewControllerAnimated:YES completion:nil];
    LocationController *locController = [LocationController sharedLocationController];
    if ((locController.location.coordinate.latitude == 0) && (locController.location.coordinate.longitude == 0)) {
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Turn On Location Services to See Nearby Posts"
                                                          message:@"Please go to Settings -> Privacy -> Location Services to turn it on."
                                                         delegate:nil
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles:nil];
        [message show];
    }
}

- (void)launchNewMessage
{
    if ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == NotReachable) {
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Error: No Internet Connection"
                                                          message:@"Can't send messages when offline."
                                                         delegate:nil
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles:nil];
        [message show];
    } else {
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
}

- (void)initOptionsButton
{
    int const SCREEN_WIDTH = self.view.frame.size.width;
    int const SCREEN_HEIGHT = self.view.frame.size.height;
    self.optionsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *pictureButtonImage = [UIImage imageNamed:@"gear.png"];
    [self.optionsButton setBackgroundImage:pictureButtonImage forState:UIControlStateNormal];
    self.optionsButton.frame = CGRectMake(SCREEN_WIDTH - 25, SCREEN_HEIGHT - 70, 20.0, 20.0);
    [self.optionsButton addTarget:self action:@selector(launchOptionsMenu) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.optionsButton];
}

- (void)initRdioButton
{
    int const SCREEN_HEIGHT = self.view.frame.size.height;
    self.rdioButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *rdioButtonImage = [UIImage imageNamed:@"musicNote.png"];
    [self.rdioButton setBackgroundImage:rdioButtonImage forState:UIControlStateNormal];
    self.rdioButton.frame = CGRectMake(25, SCREEN_HEIGHT - 70, 20.0, 20.0);
    [self.rdioButton addTarget:self action:@selector(playMusic:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.rdioButton];
}

- (void)launchOptionsMenu
{
    OptionsViewController *ovc = [[OptionsViewController alloc] init];
    UINavigationController *optionsNavController = [[UINavigationController alloc] initWithRootViewController:ovc];
    [self.navigationController presentViewController:optionsNavController animated:YES completion:nil];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
		self.className = kPAWParsePostsClassKey;
    }
    return self;
}

- (id)initWithStyle:(UITableViewStyle)style {
	self = [super initWithStyle:style];
	if (self) {
		// Customize the table:
        
		// The className to query on
		self.parseClassName = kPAWParsePostsClassKey;
        
		// The key of the PFObject to display in the label of the default cell style
		self.textKey = kPAWParseTextKey;
        
        // Whether the built-in pull-to-refresh is enabled
        if (NSClassFromString(@"UIRefreshControl")) {
            self.pullToRefreshEnabled = NO;
        } else {
            self.pullToRefreshEnabled = YES;
        }
		
        [self.tableView setSeparatorColor: [UIColor clearColor]];
        [self.tableView setBackgroundColor: [UIColor lightGrayColor]];
        
		// Whether the built-in pagination is enabled
		self.paginationEnabled = YES;
        
		// The number of objects to show per page
		self.objectsPerPage = kPAWWallPostsSearch;
	}
	return self;
}

- (void)viewDidLoad
{
    // questionable whether i need to load the super viewdidload
    [super viewDidLoad];
    
    songsToCell = [[NSMutableDictionary alloc] init];
    
    if (NSClassFromString(@"UIRefreshControl")) {
        // Use the new iOS 6 refresh control.
        UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
        self.refreshControl = refreshControl;
        self.refreshControl.tintColor = [UIColor colorWithRed:118.0f/255.0f green:117.0f/255.0f blue:117.0f/255.0f alpha:1.0f];
        [self.refreshControl addTarget:self action:@selector(refreshControlValueChanged:) forControlEvents:UIControlEventValueChanged];
        self.pullToRefreshEnabled = YES;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(locationDidChange:)
                                                 name:kPAWLocationChangeNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(postWasCreated:) name:kPAWPostCreatedNotification object:nil];
	// Do any additional setup after loading the view.

    pushQuery = [PFInstallation query];
    [pushQuery whereKey:@"deviceType" equalTo:@"ios"];
    [pushQuery whereKey:@"owner" equalTo:[PFUser currentUser]];
    
}


- (void)viewDidUnload {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kPAWLocationChangeNotification
                                                  object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// table view controller stuff

- (void)changeSegment:(UISegmentedControl *)sender
{
    NSInteger value = [sender selectedSegmentIndex];
    if (value == 0) {
        _indexing = 0;
        NSLog(@"Changed value to 0");
        [self loadObjects];
    } else if (value == 1) {
        _indexing = 1;
        NSLog(@"Changed value to 1");
        [self loadObjects];
    } else if (value == 2) {
        _indexing = 2;
        NSLog(@"Changed value to 2");
        [self loadObjects];
    }
}

- (void)objectsDidLoad:(NSError *)error {
    [super objectsDidLoad:error];
    
    if (error) {
        NSLog(@"objectsDidLoad: Error: %@", error);
    }
    
    // This method is called every time objects are loaded from Parse via the PFQuery
    if (NSClassFromString(@"UIRefreshControl")) {
        [self.refreshControl endRefreshing];
    }
}

- (void)objectsWillLoad {
    [super objectsWillLoad];
    NSLog(@"objectsWillLoad");
    // This method is called before a PFh  is fired to get more objects
}

// Override to customize what kind of query to perform on the class. The default is  for
// all objects ordered by createdAt descending.
- (PFQuery *)queryForTable {
    
	PFQuery *query = [PFQuery queryWithClassName:self.parseClassName];
    
    NSLog(@"querying for table called");
	// If no objects are loaded in memory, we look to the cache first to fill the table
	// and then subsequently do a query against the network.
	if ([self.objects count] == 0) {
		query.cachePolicy = kPFCachePolicyCacheThenNetwork;
	}
    
	// Query for posts near our current location.
    
	// Get our current location:
	LocationController* locationController = [LocationController sharedLocationController];
    CLLocationCoordinate2D currentCoordinate = locationController.location.coordinate;
    
	CLLocationAccuracy filterDistance = locationController.locationManager.distanceFilter;
    
	// And set the query to look by location
	PFGeoPoint *point = [PFGeoPoint geoPointWithLatitude:currentCoordinate.latitude longitude:currentCoordinate.longitude];
	[query whereKey:kPAWParseLocationKey nearGeoPoint:point withinKilometers:filterDistance / kPAWMetersInAKilometer];
    [query includeKey:kPAWParseSenderKey];
    [query includeKey:@"readReceiptsArray"];
    [query orderByDescending:@"createdAt"];
    
    if (self.indexing == 0) {
        NSLog(@"Only shows notes from self");
        [query whereKey:@"sender" equalTo:[[PFUser currentUser] objectForKey:@"userData"]];
        [query whereKey:@"receivers" equalTo:[[PFUser currentUser] objectForKey:@"userData"]];
    } else if (self.indexing == 1) {
        NSLog(@"Shows notes from friends");
        [query whereKey:@"receivers" equalTo:[[PFUser currentUser] objectForKey:@"userData"]];
        [query whereKey:@"sender" notEqualTo:[[PFUser currentUser] objectForKey:@"userData"]];
    } else if (self.indexing == 2) {
        NSLog(@"Shows public notes");
        [query whereKey:@"receivers" equalTo:publicUserObj];
    }
    
	return query;
}

// Override to customize the look of a cell representing an object. The default is to display
// a UITableViewCellStyleDefault style cell with the label being the first key in the object.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
    
	// Reuse identifiers for left and right cells
	static NSString *CellIdentifier = @"Cell";
    
	// Try to reuse a cell
	UITableViewCell *cell;
    cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        
        UIImageView *backgroundImage = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"PostBackground"] resizableImageWithCapInsets:UIEdgeInsetsMake(10.0f, 100.0f, 10.0f, 100.0f)]];
        [backgroundImage setTag:cellBackgroundTag];
        [cell.contentView addSubview:backgroundImage];
        
        UILabel *nameLabel = [[UILabel alloc] init];
        [nameLabel setTag:cellNameLabelTag];
        [cell.contentView addSubview:nameLabel];
        
        UILabel *textLabel = [[UILabel alloc] init];
        [textLabel setTag:cellTextLabelTag];
        [cell.contentView addSubview:textLabel];
        
        UILabel *sentDate = [[UILabel alloc] init];
        [sentDate setTag:cellSentDateLabelTag];
        [cell.contentView addSubview:sentDate];
        
        UILabel *receivedDate = [[UILabel alloc] init];
        [receivedDate setTag: cellReceivedDateLabelTag];
        [cell.contentView addSubview:receivedDate];
        
        UILabel *locationLabel = [[UILabel alloc] init];
        [locationLabel setTag: cellLocationLabelTag];
        [cell.contentView addSubview:locationLabel];
        
        UIView *mediaView = [[UIView alloc] init];
        [mediaView setTag: cellAttachedMediaTag];
        [cell.contentView addSubview:mediaView];

    }
    
    // so we don't get floating music buttons in random places they shouldn't be
    for (id subview in [cell.contentView subviews])
    {
        if ([subview  isKindOfClass:[UIButton class]])
            [subview removeFromSuperview];
    }
    
    
	// Configure the cell content
    
	UILabel *textLabel = (UILabel*) [cell.contentView viewWithTag:cellTextLabelTag];
	textLabel.text = [object objectForKey:kPAWParseTextKey];
	textLabel.lineBreakMode = NSLineBreakByWordWrapping;
	textLabel.numberOfLines = 0;
	textLabel.font = [UIFont systemFontOfSize:textFontSize];
	textLabel.backgroundColor = [UIColor clearColor];
    
    
	UILabel *locationLabel = (UILabel *) [cell.contentView viewWithTag:cellLocationLabelTag];
    locationLabel.text = @"Unknown Location";
    locationLabel.font = [UIFont systemFontOfSize:textFontSize];
    locationLabel.backgroundColor = [UIColor clearColor];
    
    locationLabel.text = [object objectForKey:@"locationAddress"];
    
    UILabel *sentDate = (UILabel *) [cell.contentView viewWithTag:cellSentDateLabelTag];
    NSDate *sentAt = object.createdAt;
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"hh:mm a 'on' dd MMMM yyyy"];
    NSString *sentAtString = [df stringFromDate:sentAt];
    sentDate.text = [NSString stringWithFormat: @"Sent at: %@", sentAtString];
    sentDate.font = [UIFont systemFontOfSize:dateFontSize];
    
    UILabel *receivedDate = (UILabel *) [cell.contentView viewWithTag:cellReceivedDateLabelTag];
    NSString *facebookId = [[[PFUser currentUser] objectForKey:@"userData"] objectForKey:@"facebookId"];
    NSArray *rrArray = [object objectForKey:@"readReceiptsArray"];
    
    PFObject *rr = nil;
    NSDate *receivedAt = nil;
    
    for(PFObject *r in rrArray) {
        if([[r objectForKey:@"receiver"] isEqualToString:facebookId]) {
            NSLog(@"%@", r);
            receivedAt = [r objectForKey:@"dateOpened"];
            rr = r;
        }
    }
    
    if(receivedAt == nil) {
        receivedAt = [NSDate date];
        [rr setObject:receivedAt forKey:@"dateOpened"];
        [rr saveInBackground];
    }
    
    
    NSString *gotAtString = [df stringFromDate:receivedAt];
    receivedDate.text = [NSString stringWithFormat: @"Read at: %@", gotAtString];
    receivedDate.font = [UIFont systemFontOfSize:dateFontSize];

    
	NSString *username = [NSString stringWithFormat:@"%@",[[object objectForKey:kPAWParseSenderKey] objectForKey:@"profile"][@"name"]];
	UILabel *nameLabel = (UILabel*) [cell.contentView viewWithTag:cellNameLabelTag];
	nameLabel.text = username;
	nameLabel.font = [UIFont systemFontOfSize:nameFontSize];
	nameLabel.backgroundColor = [UIColor clearColor];
    nameLabel.textColor = [UIColor blackColor];
    nameLabel.shadowColor = [UIColor colorWithRed:0.9f green:0.9f blue:0.9f alpha:0.35f];
    nameLabel.shadowOffset = CGSizeMake(0.0f, 0.5f);
	
	UIImageView *backgroundImage = (UIImageView*) [cell.contentView viewWithTag:cellBackgroundTag];
	
	// Move cell content to the right position
	// Calculate the size of the post's text and username
	CGSize textSize = [[object objectForKey:kPAWParseTextKey] sizeWithFont:[UIFont systemFontOfSize:textFontSize] constrainedToSize:CGSizeMake(cellWidth, FLT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
	CGSize nameSize = [username sizeWithFont:[UIFont systemFontOfSize:nameFontSize] forWidth:cellWidth lineBreakMode:NSLineBreakByTruncatingTail];
    
    CGSize sentDateSize = [sentDate.text sizeWithFont:[UIFont systemFontOfSize:nameFontSize] forWidth:cellWidth lineBreakMode:NSLineBreakByTruncatingTail];
    
    CGSize receivedDateSize = [receivedDate.text sizeWithFont:[UIFont systemFontOfSize:nameFontSize] forWidth:cellWidth lineBreakMode:NSLineBreakByTruncatingTail];
    
    CGSize locationLabelSize = [locationLabel.text sizeWithFont:[UIFont systemFontOfSize:nameFontSize] forWidth:cellWidth lineBreakMode:NSLineBreakByTruncatingTail];
    
    
    
	CGFloat cellHeight = [self tableView:tableView heightForRowAtIndexPath:indexPath] + cellTextPaddingTop ; // Get the height of the cell
	
	// Place the content in the correct position depending on the type
    
    [nameLabel setFrame:CGRectMake(cellPaddingSides+cellTextPaddingSides,
                                   
                                   cellPaddingTop+cellTextPaddingTop,
                                   nameSize.width,
                                   nameSize.height)];
    
    
    [locationLabel setFrame:CGRectMake(cellPaddingSides+cellTextPaddingSides,
                                       cellPaddingTop+cellTextPaddingTop*3,
                                       locationLabelSize.width,
                                       locationLabelSize.height)];
    
    [sentDate setFrame:CGRectMake(cellPaddingSides+cellTextPaddingSides,
                                  cellPaddingTop+cellTextPaddingTop*5,
                                  sentDateSize.width,
                                  sentDateSize.height)];
    [receivedDate setFrame:CGRectMake(cellPaddingSides+cellTextPaddingSides, cellPaddingTop+cellTextPaddingTop * 12+ textSize.height + additionalPhotoHeight,
                                      receivedDateSize.width,
                                      receivedDateSize.height)];
    
    [textLabel setFrame:CGRectMake(cellPaddingSides+cellTextPaddingSides,
                                   cellPaddingTop+cellTextPaddingTop*9,
                                   textSize.width,
                                   textSize.height)];
    

    
    
    UIView *mediaView = [cell.contentView viewWithTag:cellAttachedMediaTag];
    additionalPhotoWidth = self.tableView.frame.size.width * 4/7;
    CGRect mediaFrame = CGRectMake(self.tableView.frame.size.width/2 - additionalPhotoWidth/2,
                              cellPaddingTop+cellTextPaddingTop*11+textSize.height,
                              additionalPhotoWidth,
                               additionalPhotoHeight);
    
    if([object objectForKey:@"mediaHeight"] > 0) {
        mediaView.contentMode = UIViewContentModeScaleAspectFill;
        [[object objectForKey:@"media"] getDataInBackgroundWithBlock:^(NSData *mediaData, NSError *error) {
            UIImage *photo = [[UIImage alloc] initWithData:mediaData];
            if (photo) {
                mediaView.contentMode = UIViewContentModeScaleAspectFill;
                UIImageView *photoView = [[UIImageView alloc] initWithImage:photo];
                [photoView setFrame:CGRectMake(0.0, 0.0, additionalPhotoWidth, additionalPhotoHeight)];
                [mediaView addSubview:photoView];
            } else { //photo will be null if mediaData is not valid image data, so movie
                NSLog(@"look this post has a movie :O");
                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                NSString *documentsDirectory = [paths objectAtIndex:0];
                NSString *path = [documentsDirectory stringByAppendingPathComponent:@"postVideo.m4v"];
                [mediaData writeToFile:path atomically:YES];
                NSURL *videoURL = [NSURL fileURLWithPath:path];
                MPMoviePlayerController *player = [[MPMoviePlayerController alloc] init];
                [player setContentURL:videoURL];
                [player prepareToPlay];
                [player.view setFrame:CGRectMake(0.0, 0.0, additionalPhotoWidth, additionalPhotoHeight)];
                [mediaView addSubview:player.view];
                [player play];
            }
            
        }];
    } else {
        //REMOVE OLD BAD VIEWS STILL ATTACHED
        
        [mediaView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    }
    
    [mediaView setFrame:mediaFrame];
    
    [backgroundImage setFrame:CGRectMake(cellPaddingSides,
                                         cellPaddingTop,
                                         self.tableView.frame.size.width - cellPaddingSides*2,
                                         cellHeight-cellPaddingTop-cellPaddingBottom)];
    
    
    UIButton *musicButton = [UIButton buttonWithType:UIButtonTypeCustom];


    if ([object objectForKey:@"trackKey"]) {
        
        [songsToCell setObject: [object objectForKey:@"trackKey"] forKey: indexPath];

        UIImage *musicNote = [UIImage imageNamed:@"musicNote"];
        [musicButton setBackgroundImage:musicNote forState:UIControlStateNormal];
        [cell.contentView addSubview: musicButton];
        
        [musicButton addTarget:self action:@selector (playMusic:) forControlEvents:UIControlEventTouchUpInside];
        musicButton.frame = CGRectMake(self.tableView.frame.size.width - cellPaddingSides - cellTextPaddingSides*3, cellHeight + additionalPhotoHeight - cellPaddingBottom - cellTextPaddingBottom*5, 20.0, 20.0);

    }
    

    
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForNextPageAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [super tableView:tableView cellForNextPageAtIndexPath:indexPath];
	cell.textLabel.font = [cell.textLabel.font fontWithSize:textFontSize];
	return cell;
}


#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	// call super because we're a custom subclass.
	[super tableView:tableView didSelectRowAtIndexPath:indexPath];
    
    //Flips cell on touch
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    [UIView beginAnimations:@"FlipCellAnimation" context:nil];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:cell cache:YES];
    [cell removeFromSuperview];
    [self.tableView addSubview:cell];
    [UIView commitAnimations];
    
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

//-(IBAction)btnInfoTapped:(id)sender{
//    CGContextRef context = UIGraphicsGetCurrentContext();
//    [UIView beginAnimations:nil context:context];
//    [UIView setAnimationTransition: UIViewAnimationTransitionFlipFromLeft forView:viewMain cache:YES];
//    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
//    [UIView setAnimationDuration:1.0];
//    [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(hideMainView) userInfo:nil repeats:NO];
//    [UIView commitAnimations];
//}
//-(void)hideMainView{
//    [viewMain addSubview:viewInfo];
//}
//
//-(IBAction)btnBack:(id)sender{
//    CGContextRef context = UIGraphicsGetCurrentContext();
//    [UIView beginAnimations:nil context:context];
//    [UIView setAnimationTransition: UIViewAnimationTransitionFlipFromRight forView:viewMain cache:YES];
//    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
//    [UIView setAnimationDuration:1.0];
//    [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(hideInfoView) userInfo:nil repeats:NO];
//    [UIView commitAnimations];
//}
//
//-(void)hideInfoView {
//    [viewInfo removeFromSuperview];
//}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	// Account for the load more cell at the bottom of the tableview if we hit the pagination limit:
	if ( (NSUInteger)indexPath.row >= [self.objects count]) {
		return [tableView rowHeight];
	}
    
	// Retrieve the text and username for this row:
	PFObject *object = [self.objects objectAtIndex:indexPath.row];
	TextMessage *postFromObject = [[TextMessage alloc] initWithPFObject:object];
	NSString *text = postFromObject.title;
    //NSLog(@"%@", [postFromObject.sender objectForKey:@"profile"]);
	NSString *username = [postFromObject.sender objectForKey:@"profile"][@"name"];
	
	// Calculate what the frame to fit the post text and the username
	CGSize textSize = [text sizeWithFont:[UIFont systemFontOfSize:textFontSize] constrainedToSize:CGSizeMake(cellWidth, FLT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
	CGSize nameSize = [username sizeWithFont:[UIFont systemFontOfSize:nameFontSize] forWidth:cellWidth lineBreakMode:NSLineBreakByTruncatingTail];
    
	// And return this height plus cell padding and the offset of the bubble image height (without taking into account the text height twice)
    
    additionalPhotoHeight = [[object objectForKey:@"mediaHeight"] floatValue];
    
    if (additionalPhotoHeight > 0)
        photoAttachmentExists = true;
    else
    {
        photoAttachmentExists = false;
        additionalPhotoHeight = 0;
    }
    
	CGFloat rowHeight = cellPaddingTop + textSize.height + nameSize.height * 5 + cellBGOffset + cellPaddingTop + additionalPhotoHeight;
    
	return rowHeight;
}


- (void)distanceFilterDidChange:(NSNotification *)note {
	[self loadObjects];
}

- (void)locationDidChange:(NSNotification *)note {
	[self loadObjects];
}

- (void)postWasCreated:(NSNotification *)note {
	[self loadObjects];
}

- (void)refreshControlValueChanged:(UIRefreshControl *)refreshControl {
    [self loadObjects];
}

- (void)loadObjects {
    if([PFUser currentUser] != nil) {
        [super loadObjects];
    }
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if([PFUser currentUser] != nil) {
        [self loadObjects];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    CGRect frame = self.optionsButton.frame;
    frame.origin.y = scrollView.contentOffset.y + self.tableView.frame.size.height + self.navigationController.navigationBar.frame.size.height - 70;
    self.optionsButton.frame = frame;
    
    [self.view bringSubviewToFront:self.optionsButton];
}

//rdio player
- (BOOL)rdioIsPlayingElsewhere
{
    return NO;
}
- (void)rdioPlayerChangedFromState:(RDPlayerState)fromState toState:(RDPlayerState)state
{
    _playing = (state != RDPlayerStateInitializing && state != RDPlayerStateStopped);
    _paused = (state == RDPlayerStatePaused);
}
- (RDPlayer*)getPlayer
{
    if (_player == nil) {
        _player = [AppDelegate rdioInstance].player;
    }
    return _player;
}
- (void)playMusic: (id) sender
{
    UIView *contentView = [sender superview];
    UITableViewCell *cell = (UITableViewCell *)[contentView superview];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    _trackKey = [songsToCell objectForKey:indexPath];
    
    if (!_playing){
        [[self getPlayer] playSource: _trackKey];
        [sender setImage: [UIImage imageNamed:@"musicNoteRed"] forState:UIControlStateNormal];

    }
    else{
        [sender setImage: [UIImage imageNamed:@"musicNote"] forState:UIControlStateNormal];

    
        [[self getPlayer] togglePause];
    }
    
}


@end

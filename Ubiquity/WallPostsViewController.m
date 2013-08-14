//
//  WallPostsViewController.m
//  Ubiquity
//
//  Created by Catherine Morrison on 7/25/13.
//  Copyright (c) 2013 Team Ubi. All rights reserved.
//

static CGFloat const kPAWWallPostTableViewFontSizeName = 20.f;
static CGFloat const kPAWWallPostTableViewFontSizeText = 15.f;
static CGFloat const kPawWallPostTableViewFontSizeDate = 12.f;

static CGFloat const kPAWWallPostTableViewCellWidth = 280.f; // subject to change.
static CGFloat const kPAWCellMaxImageHeight = 300.f; // subject to change.



// Cell dimension and positioning constants
static CGFloat const kPAWCellPaddingTop = 10.0f;
static CGFloat const kPAWCellPaddingBottom = 10.0f;
static CGFloat const kPAWCellPaddingSides = 10.0f;
static CGFloat const kPAWCellTextPaddingTop = 10.0f;
static CGFloat const kPAWCellTextPaddingBottom = 5.0f;
static CGFloat const kPAWCellTextPaddingSides = 10.0f;

static CGFloat const kPAWCellUsernameHeight = 15.0f;
static CGFloat const kPAWCellBkgdHeight = 32.0f;
static CGFloat const kPAWCellBkgdOffset = kPAWCellBkgdHeight - kPAWCellUsernameHeight;

// TableViewCell ContentView tags
static NSInteger kPAWCellBackgroundTag = 2;
static NSInteger kPAWCellTextLabelTag = 3;
static NSInteger kPAWCellNameLabelTag = 4;
static NSInteger kPAWCellSentDateLabelTag = 5;
static NSInteger kPAWCellReceivedDateLabelTag = 6;
static NSInteger kPAWCellLocationLabelTag = 7;
static NSInteger kPAWCellAttachedPhotoTag = 8;


#import "HomeMapViewController.h"
#import "WallPostsViewController.h"
#import "AppDelegate.h"
#import "TextMessage.h"
#import "LocationController.h"
#import "FriendsViewController.h"
#import "NewMessageViewController.h"
#import "OptionsViewController.h"

@interface WallPostsViewController ()
{
    CGFloat additionalPhotoHeight;
    CGFloat additionalPhotoWidth;
    BOOL photoAttachmentExists;
    PFObject *publicUserObj;
}

@property (nonatomic, strong) FriendsViewController *friendsViewController;

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
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(loadObjects)
                                                     name:KPAWInitialLocationFound
                                                   object:nil];

        PFQuery *query = [PFQuery queryWithClassName:@"UserData"];
        [query whereKey:@"facebookId" equalTo:[NSString stringWithFormat:@"100006434632076"]];
        [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            publicUserObj = object;
        }];
        
        
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


- (void)initButtons
{
    UIBarButtonItem *mapList = [[UIBarButtonItem alloc] initWithTitle:@"Map"
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
    HomeMapViewController *hmvc = [[HomeMapViewController alloc] init];
    UINavigationController *mapNavController = [[UINavigationController alloc]
                                                      initWithRootViewController:hmvc];
    [self.navigationController presentViewController:mapNavController animated:NO completion:nil];
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
    UIImage *pictureButtonImage = [UIImage imageNamed:@"gear.png"];
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
    
    if (NSClassFromString(@"UIRefreshControl")) {
        // Use the new iOS 6 refresh control.
        UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
        self.refreshControl = refreshControl;
        self.refreshControl.tintColor = [UIColor colorWithRed:118.0f/255.0f green:117.0f/255.0f blue:117.0f/255.0f alpha:1.0f];
        [self.refreshControl addTarget:self action:@selector(refreshControlValueChanged:) forControlEvents:UIControlEventValueChanged];
        self.pullToRefreshEnabled = NO;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(locationDidChange:)
                                                 name:kPAWLocationChangeNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(postWasCreated:) name:kPAWPostCreatedNotification object:nil];
	// Do any additional setup after loading the view.
    
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
    // This method is called before a PFQuery is fired to get more objects
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
    [query orderByDescending:@"createdAt"];
    
    if (self.indexing == 0) {
        NSLog(@"Only shows notes from self");
        [query whereKey:@"sender" equalTo:[[PFUser currentUser] objectForKey:@"userData"]];
        [query whereKey:@"receivers" equalTo:[[PFUser currentUser] objectForKey:@"userData"]];
    } else if (self.indexing == 1) {
        NSLog(@"Shows notes from friends");
        [query whereKey:@"receivers" equalTo:[[PFUser currentUser] objectForKey:@"userData"]];
    } else if (self.indexing == 2) {
        NSLog(@"Shows public notes");
        [query whereKey:@"receivers" equalTo:publicUserObj];
    }
    
    [self pushNotifications];
    
	return query;
}

- (void)pushNotifications {
    PFQuery *queryUserDate = [PFQuery queryWithClassName:@"Posts"];
    
	// Get our current location:
	LocationController* locationController = [LocationController sharedLocationController];
    CLLocationCoordinate2D currentCoordinate = locationController.location.coordinate;
    
	CLLocationAccuracy filterDistance = locationController.locationManager.distanceFilter;
    
	// And set the query to look by location
	PFGeoPoint *point = [PFGeoPoint geoPointWithLatitude:currentCoordinate.latitude longitude:currentCoordinate.longitude];
	[queryUserDate whereKey:kPAWParseLocationKey nearGeoPoint:point withinKilometers:filterDistance / kPAWMetersInAKilometer];
    [queryUserDate includeKey:kPAWParseSenderKey];
    [queryUserDate orderByDescending:@"createdAt"];
    [queryUserDate whereKey:@"receivers" equalTo:[[PFUser currentUser] objectForKey:@"userData"]];
    [queryUserDate findObjectsInBackgroundWithBlock:^(NSArray *posts, NSError *error) {
        if (!error) {   // The find succeeded.
            if ([posts count] > 0) {      //Saved friend list exists
                NSLog(@"Seeing if new push notifications");
                //NSMutableArray *postsToNotify = [[NSMutableArray alloc] initWithCapacity:[posts count]];
                
                PFQuery *pushQuery = [PFInstallation query];
                [pushQuery whereKey:@"deviceType" equalTo:@"ios"];
                [pushQuery whereKey:@"owner" equalTo:[PFUser currentUser]];
                
                for (PFObject *post in posts) {
                    NSArray *receiptsArray = [post objectForKey:@"readReceiptsArray"];
                    for (PFObject *receipt in receiptsArray) {
                        [receipt fetchIfNeeded];
                       // [receipt fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error){
                            if ([[receipt objectForKey:@"receiver"] isEqualToString:[[PFUser currentUser] objectForKey:@"fbId"]]) {
                                if ([[receipt objectForKey:@"updatedAt"] isEqualToDate:[receipt createdAt]]) {
                                    //[postsToNotify addObject:post];
                                    
                                    PFObject *senderInfo = [post objectForKey:@"sender"];
                                    PFObject *profile = [senderInfo objectForKey:@"profile"];
                                    NSString *sender = [NSString stringWithFormat:@"%@",[profile objectForKey:@"name"]];
                                    NSString *pushMessage = [NSString stringWithFormat:@"Received a message from %@", sender];
                                    NSLog(@"the object id of the post is %@", [post objectForKey:@"text"]);
                                    // Send push notification to query
                                    [PFPush sendPushMessageToQueryInBackground:pushQuery
                                                                   withMessage:pushMessage];
                                    
                                    
                                    [receipt setObject:[NSDate date] forKey:@"dateOpened"];
                                    [receipt saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                                        NSLog(@"saving read receipts error: %@", error);
                                    }];
                                }
                            };
                       // }];
                    }
                }
                

                
                // NEED TO IMPLEMENT SENDING TO SPECIFIC PHONES
                
//                if ([postsToNotify count] > 0) {
//                    NSLog(@"new push notifications!");
//                    for (PFObject *obj in postsToNotify) {
//                        PFObject *senderInfo = [obj objectForKey:@"sender"];
//                        PFObject *profile = [senderInfo objectForKey:@"profile"];
//                        NSString *sender = [NSString stringWithFormat:@"%@",[profile objectForKey:@"name"]];
//                        NSString *pushMessage = [NSString stringWithFormat:@"Received a message from %@", sender];
//                        NSLog(@"the object id of the post is %@", [obj objectForKey:@"text"]);
//                        // Send push notification to query
//                        [PFPush sendPushMessageToQueryInBackground:pushQuery
//                                                       withMessage:pushMessage];
//                    }
//                } else {
//                    NSLog(@"no new push notifications");
//                }
//                
//                [postsToNotify removeAllObjects];
            } else {
                // Log details of the failure
               // NSLog(@"Error in push notifications: %@", error);
            }
        }
    }];
}

// Override to customize the look of a cell representing an object. The default is to display
// a UITableViewCellStyleDefault style cell with the label being the first key in the object.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
    
	// Reuse identifiers for left and right cells
	static NSString *LeftCellIdentifier = @"LeftCell";
    
	// Try to reuse a cell
	BOOL cellIsRight = [[[object objectForKey:kPAWParseSenderKey] objectForKey:kPAWParseUsernameKey] isEqualToString:[[PFUser currentUser] objectForKey:@"username"]];
    
	UITableViewCell *cell;
    cell = [tableView dequeueReusableCellWithIdentifier:LeftCellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:LeftCellIdentifier];
        
        UIImageView *backgroundImage = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"PostBackground"] resizableImageWithCapInsets:UIEdgeInsetsMake(10.0f, 100.0f, 10.0f, 100.0f)]];
        [backgroundImage setTag:kPAWCellBackgroundTag];
        [cell.contentView addSubview:backgroundImage];
        
        
        UILabel *nameLabel = [[UILabel alloc] init];
        [nameLabel setTag:kPAWCellNameLabelTag];
        [cell.contentView addSubview:nameLabel];
        
        UILabel *textLabel = [[UILabel alloc] init];
        [textLabel setTag:kPAWCellTextLabelTag];
        [cell.contentView addSubview:textLabel];
        
        UILabel *sentDate = [[UILabel alloc] init];
        [sentDate setTag:kPAWCellSentDateLabelTag];
        [cell.contentView addSubview:sentDate];
        
        UILabel *receivedDate = [[UILabel alloc] init];
        [receivedDate setTag: kPAWCellReceivedDateLabelTag];
        [cell.contentView addSubview:receivedDate];
        
        UILabel *locationLabel = [[UILabel alloc] init];
        [locationLabel setTag: kPAWCellLocationLabelTag];
        [cell.contentView addSubview:locationLabel];
        
        UIImageView *photoView = [[UIImageView alloc] init];
        [photoView setTag: kPAWCellAttachedPhotoTag];
        [cell.contentView addSubview:photoView];
        
    }
    
    
	
	// Configure the cell content
    
    
	UILabel *textLabel = (UILabel*) [cell.contentView viewWithTag:kPAWCellTextLabelTag];
	textLabel.text = [object objectForKey:kPAWParseTextKey];
	textLabel.lineBreakMode = NSLineBreakByWordWrapping;
	textLabel.numberOfLines = 0;
	textLabel.font = [UIFont systemFontOfSize:kPAWWallPostTableViewFontSizeText];
	textLabel.backgroundColor = [UIColor clearColor];
    
    
	UILabel *locationLabel = (UILabel *) [cell.contentView viewWithTag:kPAWCellLocationLabelTag];
    locationLabel.text = @"Unknown Location";
    locationLabel.font = [UIFont systemFontOfSize:kPAWWallPostTableViewFontSizeText];
    locationLabel.backgroundColor = [UIColor clearColor];
    
    locationLabel.text = [object objectForKey:@"locationAddress"];
    
    UILabel *sentDate = (UILabel *) [cell.contentView viewWithTag:kPAWCellSentDateLabelTag];
    NSDate *sentAt = object.createdAt;
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"hh:mm a 'on' dd MMMM yyyy"];
    NSString *sentAtString = [df stringFromDate:sentAt];
    sentDate.text = [NSString stringWithFormat: @"Sent at: %@", sentAtString];
    sentDate.font = [UIFont systemFontOfSize:kPawWallPostTableViewFontSizeDate];
    
    UILabel *receivedDate = (UILabel *) [cell.contentView viewWithTag:kPAWCellReceivedDateLabelTag];
    receivedDate.text = @"Received at: 6:05am Friday 28 July 2013";
    receivedDate.font = [UIFont systemFontOfSize:kPawWallPostTableViewFontSizeDate];
    
	NSString *username = [NSString stringWithFormat:@"%@",[[object objectForKey:kPAWParseSenderKey] objectForKey:@"profile"][@"name"]];
	UILabel *nameLabel = (UILabel*) [cell.contentView viewWithTag:kPAWCellNameLabelTag];
	nameLabel.text = username;
	nameLabel.font = [UIFont systemFontOfSize:kPAWWallPostTableViewFontSizeName];
	nameLabel.backgroundColor = [UIColor clearColor];
	if (cellIsRight) {
		nameLabel.textColor = [UIColor colorWithRed:175.0f/255.0f green:172.0f/255.0f blue:172.0f/255.0f alpha:1.0f];
		nameLabel.shadowColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.35f];
		nameLabel.shadowOffset = CGSizeMake(0.0f, 0.5f);
	} else {
		nameLabel.textColor = [UIColor blackColor];
		nameLabel.shadowColor = [UIColor colorWithRed:0.9f green:0.9f blue:0.9f alpha:0.35f];
		nameLabel.shadowOffset = CGSizeMake(0.0f, 0.5f);
	}
	
	UIImageView *backgroundImage = (UIImageView*) [cell.contentView viewWithTag:kPAWCellBackgroundTag];
	
	// Move cell content to the right position
	// Calculate the size of the post's text and username
	CGSize textSize = [[object objectForKey:kPAWParseTextKey] sizeWithFont:[UIFont systemFontOfSize:kPAWWallPostTableViewFontSizeText] constrainedToSize:CGSizeMake(kPAWWallPostTableViewCellWidth, FLT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
	CGSize nameSize = [username sizeWithFont:[UIFont systemFontOfSize:kPAWWallPostTableViewFontSizeName] forWidth:kPAWWallPostTableViewCellWidth lineBreakMode:NSLineBreakByTruncatingTail];
    
    CGSize sentDateSize = [sentDate.text sizeWithFont:[UIFont systemFontOfSize:kPAWWallPostTableViewFontSizeName] forWidth:kPAWWallPostTableViewCellWidth lineBreakMode:NSLineBreakByTruncatingTail];
    
    CGSize receivedDateSize = [receivedDate.text sizeWithFont:[UIFont systemFontOfSize:kPAWWallPostTableViewFontSizeName] forWidth:kPAWWallPostTableViewCellWidth lineBreakMode:NSLineBreakByTruncatingTail];
    
    CGSize locationLabelSize = [locationLabel.text sizeWithFont:[UIFont systemFontOfSize:kPAWWallPostTableViewFontSizeName] forWidth:kPAWWallPostTableViewCellWidth lineBreakMode:NSLineBreakByTruncatingTail];
    
    
    
	
	CGFloat cellHeight = [self tableView:tableView heightForRowAtIndexPath:indexPath] + kPAWCellTextPaddingTop ; // Get the height of the cell
	
	// Place the content in the correct position depending on the type
    
    [nameLabel setFrame:CGRectMake(kPAWCellPaddingSides+kPAWCellTextPaddingSides,
                                   
                                   kPAWCellPaddingTop+kPAWCellTextPaddingTop,
                                   nameSize.width,
                                   nameSize.height)];
    
    
    [locationLabel setFrame:CGRectMake(kPAWCellPaddingSides+kPAWCellTextPaddingSides,
                                       kPAWCellPaddingTop+kPAWCellTextPaddingTop*3,
                                       locationLabelSize.width,
                                       locationLabelSize.height)];
    
    [sentDate setFrame:CGRectMake(kPAWCellPaddingSides+kPAWCellTextPaddingSides,
                                  kPAWCellPaddingTop+kPAWCellTextPaddingTop*5,
                                  sentDateSize.width,
                                  sentDateSize.height)];
    [receivedDate setFrame:CGRectMake(kPAWCellPaddingSides+kPAWCellTextPaddingSides, kPAWCellPaddingTop+kPAWCellTextPaddingTop * 12+ textSize.height + additionalPhotoHeight,
                                      receivedDateSize.width,
                                      receivedDateSize.height)];
    
    [textLabel setFrame:CGRectMake(kPAWCellPaddingSides+kPAWCellTextPaddingSides,
                                   kPAWCellPaddingTop+kPAWCellTextPaddingTop*9,
                                   textSize.width,
                                   textSize.height)];
    
    UIImageView *photoView = (UIImageView *) [cell.contentView viewWithTag:kPAWCellAttachedPhotoTag];

    if([object objectForKey:@"photoHeight"] > 0) {
        [[object objectForKey:@"photo"] getDataInBackgroundWithBlock:^(NSData *photoData, NSError *error) {
            UIImage *photo = [[UIImage alloc] initWithData:photoData];
            photoView.contentMode = UIViewContentModeScaleAspectFill;
            additionalPhotoWidth = self.tableView.frame.size.width * 4/7;
            [photoView setImage:photo];
        }];
    }
    
    
    [photoView setFrame:CGRectMake(self.tableView.frame.size.width/2 - additionalPhotoWidth/2,
                                   kPAWCellPaddingTop+kPAWCellTextPaddingTop*11+textSize.height,
                                   additionalPhotoWidth,
                                   additionalPhotoHeight)];
    
    
    
    [backgroundImage setFrame:CGRectMake(kPAWCellPaddingSides,
                                         kPAWCellPaddingTop,
                                         self.tableView.frame.size.width - kPAWCellPaddingSides*2,
                                         cellHeight-kPAWCellPaddingTop-kPAWCellPaddingBottom)];
    
    
    
    
    
    
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForNextPageAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [super tableView:tableView cellForNextPageAtIndexPath:indexPath];
	cell.textLabel.font = [cell.textLabel.font fontWithSize:kPAWWallPostTableViewFontSizeText];
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
	CGSize textSize = [text sizeWithFont:[UIFont systemFontOfSize:kPAWWallPostTableViewFontSizeText] constrainedToSize:CGSizeMake(kPAWWallPostTableViewCellWidth, FLT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
	CGSize nameSize = [username sizeWithFont:[UIFont systemFontOfSize:kPAWWallPostTableViewFontSizeName] forWidth:kPAWWallPostTableViewCellWidth lineBreakMode:NSLineBreakByTruncatingTail];
    
	// And return this height plus cell padding and the offset of the bubble image height (without taking into account the text height twice)
    
    additionalPhotoHeight = [[object objectForKey:@"photoHeight"] floatValue];
    
    if (additionalPhotoHeight > 0)
        photoAttachmentExists = true;
    else
    {
        photoAttachmentExists = false;
        additionalPhotoHeight = 0;
    }
    
	CGFloat rowHeight = kPAWCellPaddingTop + textSize.height + nameSize.height * 5 + kPAWCellBkgdOffset + kPAWCellPaddingTop + additionalPhotoHeight;
    
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

@end

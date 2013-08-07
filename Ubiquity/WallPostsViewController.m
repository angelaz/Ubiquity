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


#import "WallPostsViewController.h"
#import "AppDelegate.h"
#import "TextMessage.h"
#import "LocationController.h"
#import "FriendsViewController.h"

@interface WallPostsViewController ()


@property (nonatomic, strong) FriendsViewController *friendsViewController;

@end

@implementation WallPostsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
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
    
    if (self.indexing == 0) {
        
        // THIS IS WHERE WE NEED TO IMPLEMENT JUST FRIENDS SHOWING UP!!!!!
        
        NSLog(@"Order was changed to just friends (actually just text alphabetical)");

        [query orderByDescending:@"createdAt"];
    } else
    if (self.indexing == 1) {
        [query orderByDescending:@"createdAt"];
        NSLog(@"Order was changed to date");
    } else if (self.indexing == 2) {
        
        // THIS IS WHERE WE NEED TO IMPLEMENT FAVORITES SHOWING UP!!!!!
        
        [query orderByDescending:@"updatedAt"];
        NSLog(@"Order was changed to favorites (not really)");
    }
    
	return query;
}

// Override to customize the look of a cell representing an object. The default is to display
// a UITableViewCellStyleDefault style cell with the label being the first key in the object.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
    [tableView setSeparatorColor: [UIColor clearColor]];
    [tableView setBackgroundColor: [UIColor lightGrayColor]];

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
    }
    
    
	
	// Configure the cell content

    
	UILabel *textLabel = (UILabel*) [cell.contentView viewWithTag:kPAWCellTextLabelTag];
	textLabel.text = [object objectForKey:kPAWParseTextKey];
	textLabel.lineBreakMode = NSLineBreakByWordWrapping;
	textLabel.numberOfLines = 0;
	textLabel.font = [UIFont systemFontOfSize:kPAWWallPostTableViewFontSizeText];
	textLabel.textColor = [UIColor darkGrayColor];
	textLabel.backgroundColor = [UIColor clearColor];
    
	UILabel *locationLabel = (UILabel *) [cell.contentView viewWithTag:kPAWCellLocationLabelTag];
    locationLabel.text = @"Facebook HQ, 1601 Willow Road";
    locationLabel.font = [UIFont systemFontOfSize:kPAWWallPostTableViewFontSizeText];
    locationLabel.backgroundColor = [UIColor clearColor];
    
    UILabel *sentDate = (UILabel *) [cell.contentView viewWithTag:kPAWCellSentDateLabelTag];
    sentDate.text = @"Sent at: 10:28am Wednesday 20 May 2013";
    sentDate.font = [UIFont systemFontOfSize:kPawWallPostTableViewFontSizeDate];
    
    
    UILabel *receivedDate = (UILabel *) [cell.contentView viewWithTag:kPAWCellReceivedDateLabelTag];
    receivedDate.text = @"Received at: 6:05am Friday 28 July 2013";
    receivedDate.font = [UIFont systemFontOfSize:kPawWallPostTableViewFontSizeDate];
    
    
    //TODO Remove
    PFUser *sender = [object objectForKey:@"sender"];
    NSString *prof = [sender objectForKey:@"profile"];
    
	NSString *username = [NSString stringWithFormat:@"%@",[[object objectForKey:@"sender"] objectForKey:@"profile"][@"name"]];
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
    [receivedDate setFrame:CGRectMake(kPAWCellPaddingSides+kPAWCellTextPaddingSides,
                                      kPAWCellPaddingTop+kPAWCellTextPaddingTop+nameSize.height*4+textSize.height,
                                      receivedDateSize.width,
                                      receivedDateSize.height)];
    
    [textLabel setFrame:CGRectMake(kPAWCellPaddingSides+kPAWCellTextPaddingSides,
                                   kPAWCellPaddingTop+kPAWCellTextPaddingTop*9,
                                   textSize.width,
                                   textSize.height)];

    
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
	CGFloat rowHeight = kPAWCellPaddingTop + textSize.height + nameSize.height * 5 + kPAWCellBkgdOffset + kPAWCellPaddingTop;
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

@end

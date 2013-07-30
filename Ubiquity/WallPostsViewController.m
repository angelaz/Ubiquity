//
//  WallPostsViewController.m
//  Ubiquity
//
//  Created by Catherine Morrison on 7/25/13.
//  Copyright (c) 2013 Team Ubi. All rights reserved.
//

static CGFloat const kPAWWallPostTableViewFontSize = 12.f;
static CGFloat const kPAWWallPostTableViewCellWidth = 230.f; // subject to change.

// Cell dimension and positioning constants
static CGFloat const kPAWCellPaddingTop = 5.0f;
static CGFloat const kPAWCellPaddingBottom = 1.0f;
static CGFloat const kPAWCellPaddingSides = 0.0f;
static CGFloat const kPAWCellTextPaddingTop = 6.0f;
static CGFloat const kPAWCellTextPaddingBottom = 5.0f;
static CGFloat const kPAWCellTextPaddingSides = 5.0f;

static CGFloat const kPAWCellUsernameHeight = 15.0f;
static CGFloat const kPAWCellBkgdHeight = 32.0f;
static CGFloat const kPAWCellBkgdOffset = kPAWCellBkgdHeight - kPAWCellUsernameHeight;

// TableViewCell ContentView tags
static NSInteger kPAWCellBackgroundTag = 2;
static NSInteger kPAWCellTextLabelTag = 3;
static NSInteger kPAWCellNameLabelTag = 4;

#import "WallPostsViewController.h"
#import "AppDelegate.h"
#import "TextMessage.h"
#import "LocationController.h"

@interface WallPostsViewController ()

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
    
    // This method is called every time objects are loaded from Parse via the PFQuery
    if (NSClassFromString(@"UIRefreshControl")) {
        [self.refreshControl endRefreshing];
    }
}

- (void)objectsWillLoad {
    [super objectsWillLoad];
    
    // This method is called before a PFQuery is fired to get more objects
}

// Override to customize what kind of query to perform on the class. The default is to query for
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
    
	CLLocationAccuracy filterDistance = locationController.filterDistance;
    
	// And set the query to look by location
	PFGeoPoint *point = [PFGeoPoint geoPointWithLatitude:currentCoordinate.latitude longitude:currentCoordinate.longitude];
	[query whereKey:kPAWParseLocationKey nearGeoPoint:point withinKilometers:filterDistance / kPAWMetersInAKilometer];
	[query includeKey:kPAWParseUserKey];
    
	return query;
}

// Override to customize the look of a cell representing an object. The default is to display
// a UITableViewCellStyleDefault style cell with the label being the first key in the object.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
	// Reuse identifiers for left and right cells
	static NSString *RightCellIdentifier = @"RightCell";
	static NSString *LeftCellIdentifier = @"LeftCell";
    
	// Try to reuse a cell
	BOOL cellIsRight = [[[object objectForKey:kPAWParseUserKey] objectForKey:kPAWParseUsernameKey] isEqualToString:[[PFUser currentUser] objectForKey:@"username"]];
    
	UITableViewCell *cell;
	if (cellIsRight) { // User's post so create blue bubble
		cell = [tableView dequeueReusableCellWithIdentifier:RightCellIdentifier];
		if (cell == nil) {
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:RightCellIdentifier];
			
			UIImageView *backgroundImage = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"blueBubble.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(15.0f, 11.0f, 16.0f, 11.0f)]];
			[backgroundImage setTag:kPAWCellBackgroundTag];
			[cell.contentView addSubview:backgroundImage];
            
			UILabel *textLabel = [[UILabel alloc] init];
			[textLabel setTag:kPAWCellTextLabelTag];
			[cell.contentView addSubview:textLabel];
			
			UILabel *nameLabel = [[UILabel alloc] init];
			[nameLabel setTag:kPAWCellNameLabelTag];
			[cell.contentView addSubview:nameLabel];
		}
	} else { // Someone else's post so create gray bubble
		cell = [tableView dequeueReusableCellWithIdentifier:LeftCellIdentifier];
		if (cell == nil) {
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:LeftCellIdentifier];
			
			UIImageView *backgroundImage = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"grayBubble.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(15.0f, 11.0f, 16.0f, 11.0f)]];
			[backgroundImage setTag:kPAWCellBackgroundTag];
			[cell.contentView addSubview:backgroundImage];
            
			UILabel *textLabel = [[UILabel alloc] init];
			[textLabel setTag:kPAWCellTextLabelTag];
			[cell.contentView addSubview:textLabel];
			
			UILabel *nameLabel = [[UILabel alloc] init];
			[nameLabel setTag:kPAWCellNameLabelTag];
			[cell.contentView addSubview:nameLabel];
		}
	}
	
	// Configure the cell content
	UILabel *textLabel = (UILabel*) [cell.contentView viewWithTag:kPAWCellTextLabelTag];
	textLabel.text = [object objectForKey:kPAWParseTextKey];
	textLabel.lineBreakMode = NSLineBreakByWordWrapping;
	textLabel.numberOfLines = 0;
	textLabel.font = [UIFont systemFontOfSize:kPAWWallPostTableViewFontSize];
	textLabel.textColor = [UIColor whiteColor];
	textLabel.backgroundColor = [UIColor clearColor];
	
	NSString *username = [NSString stringWithFormat:@"- %@",[[object objectForKey:@"user"] objectForKey:@"profile"][@"name"]];
	UILabel *nameLabel = (UILabel*) [cell.contentView viewWithTag:kPAWCellNameLabelTag];
	nameLabel.text = username;
	nameLabel.font = [UIFont systemFontOfSize:kPAWWallPostTableViewFontSize];
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
	CGSize textSize = [[object objectForKey:kPAWParseTextKey] sizeWithFont:[UIFont systemFontOfSize:kPAWWallPostTableViewFontSize] constrainedToSize:CGSizeMake(kPAWWallPostTableViewCellWidth, FLT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
	CGSize nameSize = [username sizeWithFont:[UIFont systemFontOfSize:kPAWWallPostTableViewFontSize] forWidth:kPAWWallPostTableViewCellWidth lineBreakMode:NSLineBreakByTruncatingTail];
	
	
	CGFloat cellHeight = [self tableView:tableView heightForRowAtIndexPath:indexPath]; // Get the height of the cell
	CGFloat textWidth = textSize.width > nameSize.width ? textSize.width : nameSize.width; // Set the width to the largest (text of username)
	
	// Place the content in the correct position depending on the type
	if (cellIsRight) {
		[nameLabel setFrame:CGRectMake(self.tableView.frame.size.width-textWidth-kPAWCellTextPaddingSides-kPAWCellPaddingSides,
									   kPAWCellPaddingTop+kPAWCellTextPaddingTop+textSize.height,
									   nameSize.width,
									   nameSize.height)];
		[textLabel setFrame:CGRectMake(self.tableView.frame.size.width-textWidth-kPAWCellTextPaddingSides-kPAWCellPaddingSides,
									   kPAWCellPaddingTop+kPAWCellTextPaddingTop,
									   textSize.width,
									   textSize.height)];
		[backgroundImage setFrame:CGRectMake(self.tableView.frame.size.width-textWidth-kPAWCellTextPaddingSides*2-kPAWCellPaddingSides,
											 kPAWCellPaddingTop,
											 textWidth+kPAWCellTextPaddingSides*2,
											 cellHeight-kPAWCellPaddingTop-kPAWCellPaddingBottom)];
		
	} else {
		[nameLabel setFrame:CGRectMake(kPAWCellTextPaddingSides-kPAWCellPaddingSides,
									   kPAWCellPaddingTop+kPAWCellTextPaddingTop+textSize.height,
									   nameSize.width,
									   nameSize.height)];
		[textLabel setFrame:CGRectMake(kPAWCellPaddingSides+kPAWCellTextPaddingSides,
									   kPAWCellPaddingTop+kPAWCellTextPaddingTop,
									   textSize.width,
									   textSize.height)];
		[backgroundImage setFrame:CGRectMake(kPAWCellPaddingSides,
											 kPAWCellPaddingTop,
											 textWidth+kPAWCellTextPaddingSides*2,
											 cellHeight-kPAWCellPaddingTop-kPAWCellPaddingBottom)];
	}
    
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForNextPageAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [super tableView:tableView cellForNextPageAtIndexPath:indexPath];
	cell.textLabel.font = [cell.textLabel.font fontWithSize:kPAWWallPostTableViewFontSize];
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
	NSString *username = postFromObject.user.username;
	
	// Calculate what the frame to fit the post text and the username
	CGSize textSize = [text sizeWithFont:[UIFont systemFontOfSize:kPAWWallPostTableViewFontSize] constrainedToSize:CGSizeMake(kPAWWallPostTableViewCellWidth, FLT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
	CGSize nameSize = [username sizeWithFont:[UIFont systemFontOfSize:kPAWWallPostTableViewFontSize] forWidth:kPAWWallPostTableViewCellWidth lineBreakMode:NSLineBreakByTruncatingTail];
    
	// And return this height plus cell padding and the offset of the bubble image height (without taking into account the text height twice)
	CGFloat rowHeight = kPAWCellPaddingTop + textSize.height + nameSize.height + kPAWCellBkgdOffset;
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

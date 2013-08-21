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
#import <Social/Social.h>

@interface WallPostsViewController ()
{
    CGFloat additionalPhotoHeight;
    CGFloat additionalPhotoWidth;
    BOOL photoAttachmentExists;
    RDPlayer* _player;
    BOOL _playing;
    BOOL _paused;
    NSMutableArray *_trackKeys;
    PFQuery *pushQuery;
    NSString *_trackKey;
    NSMutableDictionary *songsToCell;
    NSMutableDictionary *objectsToPost;
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
    objectsToPost = [[NSMutableDictionary alloc] init];
    
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
    
    [AppDelegate storeObjects:self.objects ofType:self.segmentedControl.selectedSegmentIndex];
    
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
    return [AppDelegate queryForType:self.segmentedControl.selectedSegmentIndex];
    
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
    
    PFObject *receipt = [AppDelegate postReceipt:object];
    NSDate *receivedAt = [receipt objectForKey:@"dateOpened"];
    
    if(receivedAt == nil) {
        receivedAt = [NSDate date];
        [AppDelegate openPostForFirstTime:object withReceipt:receipt atDate:receivedAt];
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
                if (photo.size.height > photo.size.width) {
                    [photoView setFrame:CGRectMake(0.0 + additionalPhotoWidth*.2, 0.0, additionalPhotoWidth*.6, additionalPhotoHeight)];
                } else if (photo.size.height < photo.size.width) {
                    [photoView setFrame:CGRectMake(0.0, 0.0, additionalPhotoWidth, additionalPhotoHeight)];
                } else if (photo.size.height == photo.size.width) {
                    [photoView setFrame:CGRectMake(0.0 + additionalPhotoWidth*.1, 0.0, additionalPhotoHeight, additionalPhotoHeight)];
                }

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
    
    mediaView.contentMode = UIViewContentModeScaleAspectFit;
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

    [objectsToPost setObject:object forKey:indexPath];
    
    UIButton *tweetButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *twitterPic = [UIImage imageNamed:@"twitter"];
    [tweetButton setBackgroundImage:twitterPic forState:UIControlStateNormal];
    [cell.contentView addSubview: tweetButton];
    tweetButton.frame = CGRectMake(cell.contentView.frame.size.width/2 + 2.5, cellPaddingTop+cellTextPaddingTop*15+textSize.height + additionalPhotoHeight, 30.0, 30.0);
    [tweetButton addTarget:self action:@selector (sendTweet:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *fbButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *fbPic = [UIImage imageNamed:@"facebook"];
    [fbButton setBackgroundImage:fbPic forState:UIControlStateNormal];
    [cell.contentView addSubview: fbButton];
    fbButton.frame = CGRectMake(cell.contentView.frame.size.width/2 - 32.5, cellPaddingTop+cellTextPaddingTop*15+textSize.height + additionalPhotoHeight, 30.0, 30.0);
    [fbButton addTarget:self action:@selector (fbPost:) forControlEvents:UIControlEventTouchUpInside];
    
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
    
//    //Flips cell on touch
//    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
//    [UIView beginAnimations:@"FlipCellAnimation" context:nil];
//    [UIView setAnimationDuration:0.5];
//    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:cell cache:YES];
//    [cell removeFromSuperview];
//    [self.tableView addSubview:cell];
//    [UIView commitAnimations];
    
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
    
	return rowHeight + 50;
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

- (void)sendTweet: (id) sender
{
    UIView *contentView = [sender superview];
    UITableViewCell *cell = (UITableViewCell *)[contentView superview];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];

    PFObject *object = [objectsToPost objectForKey:indexPath];
    NSString *senderName = [NSString stringWithFormat:@"%@",[[object objectForKey:@"sender"] objectForKey:@"profile"][@"name"]];
    NSString *receiverName = [NSString stringWithFormat:@"%@",[[[PFUser currentUser] objectForKey:@"userData"] objectForKey:@"profile"][@"name"]];
    NSString *objectText = [NSString stringWithFormat:@"%@",[object objectForKey:@"text"]];
    NSString *postText = [NSString stringWithFormat:@"%@ would like to share a note from %@: %@", senderName, receiverName, objectText];
    
    
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
    {
        SLComposeViewController *tweetSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        [tweetSheet setInitialText:postText]; //Add here your text
        
        // Add an image
        [tweetSheet addImage:[UIImage imageNamed:@"socialThumb.png"]]; //Add here the name of your picture
        // Add a link
      //  [tweetSheet addURL:[NSURL URLWithString:@"http://www.countdownpic.com"]]; //Add here your Link
        [self presentViewController: tweetSheet animated: YES completion: nil];
    } else if (![SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
        NSLog(@"twitter not logged in");
    }
    
}


- (void)fbPost: (id) sender
{
    UIView *contentView = [sender superview];
    UITableViewCell *cell = (UITableViewCell *)[contentView superview];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    PFObject *object = [objectsToPost objectForKey:indexPath];
   // NSString *senderName = [NSString stringWithFormat:@"%@",[[object objectForKey:@"sender"] objectForKey:@"profile"][@"name"]];
    NSString *receiverName = [NSString stringWithFormat:@"%@",[[[PFUser currentUser] objectForKey:@"userData"] objectForKey:@"profile"][@"name"]];
    NSString *objectText = [NSString stringWithFormat:@"%@",[object objectForKey:@"text"]];
    NSString *postText = [NSString stringWithFormat:@"%@ has shared a note: %@", receiverName, objectText];
    
    NSMutableString *realURL = [[NSMutableString alloc] init];
    if ([object objectForKey:@"media"]) {
        PFFile *mediaFile = [object objectForKey:@"media"];
        NSString *url = mediaFile.url;
        [realURL setString:url];
    } else {
        NSString *url = @"https://raw.github.com/angelafz/Ubiquity/master/Ubiquity/icon@2x.png?login=cbbm&token=ab2cb597959ba2f93e6d7b63931bff1b";
        [realURL setString:url];
    }

    // Put together the dialog parameters
    NSMutableDictionary *params =
    [NSMutableDictionary dictionaryWithObjectsAndKeys:
     @"TerraFlare", @"name",
     @"Share location-based reminders, memories, and notes with friends.", @"caption",
     postText, @"description",
     realURL, @"picture",
     nil];
    
    // Invoke the dialog
    [FBWebDialogs presentFeedDialogModallyWithSession:nil
                                           parameters:params
                                              handler:
     ^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
         if (error) {
             // Error launching the dialog or publishing a story.
             NSLog(@"Error publishing story.");
         } else {
             if (result == FBWebDialogResultDialogNotCompleted) {
                 // User clicked the "x" icon
                 NSLog(@"User canceled story publishing.");
             } else {
                 // Handle the publish feed callback
                 NSDictionary *urlParams = [self parseURLParams:[resultURL query]];
                 if (![urlParams valueForKey:@"post_id"]) {
                     // User clicked the Cancel button
                     NSLog(@"User canceled story publishing.");
                 } else {
                     // User clicked the Share button
                     NSString *msg = [NSString stringWithFormat:
                                      @"Posted story about note: %@",
                                      objectText];
                     NSLog(@"%@", msg);
                     // Show the result in an alert
                     [[[UIAlertView alloc] initWithTitle:@"Thanks for sharing!"
                                                 message:msg
                                                delegate:nil
                                       cancelButtonTitle:@"OK!"
                                       otherButtonTitles:nil]
                      show];
                 }
             }
         }
     }];

}

- (NSDictionary*)parseURLParams:(NSString *)query {
    NSArray *pairs = [query componentsSeparatedByString:@"&"];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    for (NSString *pair in pairs) {
        NSArray *kv = [pair componentsSeparatedByString:@"="];
        NSString *val =
        [kv[1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        params[kv[0]] = val;
    }
    return params;
}

@end

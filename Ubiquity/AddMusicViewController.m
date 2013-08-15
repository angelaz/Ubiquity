//
//  AddMusicViewController.m
//  Ubiquity
//
//  Created by Angela Zhang on 8/14/13.
//
//

static int const numResults = 5;

#import "AddMusicViewController.h"
#import "AppDelegate.h"

@interface AddMusicViewController ()
{
    UIButton *_playButton;
    UIButton *_searchButton;
    UITextView *_searchTextView;
    BOOL _playing;
    BOOL _paused;
    NSMutableArray *_results;
    NSString *_trackKey;
}
@end

@implementation AddMusicViewController
@synthesize tableView=_tableView;
@synthesize delegate;

- (void)viewDidLoad
{
    [super viewDidLoad];
    Rdio *sharedRdio = [AppDelegate rdioInstance];
    sharedRdio.delegate = self;
}

- (void)viewDidUnload {
    self.tableView = nil;
    [super viewDidUnload];
}

- (void)loadView
{
    CGRect appFrame = [UIScreen mainScreen].applicationFrame;
    UIView *view = [[UIView alloc] initWithFrame:appFrame];
    [view setBackgroundColor:[UIColor whiteColor]];

    CGRect labelFrame = CGRectMake(20, 10, appFrame.size.width - 40, 40);
    UILabel *searchLabel = [[UILabel alloc] initWithFrame:labelFrame];
    [searchLabel setText:@"Search for a song"];
    [searchLabel setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [searchLabel setTextAlignment:NSTextAlignmentCenter];
    
    _searchTextView = [[UITextView alloc] initWithFrame:CGRectMake(20, 60, appFrame.size.width - 40, 40)];
    _searchTextView.layer.borderWidth = 1.0f;
    _searchTextView.layer.borderColor = [[UIColor grayColor] CGColor];
    [_searchTextView setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    
    _searchButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [_searchButton setTitle:@"Search" forState:UIControlStateNormal];
    CGRect searchFrame = CGRectMake(20, 110, appFrame.size.width - 40, 40);
    [_searchButton setFrame:searchFrame];
    [_searchButton setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [_searchButton addTarget:self action:@selector(sendSearchRequest) forControlEvents:UIControlEventTouchUpInside];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(20.0, 200.0, [UIScreen mainScreen].applicationFrame.size.width - 40, [UIScreen mainScreen].applicationFrame.size.height - 200.0) style:UITableViewStylePlain];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    [view addSubview:searchLabel];
    [view addSubview:_searchTextView];
    [view addSubview:_searchButton];
    [view addSubview:_tableView];
    
    self.view = view;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self initButtons];
        [self initResults];
    }
    return self;
}

- (void)initButtons
{
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                target:self
                                                                                action:@selector(dismissDone)];
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                  target:self
                                                                                  action:@selector(dismiss)];
    [[self navigationItem] setRightBarButtonItem:doneButton];
    [[self navigationItem] setLeftBarButtonItem:cancelButton];
}

- (void)initResults
{
    _results = [[NSMutableArray alloc] init];
    for (int i = 0; i < numResults; i ++) {
        [_results addObject:[NSDictionary dictionaryWithObject:@"" forKey:@"name"]];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)dismiss
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)dismissDone
{
    NSString *trackKeyToPassBack;
    if (_trackKey) {
        trackKeyToPassBack = _trackKey;
    } else {
        trackKeyToPassBack = @"";
    }
    [self.delegate addMusicViewController:self didFinishSelectingSong:trackKeyToPassBack];
    [self dismiss];
}

- (void)sendSearchRequest
{
    [_searchTextView resignFirstResponder];
    Rdio *sharedRdio = [AppDelegate rdioInstance];
    NSDictionary *parameters = [[NSDictionary alloc] initWithObjectsAndKeys:_searchTextView.text, @"query", @"Track", @"types", [NSString stringWithFormat:@"%d", numResults], @"count", nil];
    RDAPIRequestDelegate *APIRequestDelegate = [RDAPIRequestDelegate delegateToTarget:self loadedAction:@selector(rdioRequest:didLoadData:) failedAction:@selector(rdioRequest:didFailWithError:)];
    [sharedRdio callAPIMethod:@"search" withParameters:parameters delegate:APIRequestDelegate];
}

- (void)rdioRequest:(RDAPIRequest *)request didLoadData:(id)data {
    NSString *method = [request.parameters objectForKey:@"method"];
    if([method isEqualToString:@"search"]) {
        NSArray *tempResults = [data objectForKey:@"results"];
        for (int i = 0; i < [tempResults count]; i ++) {
            [_results replaceObjectAtIndex:i withObject:[tempResults objectAtIndex:i]];
        }
        [self.tableView reloadData];
    }
}

- (void)rdioRequest:(RDAPIRequest *)request didFailWithError:(NSError *)error
{
    UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Error."
                                                      message:@"Search failed."
                                                     delegate:nil
                                            cancelButtonTitle:@"OK"
                                            otherButtonTitles:nil];
    [message show];
}

//Table View Stuff
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *MyCellIdentifier = @"Cell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:MyCellIdentifier];
    
    if(cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MyCellIdentifier];
    }
    
    [[cell textLabel] setText:[[_results objectAtIndex:[indexPath row]] objectForKey:@"name"]];
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return numResults;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[_results objectAtIndex:[indexPath row]] objectForKey:@"key"]) {
        _trackKey = [[_results objectAtIndex:[indexPath row]] objectForKey:@"key"];
    } else {
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Error:"
                                                          message:@"You haven't searched for any songs yet."
                                                         delegate:nil
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles:nil];
        [message show];
    }
}
@end

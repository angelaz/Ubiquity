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
#import "HomeMapView.h"

@interface AddMusicViewController ()
{
    UIButton *_playButton;
    UIButton *_searchButton;
    UITextView *_searchTextView;
    UITextField *_searchTextField;

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
    [self performSelector:@selector(changeBackground) withObject:self afterDelay:0.25];
}

- (void) changeBackground
{
    [UIView animateWithDuration:0.1
                     animations:^{

    [self.view setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:0.5]];
                     }];
}

- (void)viewDidUnload {
    self.tableView = nil;
    [super viewDidUnload];
}

- (void)loadView
{
    
    CGRect appFrame = [UIScreen mainScreen].applicationFrame;
    int w = appFrame.size.width;
    int h = appFrame.size.height;
    UIView *view = [[UIView alloc] initWithFrame:appFrame];
    [view setBackgroundColor:[UIColor clearColor]];

    
    
    
    
    self.view = view;
    
    [self createJukeboxBackgroundWithFrame:w andHeight:h];
    [self setUpSearchWithFrame:appFrame];
    [self setUpTableViewWithFrame:appFrame];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]  initWithTarget:self action:@selector(hideKeyboard:)];
    [self.view addGestureRecognizer:tap];
}

- (void) createJukeboxBackgroundWithFrame: (int)w andHeight: (int)h
{
    int imageWidth = w * 19 / 20;
    int imageHeight = h * 19 / 20;
    UIImageView *jukebox = [[UIImageView alloc] initWithFrame:CGRectMake(w/2 - imageWidth / 2, h - imageHeight, imageWidth, imageHeight)];
    jukebox.image = [UIImage imageNamed:@"JukeBox"];
    [self.view addSubview:jukebox];
    
}




- (void) setUpSearchWithFrame: (CGRect) appFrame
{
    int width = appFrame.size.width * 5/10;
    int leftMargin = appFrame.size.width/2 - width/2;
    int topMargin = appFrame.size.height*11/40;
    UIColor *titleColor = mainThemeColor;

    _searchTextField = [[UITextField alloc] initWithFrame:CGRectMake(leftMargin, topMargin, width, 25)];
    _searchTextField.layer.borderWidth = 1.0f;
    _searchTextField.layer.borderColor = [titleColor CGColor];
    _searchTextField.placeholder = @"Song or Artist";
    
    _searchTextField.textColor = titleColor;
    _searchTextField.textAlignment = NSTextAlignmentCenter;
    [_searchTextField setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    
    
    int buttonWidth = width * 9/10;
    int buttonOffset = appFrame.size.width/2 - buttonWidth/2;
    _searchButton = [UIButton buttonWithType:UIButtonTypeCustom];
  //  _searchButton = [UIButton buttonWithType:UIButtonTypeCustom];
  //  UIImage *btnImage = [UIImage imageNamed:@"JukeBoxSearch"];
  //  [_searchButton setBackgroundImage: btnImage forState: UIControlStateNormal];
    _searchButton.frame = CGRectMake(buttonOffset, _searchTextField.frame.origin.y + _searchTextField.frame.size.height + 20, buttonWidth, 35);
    [_searchButton setTitle:@"Search" forState:UIControlStateNormal];
    [_searchButton setTitleColor: [UIColor whiteColor] forState:UIControlStateNormal];
    [_searchButton setBackgroundColor: titleColor];
    _searchButton.clipsToBounds = YES;
    _searchButton.layer.cornerRadius = 5.0f;
    [_searchButton addTarget:self action:@selector(sendSearchRequest) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:_searchTextField];
    [self.view addSubview:_searchButton];


}


- (void) setUpTableViewWithFrame: (CGRect) appFrame
{
    int width = appFrame.size.width * 3/5;
    int leftMargin = appFrame.size.width/2 - width/2;
    int topMargin =_searchButton.frame.origin.y + _searchButton.frame.size.height + 10;
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(leftMargin, topMargin, width, [UIScreen mainScreen].applicationFrame.size.height - topMargin) style:UITableViewStylePlain];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.backgroundColor = [UIColor clearColor];
    
    [self.view addSubview:_tableView];
    
}


-(void) hideKeyboard: (id) sender
{
    
    [_searchTextField resignFirstResponder];
    
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
                                                                                  action:@selector(closeJukebox)];
    [[self navigationItem] setRightBarButtonItem:doneButton];
    [[self navigationItem] setLeftBarButtonItem:cancelButton];
}

- (void) closeJukebox
{
    self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height);
    [UIView animateWithDuration:0.25
                     animations:^{
                         
                         self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height);
                     }];
    
    
    [self performSelector:@selector(dismiss) withObject:self afterDelay:0.25];

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
    [self dismissViewControllerAnimated:NO completion:nil];
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
    [_searchTextField resignFirstResponder];
    Rdio *sharedRdio = [AppDelegate rdioInstance];
    NSDictionary *parameters = [[NSDictionary alloc] initWithObjectsAndKeys:_searchTextField.text, @"query", @"Track", @"types", [NSString stringWithFormat:@"%d", numResults], @"count", nil];
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
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return numResults;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[_results objectAtIndex:[indexPath row]] objectForKey:@"key"]) {
        NSLog(@"touched me");
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

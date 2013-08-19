//
// NewMessageViewController.m
// Ubiquity
//
// Created by Winnie Wu on 7/24/13.
// Copyright (c) 2013 Team Ubi. All rights reserved.
//

#import <MobileCoreServices/MobileCoreServices.h>
#import <MediaPlayer/MediaPlayer.h>
#import <Parse/Parse.h>

#import "AppDelegate.h"
#import "LocationController.h"
#import "Geocoding.h"

#import "NewMessageViewController.h"
#import "NewMessageView.h"
#import "WallPostsViewController.h"

#define kOFFSET_FOR_KEYBOARD 100.0
#define kNAV_OFFSET self.navigationController.navigationBar.bounds.size.height;
#define isiPhone5  ([[UIScreen mainScreen] bounds].size.height == 568)?TRUE:FALSE

int const ME = 0;
int const FRIENDS = 1;
int const PUBLIC = 2;

@interface NewMessageViewController ()
{
    BOOL mediaPicked;
    PFFile *mediaFile;
    NSUInteger countNumber;
    int recipient;
    NSString *song;
}
@end

@implementation NewMessageViewController
@synthesize gs;

- (void) viewWillAppear:(BOOL)animated
{
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    [super viewWillAppear:animated];
}

-(void) viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
    [super viewWillDisappear:animated];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"New Message";
        recipientsList = [[NSMutableArray alloc] init];
        countNumber = 0;
        song = @"";
        UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                    target:self
                                                                                    action:@selector(closeNewMessage:)];
        [[self navigationItem] setLeftBarButtonItem:backButton];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _nmv = [[NewMessageView alloc] initWithFrame: [UIScreen mainScreen].bounds];
    [self setView: _nmv];
    
    _nmv.addressTitle.delegate = self;
    _nmv.messageTextView.delegate = self;
    _nmv.friendScroller.delegate = self;
    
    UIBarButtonItem *doneButton= [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                               target:self
                                                                               action:@selector(sendMessage:)];
    [[self navigationItem] setRightBarButtonItem:doneButton];
    
    [_nmv.addFriendsButton addTarget:self action:@selector(selectFriendsButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    _nmv.tapRecognizer = [[UITapGestureRecognizer alloc]  initWithTarget:self action:@selector(hideKeyboard:)];
    [_nmv addGestureRecognizer:_nmv.tapRecognizer];
    
    [_nmv.pictureButton addTarget:self action:@selector(choosePicture:) forControlEvents:UIControlEventTouchUpInside];
    self.friendPickerController = nil;
    _nmv.searchBar = nil;
    
    _nmv.imagePicker = [[UIImagePickerController alloc] init];
    _nmv.imagePicker.delegate = self;
    
    recipient = ME;
    [_nmv.addFriendsButton removeFromSuperview];
    [_nmv.friendScroller removeFromSuperview];
    [_nmv.toButton addTarget:self action:@selector(recipientSwitcher:) forControlEvents:UIControlEventTouchUpInside];

    [_nmv.musicButton addTarget:self action:@selector(launchMusicSearch) forControlEvents:UIControlEventTouchUpInside];
    
}

- (void) recipientSwitcher: (id) sender
{
    if (recipient == ME)
    {
        [_nmv.toButton setBackgroundImage: [UIImage imageNamed: @"ToFriends"] forState:UIControlStateNormal];
        recipient = FRIENDS;
        [_nmv addSubview: _nmv.addFriendsButton];
        [_nmv addSubview: _nmv.friendScroller];
        _nmv.recipientLabel.text = @"Add Friends";

    } else if (recipient == FRIENDS)
    {
        [_nmv.toButton setBackgroundImage: [UIImage imageNamed: @"ToPublic"] forState:UIControlStateNormal];
        recipient = PUBLIC;
        [_nmv.addFriendsButton removeFromSuperview];
        [_nmv.friendScroller removeFromSuperview];
        _nmv.recipientLabel.text = @"Note for Everyone";


    } else {
        [_nmv.toButton setBackgroundImage: [UIImage imageNamed: @"ToMe"] forState:UIControlStateNormal];
        recipient = ME;
        _nmv.recipientLabel.text = @"Note for Myself";

    }
}

- (void)addSearchBarToFriendPickerView
{
    if (_nmv.searchBar == nil) {
        CGFloat searchBarHeight = 44.0;
        _nmv.searchBar =
        [[UISearchBar alloc]
         initWithFrame:
         CGRectMake(0,0,
                    self.view.bounds.size.width,
                    searchBarHeight)];
        _nmv.searchBar.autoresizingMask = _nmv.searchBar.autoresizingMask |
        UIViewAutoresizingFlexibleWidth;
        _nmv.searchBar.delegate = self;
        _nmv.searchBar.showsCancelButton = YES;
        
        [self.friendPickerController.canvasView addSubview:_nmv.searchBar];
        CGRect newFrame = self.friendPickerController.view.bounds;
        newFrame.size.height -= searchBarHeight;
        newFrame.origin.y = searchBarHeight;
        self.friendPickerController.tableView.frame = newFrame;
    }
}

-(void) hideKeyboard: (id) sender
{
    
    [_nmv.addressTitle resignFirstResponder];
    [_nmv.messageTextView resignFirstResponder];
    
}
-(void)keyboardWillHide: (id) sender {
    if (self.view.frame.origin.y > 0)
    {
        [self setViewMovedUp:YES];
    }
    else if (self.view.frame.origin.y < 0)
    {
        [self setViewMovedUp:NO];
    }
}

-(void)textViewDidBeginEditing:(UITextView *)sender
{
    if ([sender isEqual: _nmv.addressTitle])
        [_nmv.addressTitle selectAll:self];
    if ([sender isEqual:_nmv.messageTextView])
    {
        //move the main view, so that the keyboard does not hide it.
        if  (self.view.frame.origin.y >= 0)
        {
            [self setViewMovedUp:YES];
        }
    }
}

//method to move the view up/down whenever the keyboard is shown/dismissed
-(void)setViewMovedUp:(BOOL)movedUp
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3]; // if you want to slide up the view
    
    CGRect rect = self.view.frame;
    if (movedUp)
    {
        // 1. move the view's origin up so that the text field that will be hidden come above the keyboard
        // 2. increase the size of the view so that the area behind the keyboard is covered up.
        rect.origin.y -= kOFFSET_FOR_KEYBOARD;
        rect.size.height += kOFFSET_FOR_KEYBOARD;
    }
    else
    {
        // revert back to the normal state.
        rect.origin.y += kOFFSET_FOR_KEYBOARD;
        rect.size.height -= kOFFSET_FOR_KEYBOARD;
    }
    self.view.frame = rect;
    
    [UIView commitAnimations];
}

-(void) closeNewMessage: (id) sender
{
    if (mediaPicked == YES) {
        [_nmv.thumbnailImageView removeFromSuperview];
    }
    [_nmv.messageTextView setText: @""];
    mediaPicked = NO;
    song = @"";
    self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height);
    [UIView animateWithDuration:0.25
                     animations:^{
                         self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height);
                     }];

    
    [self performSelector:@selector(dismissMessageView) withObject:self afterDelay:0.25];

}

- (void) dismissMessageView
{
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (void) sendMessage: (id) sender
{
    
    // Dismiss keyboard and capture any auto-correct
    [_nmv.messageTextView resignFirstResponder];
    
    // Get the post's message
    NSString *postMessage = _nmv.messageTextView.text;
    
    [_nmv.messageTextView setText: @""];
    
    //Get the currently logged in PFUser
    PFUser *user = [PFUser currentUser];
    
    //Get and set the marker's location as where the post should be
    LocationController *locationController = [LocationController sharedLocationController];
    
    CLLocationCoordinate2D postLocation = locationController.marker.position;
    PFGeoPoint *currentPoint = [PFGeoPoint geoPointWithLatitude:postLocation.latitude longitude:postLocation.longitude];
    
    // Create a PFObject using the Post class and set the values we extracted above
    PFObject *postObject = [PFObject objectWithClassName:kPAWParsePostsClassKey];
    [postObject setObject:postMessage forKey:kPAWParseTextKey];
    [postObject setObject:_nmv.addressTitle.text forKey:@"locationAddress"];
    [postObject setObject:[user objectForKey:@"userData"] forKey:kPAWParseSenderKey];
    [postObject setObject:currentPoint forKey:kPAWParseLocationKey];
    if (mediaPicked == YES) {
        [postObject setObject:mediaFile forKey:@"media"];
        [_nmv.thumbnailImageView removeFromSuperview];
        [postObject setObject:@150 forKey:@"mediaHeight"];
    }
    mediaPicked = NO;
    
    if (![song isEqualToString:@""]) { //There's a song attached to this post!
        [postObject setObject:song forKey:@"trackKey"];
    }
    song = @"";
    
    NSMutableArray *readReceiptsArray = [[NSMutableArray alloc] initWithCapacity:countNumber+1];
    
    [postObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        [self sendInvitesViaFacebook:recipientsList atAddress:_nmv.addressTitle.text];
        
        if (recipient == ME) {
            countNumber = 1;
            [AppDelegate linkOrStoreUserDetails:[[PFUser currentUser] objectForKey:@"userData"]
                                           toId:[[PFUser currentUser] objectForKey:@"fbId"]
                                         toUser:nil
                          andStoreUnderRelation:@"receivers"
                                       toObject:postObject
                                     finalBlock:^(PFObject *made){}];
            
            NSString *username = [NSString stringWithFormat:@"%@", [[PFUser currentUser] objectForKey:@"fbId"]];
            PFObject *readReceiptsObject = [PFObject objectWithClassName:@"ReadReceipts"];
            //[readReceiptsObject setObject:[NSNull null] forKey:@"dateOpened"];
            [readReceiptsObject setObject:username forKey:@"receiver"];
            [readReceiptsArray addObject:readReceiptsObject];
   
        } else if (recipient == FRIENDS) {

            for (id<FBGraphUser> user in recipientsList) {
                
                [AppDelegate linkOrStoreUserDetails:user
                                               toId:[user id]
                                             toUser:nil
                              andStoreUnderRelation:@"receivers"
                                           toObject:postObject
                                         finalBlock:^(PFObject *made){}];
                
                NSString *username = [NSString stringWithFormat:@"%@", [user objectForKey:@"id"]];
                PFObject *readReceiptsObject = [PFObject objectWithClassName:@"ReadReceipts"];
               // [readReceiptsObject setObject:[NSNull null] forKey:@"dateOpened"];
                [readReceiptsObject setObject:username forKey:@"receiver"];
                [readReceiptsArray addObject:readReceiptsObject];

            }
        }
        
        [PFObject saveAllInBackground:readReceiptsArray block:^(BOOL succeeded, NSError *error) {
            [postObject setObject:(NSArray *)readReceiptsArray forKey:@"readReceiptsArray"];
            [postObject saveInBackground];
        }];
        
        if (countNumber == 0) {
            PFQuery *query = [PFQuery queryWithClassName:@"UserData"];
            [query whereKey:@"facebookId" equalTo:[NSString stringWithFormat:@"100006434632076"]];
            [query getFirstObjectInBackgroundWithBlock:^(PFObject *obj, NSError *error) {
                [AppDelegate linkOrStoreUserDetails:obj
                                               toId:[obj objectForKey:@"facebookId"]
                                             toUser:nil
                              andStoreUnderRelation:@"receivers"
                                           toObject:postObject
                                         finalBlock:^(PFObject *made){}];
            }];
            
            
        }
    }];
    
    // Set the access control list on the postObject to restrict future modifications
    // to this object
    PFACL *readOnlyACL = [PFACL ACL];
    [readOnlyACL setPublicReadAccess:YES]; // Create read-only permissions
    [readOnlyACL setWriteAccess:YES forUser:[PFUser currentUser]];
    
    [postObject setACL:readOnlyACL]; // Set the permissions on the postObject
    
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
    
    [self closeNewMessage:self];
}

- (void) choosePicture: (id) sender
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [_nmv.imagePicker setSourceType:UIImagePickerControllerSourceTypeCamera];
        NSArray* mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
        _nmv.imagePicker.mediaTypes = mediaTypes;
        [_nmv.imagePicker setSourceType:UIImagePickerControllerSourceTypeSavedPhotosAlbum];
    } else {
        [_nmv.imagePicker setSourceType:UIImagePickerControllerSourceTypeSavedPhotosAlbum];
    }
    [self presentViewController:_nmv.imagePicker animated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    mediaPicked = NO;
}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    UIImage *image;
    NSData *mediaData;
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:(NSString *) kUTTypeImage]) {
        image = [info valueForKey:UIImagePickerControllerOriginalImage];
        mediaData = UIImageJPEGRepresentation(image, 1.0f);
    } else if ([mediaType isEqualToString:(NSString *)kUTTypeMovie]) {
        NSURL *vidURL = [info valueForKey:UIImagePickerControllerMediaURL];
        mediaData = [NSData dataWithContentsOfURL:vidURL];
        MPMoviePlayerController *player = [[MPMoviePlayerController alloc] initWithContentURL:vidURL];
        image = [player thumbnailImageAtTime:1.0 timeOption:MPMovieTimeOptionNearestKeyFrame];
        player = nil;
    }
    
    mediaFile = [PFFile fileWithData:mediaData];
    mediaPicked = YES;
    
    //Make a thumbnail appear so user can see the image/video they attached!
    if (_nmv.thumbnailImage == nil && !isiPhone5)
    {
        CGRect newFrame = _nmv.messageTextView.frame;
        newFrame.size.height -= 50;
        _nmv.messageTextView.frame = newFrame;
    }
    _nmv.thumbnailImage = [self getThumbnailFromImage:image];

    _nmv.thumbnailImageView = [[UIImageView alloc] initWithImage:_nmv.thumbnailImage];
    float x = _nmv.messageTextView.frame.origin.x + _nmv.messageTextView.frame.size.width - _nmv.thumbnailImage.size.width - 40;
    float y = _nmv.messageTextView.frame.origin.y + _nmv.messageTextView.frame.size.height + 5;
    _nmv.thumbnailImageView.frame = CGRectMake(x, y, _nmv.thumbnailImage.size.width, _nmv.thumbnailImage.size.height);

    [_nmv addSubview:_nmv.thumbnailImageView];
}

- (UIImage *)getThumbnailFromImage:(UIImage *)image {
    CGRect newRect = CGRectIntegral(CGRectMake(0, 0, 20, 20));
    CGImageRef imageRef = image.CGImage;
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(20.0f, 20.0f), NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetInterpolationQuality(context, kCGInterpolationHigh);
    CGAffineTransform flipVertical = CGAffineTransformMake(1, 0, 0, -1, 0, 20.0f);
    CGContextConcatCTM(context, flipVertical);
    // Draw into the context; this scales the image
    CGContextDrawImage(context, newRect, imageRef);
    CGImageRef newImageRef = CGBitmapContextCreateImage(context);
    UIImage *newImage = [UIImage imageWithCGImage:newImageRef];

    CGImageRelease(newImageRef);
    UIGraphicsEndImageContext();
    
    return newImage;
}

- (BOOL)textFieldShouldReturn: (UITextField *)textField {
    
    [textField resignFirstResponder];
    return NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)locationDidChange:(NSNotification *)note{
    LocationController* locationController = [LocationController sharedLocationController];
    NSLog(@"Did update locations");
    //TODO
    //[self updateLocation:locationController.location.coordinate];
    
    [locationController.av dismissWithClickedButtonIndex:0 animated:YES];
    locationController.av = nil;
}

- (void) handlePickerDone
{
    [self dismissViewControllerAnimated:NO completion:nil];
    
}

////ADA
- (IBAction)selectFriendsButtonAction:(id)sender {
    if (self.friendPickerController == nil) {
        // Create friend picker, and get data loaded into it.
        self.friendPickerController = [[FBFriendPickerViewController alloc] init];
        self.friendPickerController.title = @"Select Friends";
        
        self.friendPickerController.delegate = self;
    }
    [self.friendPickerController loadData];
    [self.friendPickerController clearSelection];
    [self presentViewController:self.friendPickerController
                       animated:YES
                     completion:^(void){
                         [self addSearchBarToFriendPickerView];
                     }
     ];
    
}
- (void)facebookViewControllerCancelWasPressed:(id)sender
{
    NSLog(@"Friend selection cancelled.");
    
    [self handlePickerDone];
}

- (void)facebookViewControllerDoneWasPressed:(id)sender
{
    [recipientsList removeAllObjects];
    
    
    for (id<FBGraphUser> user in self.friendPickerController.selection) {
        [recipientsList addObject: user];
        
        NSLog(@"Person is %@", user);
    }
    //    NSMutableString *names = [[NSMutableString alloc] initWithString:@" "];
    
    for (int i = 0; i < recipientsList.count; i ++)
    {
        id <FBGraphUser> user = [recipientsList objectAtIndex: i];
        int iconDimensions = 30.0;
        CGFloat xOrigin = i * (iconDimensions + 5);
        NSString *facebookID = [user objectForKey:@"id"];//userData[@"id"];
        FBProfilePictureView *profilePictureView = [[FBProfilePictureView alloc] init];
        profilePictureView.frame = CGRectMake(xOrigin, 0.0, iconDimensions, iconDimensions);
        profilePictureView.profileID = facebookID;
        [_nmv.friendScroller addSubview:profilePictureView];
        
    }
    _nmv.friendScroller.contentSize = CGSizeMake(30.0 *
                                                 recipientsList.count,
                                                 30.0);
    
    
    
    
    countNumber = [recipientsList count];
    if (countNumber > 0)
        _nmv.recipientLabel.text = @"";
    readReceipts = [[NSMutableDictionary alloc] initWithCapacity:countNumber];
    
    [self handlePickerDone];
}

- (void) refreshScrollViewWith
{
    _nmv.friendScroller.pagingEnabled = YES;
    
}

- (void) handleSearch:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    _nmv.searchText = searchBar.text;
    [self.friendPickerController updateView];
}

- (void)searchBarSearchButtonClicked:(UISearchBar*)searchBar
{
    [self handleSearch:searchBar];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar {
    _nmv.searchText = nil;
    [searchBar resignFirstResponder];
}

- (BOOL)friendPickerViewController:(FBFriendPickerViewController *)friendPicker
                 shouldIncludeUser:(id<FBGraphUser>)user
{
    //TODO: Trim this list to just show FB friends who are members of this app
    if (_nmv.searchText && ![_nmv.searchText isEqualToString:@""]) {
        NSRange result = [user.name
                          rangeOfString:_nmv.searchText
                          options:NSCaseInsensitiveSearch];

        if (result.location != NSNotFound) {
            return YES;
        } else {
            return NO;
        }
    } else {
        return YES;
    }
    return YES;
}

- (void) sendInvitesViaFacebook:(NSMutableArray *)facebookFriends atAddress:(NSString *)address {
    
    //Make an array of the ids listed here for Parse
    NSMutableArray * idArray = [NSMutableArray arrayWithCapacity: [facebookFriends count]];
    [facebookFriends enumerateObjectsUsingBlock: ^(id obj, NSUInteger idx, BOOL *stop) {
        [idArray addObject: [obj id]];
    }];
    
    PFQuery *query = [PFQuery queryWithClassName:@"_User"];
    [query whereKey:@"fbId" containedIn:idArray];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        NSMutableArray * priorAppUsersArray = [NSMutableArray arrayWithCapacity:[objects count]];
        [objects enumerateObjectsUsingBlock: ^(id obj, NSUInteger idx, BOOL *stop) {
            [priorAppUsersArray addObject: [obj objectForKey:@"fbId"]];
        }];
        
        [idArray removeObjectsInArray:priorAppUsersArray];
        
        if([idArray count] > 0) {
            NSMutableDictionary* params =   [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                             [idArray componentsJoinedByString:@","], @"to",    nil];
            
            [FBWebDialogs presentRequestsDialogModallyWithSession:[PFFacebookUtils session]
                                                          message:[NSString stringWithFormat:@"You've received a note near %@ on Ubiquity! Install the app to find it!", address]
                                                            title:@"Invite Friend to Find Message with Ubiquity!"
                                                       parameters:params
                                                          handler:^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
                                                              if (error) {
                                                                  // Case A: Error launching the dialog or sending request.
                                                              } else {
                                                                  if (result == FBWebDialogResultDialogNotCompleted) {
                                                                      //Case B: User clicked the "x" icon
                                                                  } else {
                                                                      //Case C: Dialog shown and the user clicks Cancel or Send
                                                                  }
                                                              }
                                                          }];
        }

        }];
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

- (void)launchMusicSearch
{
    AddMusicViewController *amvc = [[AddMusicViewController alloc] initWithNibName:nil bundle:nil];
    amvc.delegate = self;
    UINavigationController *addMusicNavController = [[UINavigationController alloc]
                                                     initWithRootViewController:amvc];
//    [self.navigationController presentViewController:addMusicNavController animated:YES completion:nil];
    
    self.navigationController.modalPresentationStyle = UIModalPresentationCurrentContext;
    [self presentViewController:addMusicNavController animated:YES completion:nil];
    amvc.view.frame = CGRectMake(amvc.view.frame.origin.x, self.view.frame.size.height, amvc.view.frame.size.width, amvc.view.frame.size.height);
    [UIView animateWithDuration:0.25
                     animations:^{

                         amvc.view.frame = CGRectMake(0, self.navigationController.navigationBar.frame.size.height, amvc.view.frame.size.width, amvc.self.view.frame.size.height);
                     }];

}

- (void)addMusicViewController:(AddMusicViewController *)controller didFinishSelectingSong:(NSString *)trackKey
{
    NSLog(@"Returned from AMVC: %@", trackKey);
    song = trackKey;
    if (![song isEqualToString:@""])
    {
        [_nmv.musicButton setImage:[UIImage imageNamed:@"musicNoteRed"] forState:UIControlStateNormal];
        
    }

}
@end

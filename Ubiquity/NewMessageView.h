//
//  NewMessageView.h
//  Ubiquity
//
//  Created by Winnie Wu on 7/26/13.
//  Copyright (c) 2013 Team Ubi. All rights reserved.
//

#import <UIKit/UIKit.h>


extern int const TOP_PADDING;
extern int const ADDRESS_PADDING;
extern int const LEFT_PADDING;
extern int const HEADER_HEIGHT;
extern int const LINE_HEIGHT;


@interface NewMessageView : UIView
@property (nonatomic, strong) UIButton *addFriendsButton;

@property (strong, nonatomic) UISearchBar *searchBar;
@property (strong, nonatomic) NSString *searchText;


@property (nonatomic, strong) UIButton *recipientButton;
@property (nonatomic, strong) UIButton *toButton;
@property (nonatomic, strong) UILabel *fromLabel;
@property (nonatomic, strong) UILabel *sentLabel;

@property (nonatomic, strong) UITextView *messageTextView;
@property (nonatomic, strong) UITextView *addressTitle;
@property (nonatomic, strong) UIImageView *envelope;
@property (nonatomic, strong) UIScrollView *friendScroller;

@property (nonatomic, strong) UIButton *pictureButton;
@property (nonatomic, strong) UIImagePickerController *imagePicker;
@property (nonatomic, strong) UIImage *thumbnailImage;
@property (nonatomic, strong) UIImageView *thumbnailImageView;
@property (nonatomic, strong) UIGestureRecognizer *tapRecognizer;

@property (nonatomic, strong) UIButton *musicButton;

@end

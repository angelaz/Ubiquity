//
//  NoteView.h
//  Ubiquity
//
//  Created by Winnie Wu on 8/13/13.
//  Copyright (c) 2013 Team Ubi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NoteView : UIView
@property (nonatomic, strong) UIButton *addFriendsButton;

@property (strong, nonatomic) UISearchBar *searchBar;
@property (strong, nonatomic) NSString *searchText;

@property (nonatomic, strong) UILabel *fromLabel;
@property (nonatomic, strong) UILabel *sentLabel;
@property (nonatomic, strong) UILabel *receivedLabel;

@property (nonatomic, strong) UILabel *pagingLabel;



@property (nonatomic, strong) UILabel *messageTextView;
@property (nonatomic, strong) UIScrollView *textScroll;
@property (nonatomic, strong) UILabel *addressTitle;
@property (nonatomic, strong) UIImageView *envelope;
@property (nonatomic, strong) UIScrollView *friendScroller;

@property (nonatomic, strong) UIButton *pictureButton;
@property (nonatomic, strong) UIImagePickerController *imagePicker;
@property (nonatomic, strong) UIImage *thumbnailImage;
@property (nonatomic, strong) UIImageView *thumbnailImageView;
@property (nonatomic, strong) UIGestureRecognizer *tapRecognizer;

@end

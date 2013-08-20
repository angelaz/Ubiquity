//
//  TutorialViewController.h
//  Ubiquity
//
//  Created by Catherine Morrison on 8/19/13.
//  Copyright (c) 2013 Team Ubi. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TutorialViewController;

@protocol TutorialViewControllerDelegate <NSObject>

- (void) didFinishTutorial;

@end

@interface TutorialViewController : UIViewController <UIGestureRecognizerDelegate>

@property (nonatomic, weak) id <TutorialViewControllerDelegate> delegate;
@property (nonatomic, strong) UIGestureRecognizer *bubbleTapRecognizer;

@end

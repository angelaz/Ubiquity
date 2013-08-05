//
//  UbiquityTests.m
//  UbiquityTests
//
//  Created by Angela Zhang on 7/24/13.
//  Copyright (c) 2013 Team Ubi. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <SenTestingKit/SenTestingKit.h>

#import "RecentViewController.h"
#import "LoginViewController.h"
#import "LocationController.h"
#import "OptionsViewController.h"
#import "NewMessageViewController.h"
#import "FriendsViewController.h"


@interface UbiquityTests : SenTestCase
{
    id appDelegate;
    id locationController;
}

@end

@implementation UbiquityTests

- (void)setUp
{
    [super setUp];
    appDelegate = [[UIApplication sharedApplication] delegate];
    locationController = [[LocationController alloc] init];
    STAssertTrue( 1 == 2, @"FAIL");
    id nmvc = [[NewMessageViewController alloc] init];
    [self testNewMessageControllerSend];
    NSLog(@"hi");


    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}


- (void)testAppDelegateExists
{
    STAssertNotNil(appDelegate, nil);
}

- (void) testTabBarExists
{
    STAssertNotNil([appDelegate tabBarController], nil);
}

- (void) testNavigationPopulated
{
    NSArray *viewControllers = [[appDelegate tabBarController] customizableViewControllers];
    STAssertEquals(viewControllers.count, 4, nil);
    for (id viewController in viewControllers)
        STAssertNotNil(viewController, nil);
}

- (void) testStartAtRecentMessageController
{
    STAssertEquals([[appDelegate tabBarController] selectedIndex], 0, nil);
}

- (void) testLocationController
{
    STAssertNotNil(locationController, nil);
}

- (void) testRecentViewController
{
    id rvc = [[RecentViewController alloc] init];
    STAssertNotNil(rvc, nil);
//    CLLocation *testLocation = [[CLLocation alloc] initWithLatitude:0.0 longitude:0.0];
//    [locationController setLocation: testLocation];
//    STAssertNoThrow([rvc queryForAllPostsNearLocation:testLocation withNearbyDistance: 0.0], nil);
//    testLocation = [[CLLocation alloc] initWithLatitude:300.0 longitude:600.0];
//    STAssertNoThrow([rvc queryForAllPostsNearLocation:testLocation withNearbyDistance: 0.0], nil);
}

- (void) testNewMessageControllerInitPosition
{
    id nmvc = [[NewMessageViewController alloc] init];
    STAssertNotNil(nmvc, nil);
    STAssertEquals([[[[nmvc nmv] map] selectedMarker] position], [[[locationController locationManager] location] coordinate], nil);
    
}

- (void) testNewMessageControllerSend
{
    id nmvc = [[NewMessageViewController alloc] init];
    STAssertNoThrow([nmvc sendMessage: [[nmvc nmv] sendButton]], nil);
    [[[nmvc nmv] messageTextView] setText: @"Test Message"];
    STAssertFalse([[[[nmvc nmv] messageTextView] text] isEqualToString: @"1"], nil);
    [nmvc sendMessage: [[nmvc nmv] sendButton]];
    STAssertNoThrow([nmvc sendMessage: [[nmvc nmv] sendButton]], nil);
    NSLog(@"%@", [[[nmvc nmv] messageTextView] text]);
    [[[nmvc nmv] messageTextView] setText: @""];
    STAssertNoThrow([nmvc sendMessage: [[nmvc nmv] sendButton]], nil);


    
}

- (void) testNewMessageControllerSearch
{
    id nmvc = [[NewMessageViewController alloc] init];
    
}

@end

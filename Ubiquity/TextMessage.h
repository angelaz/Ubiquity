//
//  TextMessage.h
//  Ubiquity
//
//  Created by Winnie Wu on 7/24/13.
//  Copyright (c) 2013 Team Ubi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import <Parse/Parse.h>
#import "AppDelegate.h"


@interface TextMessage : NSObject <MKAnnotation>

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;

@property (nonatomic, readonly, copy) NSString *title;
@property (nonatomic, readonly, copy) NSString *address;


@property (nonatomic, readonly, strong) PFObject *message;
@property (nonatomic, readonly, strong) PFGeoPoint *geopoint;
@property (nonatomic, readonly, strong) PFObject *sender;
@property (nonatomic, assign) BOOL animatesDrop;
@property (nonatomic, readonly) MKPinAnnotationColor pinColor;

- (BOOL)equalToPost:(TextMessage *)aTextMessage;
- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate andTitle:(NSString *)title andAddress:(NSString *)address;
- (id)initWithPFObject:(PFObject *)message;

- (void)setTitleAndSubtitleOutsideDistance:(BOOL)outside;

@end

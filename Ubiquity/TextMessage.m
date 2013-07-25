//
//  TextMessage.m
//  Ubiquity
//
//  Created by Winnie Wu on 7/24/13.
//  Copyright (c) 2013 Team Ubi. All rights reserved.
//

#import "TextMessage.h"

/* see .h file for wtf is going on
 */

@interface TextMessage ()

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *address;


@property (nonatomic, strong) PFObject *message;
@property (nonatomic, strong) PFGeoPoint *geopoint;
@property (nonatomic, strong) PFUser *user;
@property (nonatomic, assign) MKPinAnnotationColor pinColor;


@end

@implementation TextMessage

- (id)initWithCoordinate:(CLLocationCoordinate2D)aCoordinate andTitle:(NSString *)aTitle andAddress:(NSString *)aAddress {
	self = [super init];
	if (self) {
		self.coordinate = aCoordinate;
		self.title = aTitle;
		self.address = aAddress;
		self.animatesDrop = NO;
	}
	return self;
}

- (id)initWithPFObject:(PFObject *)anObject {
	self.message = anObject;
	self.geopoint = [anObject objectForKey:kPAWParseLocationKey];
	self.user = [anObject objectForKey:kPAWParseUserKey];
    
	[anObject fetchIfNeeded];
	CLLocationCoordinate2D aCoordinate = CLLocationCoordinate2DMake(self.geopoint.latitude, self.geopoint.longitude);
	NSString *aTitle = [anObject objectForKey:kPAWParseTextKey];
	NSString *aAddress = [[anObject objectForKey:kPAWParseUserKey] objectForKey:kPAWParseUsernameKey];
    
	return [self initWithCoordinate:aCoordinate andTitle:aTitle andAddress:aAddress];
}

- (BOOL)equalToPost:(TextMessage *)aTextMessage {
	if (aTextMessage == nil) {
		return NO;
	}
    
	if (aTextMessage.message && self.message) {
		// We have a PFObject inside the PAWPost, use that instead.
		if ([aTextMessage.message.objectId compare:self.message.objectId] != NSOrderedSame) {
			return NO;
		}
		return YES;
	} else {
		// Fallback code:
        
		if ([aTextMessage.title compare:self.title] != NSOrderedSame ||
			[aTextMessage.address compare:self.address] != NSOrderedSame ||
			aTextMessage.coordinate.latitude != self.coordinate.latitude ||
			aTextMessage.coordinate.longitude != self.coordinate.longitude ) {
			return NO;
		}
        
		return YES;
	}
}


@end
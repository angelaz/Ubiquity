//
//  GMSMarkerWithCount.h
//  Ubiquity
//
//  Created by Winnie Wu on 8/15/13.
//  Copyright (c) 2013 Team Ubi. All rights reserved.
//

#import <GoogleMaps/GoogleMaps.h>

@interface GMSMarkerWithCount : GMSMarker

@property int count;
- (UIImage *) icon;
- (void) updateIcon;
@end

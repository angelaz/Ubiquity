//
//  Geocoding.h
//  Ubiquity
//
//  Created by Angela Zhang on 8/1/13.
//  Copyright (c) 2013 Team Ubi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Geocoding : NSObject
- (id)init;
- (void)geocodeAddress:(NSString *)address
          withCallback:(SEL)callback
          withDelegate:(id)delegate;

@property (nonatomic, strong) NSDictionary *geocode;
@end

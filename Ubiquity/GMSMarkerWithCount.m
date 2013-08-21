//
//  GMSMarkerWithCount.m
//  Ubiquity
//
//  Created by Winnie Wu on 8/15/13.
//  Copyright (c) 2013 Team Ubi. All rights reserved.
//

#import "GMSMarkerWithCount.h"

@implementation GMSMarkerWithCount

- (id) init
{
    self = [super init];
    if (self)
    {
        self.count = 0;
        super.icon = [self icon];
        self.animated = super.animated;
    }
    return self;
}



-(UIImage *)resizeImage:(UIImage *)image width:(CGFloat)resizedWidth height:(CGFloat)resizedHeight
{
    UIGraphicsBeginImageContext(CGSizeMake(resizedWidth ,resizedHeight));
    [image drawInRect:CGRectMake(0, 0, resizedWidth, resizedHeight)];
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return result;
}

- (UIImage *) icon
{
    if(self.count > 0) {
        UIImage *baseImage = [UIImage imageNamed:@"UnreadNoteFire"];
        baseImage = [self resizeImage: baseImage width:60.0 height:100.0];
        NSString *text = [NSString stringWithFormat:@"%d", self.count];
        CGPoint drawingPoint = CGPointMake(baseImage.size.width*30/40, baseImage.size.height*23/56);
        UIImage *returnImage = [self drawText: text inImage: baseImage atPoint: drawingPoint];
        return returnImage;
    } else {
        UIImage *baseImage = [UIImage imageNamed:@"UnreadNote"];
        baseImage = [self resizeImage: baseImage width:35.0 height:40.0];
        NSString *text = [NSString stringWithFormat:@"%d", self.count];
        CGPoint drawingPoint = CGPointMake(baseImage.size.width*61/80, baseImage.size.height*1/80);
        UIImage *returnImage = [self drawText: text inImage: baseImage atPoint: drawingPoint];
        return returnImage;
    }
}

- (void) updateIcon
{
    self.count++;
    super.icon = self.icon;
}

- (void) restartCount
{
    self.count = 0;
    super.icon = self.icon;
}


- (UIImage*) drawText:(NSString*) text
             inImage:(UIImage*)  image
             atPoint:(CGPoint)   point
{
    
    UIFont *font = [UIFont boldSystemFontOfSize:10];
    UIGraphicsBeginImageContextWithOptions(image.size, NO, 0.0);
    [image drawInRect:CGRectMake(0,0,image.size.width,image.size.height)];
    CGRect rect = CGRectMake(point.x, point.y, image.size.width, image.size.height);
    [[UIColor whiteColor] set];
    [text drawInRect:CGRectIntegral(rect) withFont:font];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

@end

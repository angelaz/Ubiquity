//
//  ArrowView.m
//  Ubiquity
//
//  Created by Catherine Morrison on 8/19/13.
//  Copyright (c) 2013 Team Ubi. All rights reserved.
//

#import "ArrowView.h"

@implementation ArrowView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.opaque = NO;
        self.backgroundColor = [UIColor clearColor];
        
        self.layer.masksToBounds = YES;
        self.layer.cornerRadius = 8.0;
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code

    CGContextRef context = UIGraphicsGetCurrentContext();

    CGFloat radius = self.layer.cornerRadius;
    UIColor *rectColor = [UIColor whiteColor];
    
    // Make sure corner radius isn't larger than half the shorter side
    if (radius > self.bounds.size.width/2.0) radius = self.bounds.size.width/2.0;
    if (radius > self.bounds.size.height/2.0) radius = self.bounds.size.height/2.0;
    
    CGFloat minx2 = CGRectGetMinX(self.bounds);
    CGFloat miny2 = CGRectGetMinY(self.bounds) + self.pointWidth;
    CGFloat midx = CGRectGetMidX(self.bounds);
    CGFloat maxx = CGRectGetMaxX(self.bounds);
    CGFloat midy = CGRectGetMidY(self.bounds);
    CGFloat maxy = CGRectGetMaxY(self.bounds);
    
    /*
     CGContextMoveToPoint(context, minx, midy);
     CGContextAddArcToPoint(context, minx, miny, midx, miny, radius);
     CGContextAddArcToPoint(context, maxx, miny, maxx, midy, radius);
     CGContextAddArcToPoint(context, maxx, maxy, midx, maxy, radius);
     CGContextAddArcToPoint(context, minx, maxy, minx, midy, radius);
     */
    
    CGContextMoveToPoint(context, minx2 + _pointY, miny2);
    CGContextAddArcToPoint(context, maxx, miny2, maxx, midy, radius);
    CGContextAddArcToPoint(context, maxx, maxy, midx, maxy, radius);
    CGContextAddArcToPoint(context, minx2, maxy, minx2, midy, radius);
    CGContextAddArcToPoint(context, minx2, miny2, midx, miny2, radius);
    CGContextAddLineToPoint (context, minx2 + _pointY + _pointHeight, miny2);
    CGContextAddLineToPoint (context, minx2 + _pointY + (_pointHeight / 2), miny2 - self.pointWidth);
    
    CGContextClosePath(context);
    [rectColor setFill];
    CGContextDrawPath(context, kCGPathFill);
    [self setNeedsDisplay];
}


@end

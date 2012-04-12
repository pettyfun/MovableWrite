//
//  PFPoint.m
//  PettyFunNote
//
//  Created by YJ Park on 11/9/10.
//  Copyright 2010 PettyFun. All rights reserved.
//

#import "PFPoint.h"

NSString *const PFPOINT_X = @"x";
NSString *const PFPOINT_Y = @"y";

@implementation PFPoint
@synthesize x;
@synthesize y;

-(NSString *) getType {
    return @"com.pettyfun.bucket.model.base.PFPoint";
}

-(void) dealloc{
    [super dealloc];
}

-(void) onInit {
    [super onInit];    
}

-(void) onInitWithData:(NSDictionary *)data {
    [super onInitWithData:data];
    PFOBJECT_GET_FLOAT(PFPOINT_X, x)
    PFOBJECT_GET_FLOAT(PFPOINT_Y, y)
}

-(void) onGetData:(NSMutableDictionary *)data {
    [super onGetData:data];
    PFOBJECT_SET_FLOAT_2_DIGITS(PFPOINT_X, x)
    PFOBJECT_SET_FLOAT_2_DIGITS(PFPOINT_Y, y)
}

#pragma mark -
#pragma mark Specific Methods

+(PFPoint *) pointFromCGPoint:(CGPoint)point {
    PFPoint *result = [[[PFPoint alloc] init] autorelease];
    [result setPoint:point];
    return result;
}

-(CGPoint) getPoint {
    return CGPointMake(x, y);
}

-(void) setPoint: (CGPoint)point {
    x = point.x;
    y = point.y;
}

-(void) setX:(float)newX andY:(float)newY {
    x = newX;
    y = newY;
}

@end

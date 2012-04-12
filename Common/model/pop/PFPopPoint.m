//
//  PFPopPoint.m
//  PettyFunPop
//
//  Created by YJ Park on 11/18/10.
//  Copyright 2010 PettyFun. All rights reserved.
//

#import "PFPopPoint.h"
#import "PFPop.h"

NSString *const PFPOP_POINT_PRESSURE = @"p";
NSString *const PFPOP_POINT_CREATE_TIME = @"t";

@implementation PFPopPoint
@synthesize pressure;
@synthesize createTime;

-(NSString *) getType {
    return @"com.pettyfun.bucket.model.pop.PFPopPoint";
}

-(void) dealloc{
    [createTime dealloc];
    [super dealloc];
}

-(void) onInit {
    [super onInit];    
    createTime = nil;
}

-(void) onInitWithData:(NSDictionary *)data {
    [super onInitWithData:data];
    PFOBJECT_GET_FLOAT(PFPOP_POINT_PRESSURE, pressure)
    PFOBJECT_GET_DATE(PFPOP_POINT_CREATE_TIME, createTime)
}

-(void) onGetData:(NSMutableDictionary *)data {
    [super onGetData:data];
    PFOBJECT_SET_FLOAT(PFPOP_POINT_PRESSURE, pressure)
    PFOBJECT_SET_DATE(PFPOP_POINT_CREATE_TIME, createTime)
}

#pragma mark -
#pragma mark Specific Methods

+(PFPopPoint *) popPointFromCGPoint:(CGPoint)point
                         withPressure:(float)pointPressure {
    PFPopPoint *result = [[[PFPopPoint alloc] init] autorelease];
    [result setPoint:point];
    result.pressure = pointPressure;
    result.createTime = [NSDate date];
    return result;
}

+(PFPopPoint *) popPointFromPB:(PFPBPopPoint *)pbPopPoint {
    PFPopPoint *result = [[[PFPopPoint alloc] init] autorelease];
    [result setX:pbPopPoint.x andY:pbPopPoint.y];
    if ([pbPopPoint hasPressure]) {
        result.pressure = pbPopPoint.pressure;
    } else {
        result.pressure = 1.0f;
    }
    if ([pbPopPoint hasCreateTime]) {        
        result.createTime = [[NSDate dateWithTimeIntervalSince1970: \
                              pbPopPoint.createTime] retain];
    }
    return result;
}

-(PFPBPopPoint *) getPB {
    PFPBPopPoint_Builder *builder = [PFPBPopPoint builder];
    [builder setX:x];
    [builder setY:y];
    if (pressure != 1.0f) {
        [builder setPressure:pressure];
    } else {
        [builder clearPressure];
    }
    if (createTime) {
        [builder setCreateTime:[createTime timeIntervalSince1970]];
    } else {
        [builder clearCreateTime];
    }
    return [builder build];
}

@end

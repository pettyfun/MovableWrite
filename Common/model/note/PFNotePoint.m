//
//  PFNotePoint.m
//  PettyFunNote
//
//  Created by YJ Park on 11/18/10.
//  Copyright 2010 PettyFun. All rights reserved.
//

#import "PFNotePoint.h"

NSString *const PFNOTE_POINT_PRESSURE = @"p";
NSString *const PFNOTE_POINT_CREATE_TIME = @"t";

@implementation PFNotePoint
@synthesize pressure;
@synthesize createTime;

-(NSString *) getType {
    return @"com.pettyfun.bucket.model.note.PFNotePoint";
}

-(void) dealloc{
    [super dealloc];
}

-(void) onInit {
    [super onInit];    
}

-(void) onInitWithData:(NSDictionary *)data {
    [super onInitWithData:data];
    PFOBJECT_GET_FLOAT(PFNOTE_POINT_PRESSURE, pressure)
    PFOBJECT_GET_FLOAT(PFNOTE_POINT_CREATE_TIME, createTime)
}

-(void) onGetData:(NSMutableDictionary *)data {
    [super onGetData:data];
    PFOBJECT_SET_FLOAT_2_DIGITS(PFNOTE_POINT_PRESSURE, pressure)
    PFOBJECT_SET_FLOAT_2_DIGITS(PFNOTE_POINT_CREATE_TIME, createTime)
}

#pragma mark -
#pragma mark Specific Methods

+(PFNotePoint *) notePointFromCGPoint:(CGPoint)point
                         withPressure:(float)pointPressure
                          andTimeMark:(double)timeMark {
    PFNotePoint *result = [[[PFNotePoint alloc] init] autorelease];
    [result setPoint:point];
    result.pressure = pointPressure;
    result.createTime = [[NSDate date] timeIntervalSince1970] - timeMark;
    return result;
}

#pragma mark -
#pragma mark PFString
-(NSString *) getString {
    return [NSString stringWithFormat:@"%.2f,%.2f,%.2f,%.2f;", x, y, pressure, createTime];
}

-(id) initWithScanner0:(NSScanner *)scanner {
    if ((self = [super init])) {
        [scanner scanFloat:&x];
        [scanner scanFloat:&y];
        [scanner scanFloat:&pressure];
        [scanner scanFloat:&createTime];
    }
    return self;
}

-(id) initWithScanner:(NSScanner *)scanner {
    if ((self = [super init])) {
        [scanner scanFloat:&x];
        [scanner scanString:@"," intoString:NULL];
        [scanner scanFloat:&y];
        [scanner scanString:@"," intoString:NULL];
        [scanner scanFloat:&pressure];
        [scanner scanString:@"," intoString:NULL];
        [scanner scanFloat:&createTime];
        [scanner scanString:@";" intoString:NULL];
    }
    return self;
}

+(NSMutableArray *) pointsWithString:(NSString *)string {
    NSMutableArray *result = [[[NSMutableArray alloc] init] autorelease];
    NSScanner *scanner = [NSScanner scannerWithString:string];
    while (![scanner isAtEnd]) {    
        PFNotePoint *point = [[[PFNotePoint alloc] initWithScanner:scanner] autorelease];
        [result addObject:point];
    }
    return result;
}

+(CGFloat) getFactor:(CGFloat)factor scale:(CGFloat)scale {
    return [PFNotePoint verifyFactor:scale * factor];
}

+(CGFloat) verifyFactor:(CGFloat)factor {
    CGFloat result = factor;
    if (result < PFNOTE_POINT_MIN_FACTOR) {
        result = PFNOTE_POINT_MIN_FACTOR;
    } else if (result > PFNOTE_POINT_MAX_FACTOR) {
        result = PFNOTE_POINT_MAX_FACTOR;
    }
    return result;    
}

@end

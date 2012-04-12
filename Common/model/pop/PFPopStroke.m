//
//  PFPopStroke.m
//  PettyFunPop
//
//  Created by YJ Park on 1/6/11.
//  Copyright 2011 PettyFun.com. All rights reserved.
//

#import "PFPopStroke.h"
#import "PFPop.h"

NSString *const PFPOP_STROKE_OFFSET = @"o";
NSString *const PFPOP_STROKE_POINTS = @"p";
NSString *const PFPOP_STROKE_TYPE = @"t";

@implementation PFPopStroke
@synthesize type;
@synthesize offset;
@synthesize points;

-(NSString *) getType {
    return @"com.pettyfun.bucket.model.pop.PFPopStroke";
}

-(void) dealloc{
    [offset release];
    [points release];
    [super dealloc];
}

-(void) onInit {
    [super onInit];    
    offset = nil;
    points = [[NSMutableArray alloc] init];    
    type = PFPopStrokeTypesPop;
}

#pragma mark -
#pragma mark Specific Methods

-(void) startStroke:(CGPoint)point withPressure:(float)pressure {
    offset = [[PFPopPoint popPointFromCGPoint:point withPressure:pressure] retain];
    [points removeAllObjects];
}

-(void) addPoint:(CGPoint)point withPressure:(float)pressure{
    if (offset) {
        CGPoint relativePoint = CGPointMake(point.x - offset.x, point.y - offset.y);
        [points addObject:[PFPopPoint popPointFromCGPoint:relativePoint withPressure:pressure]];
    } else {
        PFError(@"addPoint() must be called after startStroke(), %@", self);
    }
}

-(PFPopPoint *) getLastPoint {
    return [points lastObject];
}

-(float) getLineWidth {
    NSString *lineWidth = (NSString *)[self getProperty:PFPOP_LINE_WIDTH];
    if (lineWidth) {
        return [lineWidth floatValue];
    }
    return 5.0f;
}

-(void) setLineWidth:(float)lineWidth {
    if (lineWidth != 1.0f) {
        [self setProperty:[[NSNumber numberWithFloat:lineWidth] stringValue] forKey:PFPOP_LINE_WIDTH];
    }
}

-(NSString *) getColor {
    NSString *color = (NSString *)[self getProperty:PFPOP_COLOR];
    return color;
}

-(void) setColor:(NSString *)color {
    if (color) {
        [self setProperty:color forKey:PFPOP_COLOR];
    }
}

-(void) onInitWithNonPB:(NSDictionary *)data {
    PFOBJECT_GET_OBJECT(PFPOP_STROKE_OFFSET, offset, PFPopPoint)
    PFOBJECT_GET_ARRAY(PFPOP_STROKE_POINTS, points, PFPopPoint)
    PFOBJECT_GET_INT(PFPOP_STROKE_TYPE, type)
}

-(void) onInitWithPB:(NSData *)pbData {
    PFPBPopStroke *pbStroke = [PFPBPopStroke parseFromData:pbData];
    offset = [[PFPopPoint popPointFromPB:pbStroke.offset] retain];
    points = [[NSMutableArray alloc] init];
    type = pbStroke.type;
    for (PFPBPopPoint *point in pbStroke.pointsList) {
        [points addObject:[PFPopPoint popPointFromPB:point]];
    }
}

-(PBGeneratedMessage *) getPB {
    PFPBPopStroke_Builder *builder = [PFPBPopStroke builder];
    [builder setType:type];
    [builder setOffset:[offset getPB]];
    [builder clearPointsList];
    for (PFPopPoint *point in points) {
        [builder addPoints:[point getPB]];
    }
    return [builder build];
}

@end

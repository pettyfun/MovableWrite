//
//  PFNoteStroke.m
//  PettyFunNote
//
//  Created by YJ Park on 11/9/10.
//  Copyright 2010 PettyFun. All rights reserved.
//

#import "PFNoteStroke.h"
#import "PFNote.h"

NSString *const PFNOTE_STROKE_OFFSET = @"offset";
NSString *const PFNOTE_STROKE_POINTS = @"points";

@implementation PFNoteStroke
@synthesize offset;
@synthesize points;

-(NSString *) getType {
    return @"com.pettyfun.bucket.model.note.PFNoteStroke";
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
}

#pragma mark -
#pragma mark Specific Methods

-(void) startStroke:(CGPoint)point withPressure:(float)pressure {
    offset = [[PFNotePoint notePointFromCGPoint:point
                                   withPressure:pressure
                                    andTimeMark:0] retain];
    [self.points removeAllObjects];
}

-(void) addPoint:(CGPoint)point withPressure:(float)pressure{
    if (offset) {
        CGPoint relativePoint = CGPointMake(point.x - offset.x, point.y - offset.y);
        [self.points addObject:[PFNotePoint notePointFromCGPoint:relativePoint
                                               withPressure:pressure
                                                andTimeMark:offset.createTime]];
    } else {
        PFError(@"addPoint() must be called after startStroke(), %@", self);
    }
}

-(PFNotePoint *) getLastPoint {
    return [self.points lastObject];
}

-(float) getLineWidth {
    NSInteger lineWidthIndex = [self getLineWidthIndex];
    float width = 1.0f;
    switch (lineWidthIndex) {
        case 1:
            width = 1.5f;
            break;
        case 2:
            width = 0.5f;
            break;
        case 3:
            width = 2.0f;
            break;
        case 4:
            width = 0.25f;
            break;
        case 5:
            width = 3.0f;
            break;
        case 6:
            width = 4.0f;
            break;
        case 7:
            width = 5.0f;
            break;
        default:
            break;
    }
    return width / PFNOTE_POINT_BASE_FACTOR;
}

-(NSInteger) getLineWidthIndex {
    NSString *lineWidthIndex = (NSString *)[self getProperty:PFNOTE_LINE_WIDTH_INDEX];
    if (lineWidthIndex) {
        return [lineWidthIndex intValue];
    }
    return 0;
}

-(void) setLineWidthIndex:(NSInteger)lineWidthIndex {
    if (lineWidthIndex > 0) {
        [self setProperty:[[NSNumber numberWithInt:lineWidthIndex] stringValue] forKey:PFNOTE_LINE_WIDTH_INDEX];
    } else {
        [self setProperty:nil forKey:PFNOTE_LINE_WIDTH_INDEX];
    }
}

-(NSInteger) getColorIndex {
    NSString *colorIndex = (NSString *)[self getProperty:PFNOTE_COLOR_INDEX];
    if (colorIndex) {
        return [colorIndex intValue];
    }
    return 0;
}

-(void) setColorIndex:(NSInteger)colorIndex {
    if (colorIndex > 0) {
        [self setProperty:[[NSNumber numberWithInt:colorIndex] stringValue] forKey:PFNOTE_COLOR_INDEX];
    } else {
        [self setProperty:nil forKey:PFNOTE_COLOR_INDEX];
    }
}

-(void) onInitWithData:(NSDictionary *)data {
    [super onInitWithData:data];
    PFOBJECT_GET_OBJECT(PFNOTE_STROKE_OFFSET, offset, PFNotePoint)
    PFOBJECT_GET_ARRAY(PFNOTE_STROKE_POINTS, points, PFNotePoint)        
}

-(void) onGetData:(NSMutableDictionary *)data {
    [super onGetData:data];
    PFOBJECT_SET_OBJECT(PFNOTE_STROKE_OFFSET, offset)
    PFOBJECT_SET_ARRAY(PFNOTE_STROKE_POINTS, points)        
}

@end

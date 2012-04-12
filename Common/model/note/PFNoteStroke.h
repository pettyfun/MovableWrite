//
//  PFNoteStroke.h
//  PettyFunNote
//
//  Created by YJ Park on 11/9/10.
//  Copyright 2010 PettyFun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PFNotePoint.h"
#import "PFUtils.h"

extern NSString *const PFNOTE_STROKE_OFFSET;
extern NSString *const PFNOTE_STROKE_POINTS;

@interface PFNoteStroke : PFObject {
    PFNotePoint *offset;
    NSMutableArray *points;
}
@property (readonly) PFNotePoint *offset;
@property (readonly) NSMutableArray *points;

-(void) startStroke:(CGPoint)point withPressure:(float)pressure;
-(void) addPoint:(CGPoint)point withPressure:(float)pressure;
-(PFNotePoint *) getLastPoint;

-(NSInteger) getColorIndex;
-(void) setColorIndex:(NSInteger)colorIndex;

-(float) getLineWidth;
-(NSInteger) getLineWidthIndex;
-(void) setLineWidthIndex:(NSInteger)lineWidthIndex;

@end

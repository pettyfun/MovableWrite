//
//  PFPopStroke.h
//  PettyFunPop
//
//  Created by YJ Park on 1/6/11.
//  Copyright 2011 PettyFun.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PFPBObject.h"
#import "PFPopPoint.h"
#import "PFUtils.h"
#import "Pfpop.pb.h"

extern NSString *const PFPOP_STROKE_OFFSET;
extern NSString *const PFPOP_STROKE_POINTS;

typedef enum {
    PFPopStrokeTypesPop = 0,
    PFPopStrokeTypesSolid
} PFPopStrokeTypes;

@interface PFPopStroke : PFPBObject {
    PFPopStrokeTypes type;
    PFPopPoint *offset;
    NSMutableArray *points;
}
@property (readonly) PFPopStrokeTypes type;
@property (readonly) PFPopPoint *offset;
@property (readonly) NSMutableArray *points;

-(void) startStroke:(CGPoint)point withPressure:(float)pressure;
-(void) addPoint:(CGPoint)point withPressure:(float)pressure;
-(PFPopPoint *) getLastPoint;

-(NSString *) getColor;
-(void) setColor:(NSString *)color;

-(float) getLineWidth;
-(void) setLineWidth:(float)lineWidth;

@end

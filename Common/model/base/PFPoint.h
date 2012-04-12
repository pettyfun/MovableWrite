//
//  PFPoint.h
//  PettyFunNote
//
//  Created by YJ Park on 11/9/10.
//  Copyright 2010 PettyFun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PFObject.h"

extern NSString *const PFPOINT_X;
extern NSString *const PFPOINT_Y;
extern NSString *const PFPOINT_PRESSURE;
extern NSString *const PFPOINT_CREATE_TIME;

@interface PFPoint : PFObject {
    float x, y; 
}
@property (readonly) float x;
@property (readonly) float y;

+(PFPoint *) pointFromCGPoint:(CGPoint)point;
-(CGPoint) getPoint;
-(void) setPoint: (CGPoint)point;
-(void) setX:(float)newX andY:(float)newY;

@end

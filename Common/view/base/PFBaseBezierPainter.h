//
//  BaseBezierPainter.h
//  PettyFunPop
//
//  Created by YJ Park on 1/6/11.
//  Copyright 2011 PettyFun.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#define PF_BEZIER_DEBUGGING NO

#define PF_BEZIER_MIN_DISTANCE 3.0f

#define PF_BEZIER_ANGLE_DELTA_FACTOR_1 0.25f
#define PF_BEZIER_ANGLE_DELTA_FACTOR_2 0.5f
#define PF_BEZIER_ANGLE_DELTA_FACTOR_3 0.5f

#define PF_BEZIER_CONTROL_FACTOR_1 0.35f
#define PF_BEZIER_CONTROL_FACTOR_2 0.5f
#define PF_BEZIER_CONTROL_FACTOR_3 0.5f

@interface PFBaseBezierPainter : NSObject {

}

-(CGPoint)_getControlPoint:(CGPoint)centerPoint 
                      with:(CGPoint)point 
                        of:(CGPoint)refPoint
             controlFactor:(float)controlFactor
               angleFactor:(float)angleFactor;

-(CGPoint) _paintPointSegment:(CGPoint)thisPoint
                    onContext:(CGContextRef)context
             withCurrentPoint:(CGPoint)currentPoint
                 andLastPoint:(CGPoint)lastPoint
                 andNextPoint:(CGPoint)nextPoint;


@end

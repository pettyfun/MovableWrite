//
//  BaseBezierPainter.m
//  PettyFunPop
//
//  Created by YJ Park on 1/6/11.
//  Copyright 2011 PettyFun.com. All rights reserved.
//

#import "PFBaseBezierPainter.h"


@implementation PFBaseBezierPainter

-(CGPoint)_getControlPoint:(CGPoint)centerPoint 
                      with:(CGPoint)point 
                        of:(CGPoint)refPoint 
             controlFactor:(float)controlFactor
               angleFactor:(float)angleFactor {
    float distance = hypotf(point.y - centerPoint.y, point.x - centerPoint.x);
    float refDistance = hypotf(refPoint.y - centerPoint.y, refPoint.x - centerPoint.x);
    if ((distance < PF_BEZIER_MIN_DISTANCE) || (refDistance < PF_BEZIER_MIN_DISTANCE)) {
        return centerPoint;
    }
    float angle = atan2f(point.y - centerPoint.y, point.x - centerPoint.x);
    float refAngle = atan2f(refPoint.y - centerPoint.y, refPoint.x - centerPoint.x);
    float angleDelta = refAngle - angle;
    if (angleDelta < 0) {
        angleDelta += M_PI * 2;
    }
    angleDelta -= M_PI;
    float distantFactor = controlFactor * (M_PI - fabsf(angleDelta)) / M_PI;
    angleDelta *= angleFactor;
    float controlAngle = angle + angleDelta;
    CGPoint controlPoint = CGPointMake(distance * distantFactor * cosf(controlAngle) + centerPoint.x, 
                                       distance * distantFactor * sinf(controlAngle) + centerPoint.y);
    /*
     NSLog(@"angel = %f, refAngle = %f, controlAngle = %f", 
     angle / M_PI * 180, refAngle / M_PI * 180, controlAngle / M_PI * 180);
     NSLog(@"centerPoint = %@, point = %@, refPoint = %@, controlPoint = %@",
     NSStringFromCGPoint(centerPoint),
     NSStringFromCGPoint(point),
     NSStringFromCGPoint(refPoint),
     NSStringFromCGPoint(controlPoint));
     */
    return controlPoint;
}

-(CGPoint) _paintPathCurve:(CGPoint)thisPoint
                 onContext:(CGContextRef)context
          withCurrentPoint:(CGPoint)currentPoint
              andLastPoint:(CGPoint)lastPoint
              andNextPoint:(CGPoint)nextPoint {
    //first half of the corner;
    CGPoint endPoint = [self _getControlPoint:thisPoint with:lastPoint of:nextPoint
                                controlFactor:PF_BEZIER_CONTROL_FACTOR_1
                                  angleFactor:PF_BEZIER_ANGLE_DELTA_FACTOR_1];
    CGPoint controlPoint1 = [self _getControlPoint:currentPoint with:endPoint of:lastPoint
                                     controlFactor:PF_BEZIER_CONTROL_FACTOR_2
                                       angleFactor:PF_BEZIER_ANGLE_DELTA_FACTOR_2];
    
    CGPoint controlPoint2 = [self _getControlPoint:endPoint with:currentPoint of:thisPoint
                                     controlFactor:PF_BEZIER_CONTROL_FACTOR_2
                                       angleFactor:PF_BEZIER_ANGLE_DELTA_FACTOR_2];
    CGContextAddCurveToPoint(context, controlPoint1.x, controlPoint1.y,
                             controlPoint2.x, controlPoint2.y, endPoint.x, endPoint.y);
    if (PF_BEZIER_DEBUGGING) {
        CGContextStrokePath(context);        
        CGContextSetRGBStrokeColor(context, 0.0f, 1.0f, 0.0f, 1);
        CGContextStrokeEllipseInRect(context, CGRectMake(endPoint.x, endPoint.y, 1, 1));
        CGContextSetRGBStrokeColor(context, 0.0f, 1.0f, 1.0f, 1);
        CGContextStrokeEllipseInRect(context, CGRectMake(controlPoint1.x, controlPoint1.y, 1, 1));
        CGContextStrokeEllipseInRect(context, CGRectMake(controlPoint2.x, controlPoint2.y, 1, 1));
        CGContextBeginPath(context);
        CGContextMoveToPoint(context, endPoint.x, endPoint.y);
    }
    return endPoint;
}

-(CGPoint) _paintCornerCurve:(CGPoint)thisPoint
                   onContext:(CGContextRef)context
            withCurrentPoint:(CGPoint)currentPoint
                andLastPoint:(CGPoint)lastPoint
                andNextPoint:(CGPoint)nextPoint {
    CGPoint endPoint = [self _getControlPoint:thisPoint with:nextPoint of:lastPoint
                                controlFactor:PF_BEZIER_CONTROL_FACTOR_1
                                  angleFactor:PF_BEZIER_ANGLE_DELTA_FACTOR_1];
    CGPoint controlPoint1 = [self _getControlPoint:thisPoint with:currentPoint of:endPoint
                                     controlFactor:PF_BEZIER_CONTROL_FACTOR_3
                                       angleFactor:PF_BEZIER_ANGLE_DELTA_FACTOR_3];
    CGPoint controlPoint2 = [self _getControlPoint:thisPoint with:endPoint of:currentPoint
                                     controlFactor:PF_BEZIER_CONTROL_FACTOR_3
                                       angleFactor:PF_BEZIER_ANGLE_DELTA_FACTOR_3];
    CGContextAddCurveToPoint(context, controlPoint1.x, controlPoint1.y,
                             controlPoint2.x, controlPoint2.y, endPoint.x, endPoint.y);
    if (PF_BEZIER_DEBUGGING) {
        CGContextStrokePath(context);        
        CGContextSetRGBStrokeColor(context, 1.0f, 0.0f, 0.0f, 1);
        CGContextStrokeEllipseInRect(context, CGRectMake(thisPoint.x, thisPoint.y, 1, 1));
        CGContextSetRGBStrokeColor(context, 0.3f, 1.0f, 0.0f, 1);
        CGContextStrokeEllipseInRect(context, CGRectMake(controlPoint1.x, controlPoint2.y, 1, 1));
        CGContextStrokeEllipseInRect(context, CGRectMake(controlPoint2.x, controlPoint2.y, 1, 1));
        CGContextSetRGBStrokeColor(context, 0.0f, 0.0f, 0.0f, 1);
        CGContextBeginPath(context);
        CGContextMoveToPoint(context, endPoint.x, endPoint.y);
    }
    return endPoint;
}    
-(CGPoint) _paintPointSegment:(CGPoint)thisPoint
                    onContext:(CGContextRef)context
             withCurrentPoint:(CGPoint)currentPoint
                 andLastPoint:(CGPoint)lastPoint
                 andNextPoint:(CGPoint)nextPoint {
    CGPoint endPoint = currentPoint;
    float lastDistance = 0;
    if (lastPoint.x != NSNotFound) {
        lastDistance = hypotf(thisPoint.x - lastPoint.x, thisPoint.y - lastPoint.y);
    }
    if ((lastPoint.x != NSNotFound) && (nextPoint.x != NSNotFound) &&
        (lastDistance >= PF_BEZIER_MIN_DISTANCE)) {
        //first half of the corner;
        endPoint = [self _paintPathCurve:thisPoint onContext:context
                        withCurrentPoint:currentPoint andLastPoint:lastPoint andNextPoint:nextPoint];
        endPoint = [self _paintCornerCurve:thisPoint onContext:context
                          withCurrentPoint:endPoint andLastPoint:lastPoint andNextPoint:nextPoint];
    } else if ((lastPoint.x != NSNotFound) &&
               (lastDistance >= PF_BEZIER_MIN_DISTANCE)) {
        endPoint = [self _paintPathCurve:thisPoint onContext:context
                        withCurrentPoint:currentPoint andLastPoint:lastPoint andNextPoint:thisPoint];
    } else {
        //First point or last point
        endPoint = thisPoint;
        CGContextAddLineToPoint(context, endPoint.x, endPoint.y);
        CGContextMoveToPoint(context, endPoint.x, endPoint.y);
    }
    return endPoint;
}

@end

//
//  PFPopBezierCellPainter.m
//  PettyFunPop
//
//  Created by YJ Park on 1/6/11.
//  Copyright 2011 PettyFun.com. All rights reserved.
//

#import "PFPopPopStrokePainter.h"
#import "PFPopPainterFactory.h"

@implementation PFPopPopStrokePainter

-(void) paintStroke:(PFPopStroke *)stroke
            forCell:(PFPopCell *)cell
          onContext:(CGContextRef)context
         withConfig:(PFPopConfig *)config
         background:(BOOL)background {    
    float factor = config.factor;
    //factor = 1.0f;
    CGContextTranslateCTM(context, stroke.offset.x * factor, stroke.offset.y * factor);
    
    DECLARE_PFPOP_PAINTER_FACTORY
    UIColor *strokeColor = [painterFactory decodeStrokeColor:[stroke getColor]];
    
    float lineWidth = factor * [stroke getLineWidth] * 2.0f;
    if (!background) {
        strokeColor = [painterFactory getBackgroundColor:cell];
        lineWidth = lineWidth * 0.7f;
    }
    CGContextSetStrokeColorWithColor(context, strokeColor.CGColor);
    CGContextSetLineWidth(context, lineWidth);
    
    CGContextBeginPath (context);
    CGContextMoveToPoint(context, 0, 0);
    CGContextAddLineToPoint(context, 0, 0);
    CGPoint lastPoint = CGPointMake(NSNotFound, NSNotFound);
    CGPoint thisPoint = CGPointMake(0, 0);
    CGPoint currentPoint = CGPointMake(0, 0);
    CGPoint nextPoint = CGPointMake(NSNotFound, NSNotFound);
    for (PFPopPoint *strokePoint in stroke.points) {
        CGPoint nextPoint = [strokePoint getPoint];
        nextPoint = CGPointMake(nextPoint.x * factor, nextPoint.y * factor);
        currentPoint = [self _paintPointSegment:thisPoint onContext:context
                               withCurrentPoint:currentPoint
                                   andLastPoint:lastPoint andNextPoint:nextPoint];
        lastPoint = thisPoint;
        thisPoint = CGPointMake(nextPoint.x, nextPoint.y);
        nextPoint = CGPointMake(NSNotFound, NSNotFound);
    }
    [self _paintPointSegment:thisPoint onContext:context
            withCurrentPoint:currentPoint
                andLastPoint:lastPoint andNextPoint:nextPoint];
    CGContextStrokePath(context);
    CGContextTranslateCTM(context, -stroke.offset.x * factor, -stroke.offset.y * factor);
}

@end

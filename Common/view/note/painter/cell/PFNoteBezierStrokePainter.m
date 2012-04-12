//
//  PFNoteBezierCellPainter.m
//  PettyFunNote
//
//  Created by YJ Park on 11/18/10.
//  Copyright 2010 PettyFun. All rights reserved.
//

#import "PFNoteBezierStrokePainter.h"
#import "PFNote.h"

@implementation PFNoteBezierStrokePainter

-(void) paintStroke:(PFNoteStroke *)stroke
            forCell:(id<PFCell>)cell
          onContext:(CGContextRef)context
         withConfig:(PFPageConfig *)config 
           andTheme:(PFNoteTheme *)theme
              final:(BOOL)final {
    if (!final) return;
    
    float factor = config.factor;
    CGPoint offset = [cell getOffsetWithConfig:config];
    float offsetX = offset.x + stroke.offset.x * factor;
    float offsetY = offset.y + stroke.offset.y * factor;
    CGContextTranslateCTM(context, offsetX, offsetY);
    
    NSInteger strokeColorIndex = [stroke getColorIndex];
    UIColor *strokeColor = [theme getColor:strokeColorIndex];
    CGContextSetStrokeColorWithColor(context, strokeColor.CGColor);
    
    float lineWidth = config.factor * [stroke getLineWidth];
    CGContextSetLineWidth(context, lineWidth);
    CGContextBeginPath (context);
    CGContextMoveToPoint(context, 0, 0);
    CGContextAddLineToPoint(context, 0, 0);
    CGPoint lastPoint = CGPointMake(NSNotFound, NSNotFound);
    CGPoint thisPoint = CGPointMake(0, 0);
    CGPoint currentPoint = CGPointMake(0, 0);
    CGPoint nextPoint = CGPointMake(NSNotFound, NSNotFound);
    for (PFNotePoint *strokePoint in stroke.points) {
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
    CGContextTranslateCTM(context, -offsetX, -offsetY);
}

@end

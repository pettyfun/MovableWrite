//
//  PFNoteBezierCellPainter.m
//  PettyFunNote
//
//  Created by YJ Park on 11/18/10.
//  Copyright 2010 PettyFun. All rights reserved.
//

#import "PFNotePopBezierStrokePainter.h"
#import "PFNote.h"

@implementation PFNotePopBezierStrokePainter

-(float) getLineWidth:(PFNoteStroke *)stroke final:(BOOL)final {
    float width = 1.0f;
    NSInteger lineWidthIndex = [stroke getLineWidthIndex];
    if (final) {
        switch (lineWidthIndex) {
            case 0:
                width = 1.0f;
                break;
            case 1:
                width = 1.2f;
                break;
            case 2:
                width = 0.6f;
                break;
            case 3:
                width = 1.6f;
                break;
            case 4:
                width = 0.4f;
                break;
            case 5:
                width = 2.0f;
                break;
            case 6:
                width = 2.6f;
                break;
            case 7:
                width = 3.2f;
                break;
            default:
                break;
        }
    } else {
        switch (lineWidthIndex) {
            case 0:
                width = 2.2f;
                break;
            case 1:
                width = 2.6f;
                break;
            case 2:
                width = 1.2f;
                break;
            case 3:
                width = 3.2f;
                break;
            case 4:
                width = 0.8f;
                break;
            case 5:
                width = 3.8f;
                break;
            case 6:
                width = 4.4f;
                break;
            case 7:
                width = 5.0f;
                break;
            default:
                break;
        }
    }
    return width / PFNOTE_POINT_BASE_FACTOR;
}

-(void) paintStroke:(PFNoteStroke *)stroke
            forCell:(id<PFCell>)cell
          onContext:(CGContextRef)context
         withConfig:(PFPageConfig *)config 
           andTheme:(PFNoteTheme *)theme 
              final:(BOOL)final {    
    float factor = config.factor;
    CGPoint offset = [cell getOffsetWithConfig:config];
    float offsetX = offset.x + stroke.offset.x * factor;
    float offsetY = offset.y + stroke.offset.y * factor;
    CGContextTranslateCTM(context, offsetX, offsetY);
    
    NSInteger strokeColorIndex = [stroke getColorIndex];
    UIColor *strokeColor = [theme getColor:strokeColorIndex];
    
    float lineWidth = config.factor * [self getLineWidth:stroke final:final];
    if (final) {
        strokeColor = theme.backgroundColor;
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

//
//  PFNoteGridGridPainter.m
//  PettyFunNote
//
//  Created by YJ Park on 12/18/10.
//  Copyright 2010 PettyFun. All rights reserved.
//

#import "PFNoteCrossGridPainter.h"
#import "PFNoteConfig.h"

@implementation PFNoteCrossGridPainter

-(void) paintPage:(id<PFPage>)page
        onContext:(CGContextRef)context 
       withConfig:(PFPageConfig *)config
           inRect:(CGRect)rect
         viewRect:(CGRect)viewRect 
        withTheme:(PFNoteTheme *)theme {
    float gridWidth = 0.4f;
    CGContextSetLineWidth(context, gridWidth);
    
    float gridMargin = 25.0f;
    
    NSInteger gridColorIndex = [(PFNoteConfig *)config getGridColorIndex];
    UIColor *color = [theme getGridColor:gridColorIndex];
    CGContextSetStrokeColorWithColor(context, color.CGColor);

    CGRect crossRect = CGRectMake(
        viewRect.origin.x + theme.extraConfig.marginLeft,
        viewRect.origin.y + theme.extraConfig.marginTop,
        viewRect.size.width - theme.extraConfig.marginLeft - theme.extraConfig.marginRight, 
                                  viewRect.size.height - theme.extraConfig.marginTop - theme.extraConfig.marginBottom
                                  );
    
    float y = crossRect.origin.y + (crossRect.size.height - truncf(crossRect.size.height / gridMargin) * gridMargin + gridMargin) / 2.0f;
    while (y < crossRect.size.height) {
        CGContextBeginPath(context);
        CGContextMoveToPoint(context, crossRect.origin.x, y);
        CGContextAddLineToPoint(context, crossRect.origin.x + crossRect.size.width, y);
        CGContextStrokePath(context);
        y += gridMargin;
    }
    
    float x = crossRect.origin.x + (crossRect.size.width - truncf(crossRect.size.width / gridMargin) * gridMargin + gridMargin) / 2.0f;
    while (x < crossRect.size.width) {
        CGContextBeginPath(context);
        CGContextMoveToPoint(context, x, crossRect.origin.y);
        CGContextAddLineToPoint(context, x, crossRect.origin.y + crossRect.size.height);
        CGContextStrokePath(context);
        x += gridMargin;
    }
}

@end

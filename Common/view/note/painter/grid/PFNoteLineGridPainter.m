//
//  PFNoteLinePagePainter.m
//  PettyFunNote
//
//  Created by YJ Park on 11/21/10.
//  Copyright 2010 PettyFun. All rights reserved.
//

#import "PFNoteLineGridPainter.h"
#import "PFNoteConfig.h"

@implementation PFNoteLineGridPainter

-(void) paintPage:(id<PFPage>)page
        onContext:(CGContextRef)context 
       withConfig:(PFPageConfig *)config
           inRect:(CGRect)rect
         viewRect:(CGRect)viewRect 
        withTheme:(PFNoteTheme *)theme {
    float gridWidth = 0.4f;
    CGContextSetLineWidth(context, gridWidth);
    
    CGRect pageRect = [page getRect];
    float y = config.factor;
    NSInteger gridColorIndex = [(PFNoteConfig *)config getGridColorIndex];
    UIColor *color = [theme getGridColor:gridColorIndex];
    CGContextSetStrokeColorWithColor(context, color.CGColor);
    while (y <= pageRect.size.height) {
        CGContextBeginPath(context);
        CGContextMoveToPoint(context, 0, (int)y);
        CGContextAddLineToPoint(context, pageRect.size.width, (int)y);
        CGContextStrokePath(context);
        y += config.factor * (1.0f + config.marginLine);
    }
}

@end

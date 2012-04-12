//
//  PFNoteTianGePagePainter.m
//  PettyFunNote
//
//  Created by YJ Park on 11/9/10.
//  Copyright 2010 PettyFun. All rights reserved.
//

#import "PFNoteTianGeGridPainter.h"
#import "PFNoteConfig.h"

@implementation PFNoteTianGeGridPainter

-(void) paintPage:(id<PFPage>)page
        onContext:(CGContextRef)context 
       withConfig:(PFPageConfig *)config
           inRect:(CGRect)rect
         viewRect:(CGRect)viewRect 
        withTheme:(PFNoteTheme *)theme {
    float gridWidth = 0.4f;
    CGContextSetLineWidth(context, gridWidth);    
    
    CGRect pageRect = [page getRect];
    float x = 0;
    float y = 0;
    NSInteger gridColorIndex = [(PFNoteConfig *)config getGridColorIndex];
    UIColor *color = [theme getGridColor:gridColorIndex];
    CGContextSetStrokeColorWithColor(context, color.CGColor);
    while (y < pageRect.size.height) {
        while (x < pageRect.size.width) {
            CGRect cellRect = CGRectMake((int)x,
                                         (int)y,
                                         (int)config.factor,
                                         (int)config.factor);
            CGContextStrokeRect(context, cellRect);
            x += config.factor;
        }
        y += config.factor * (1.0f + config.marginLine);
        x = 0;
    }
}

@end

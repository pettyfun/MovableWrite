//
//  PFPopView.m
//  PettyFunPop
//
//  Created by YJ Park on 1/6/11.
//  Copyright 2011 PettyFun.com. All rights reserved.
//

#import "PFPopView.h"


@implementation PFPopView
@synthesize popConfig;
@synthesize pop;
@synthesize popPainter;
@synthesize delegate;

-(id) init {
    if ((self = [super init])) {
        self.clearsContextBeforeDrawing = YES;
        self.backgroundColor = [UIColor clearColor];
        self.multipleTouchEnabled = YES;
    }
    return self;
}

-(void) dealloc {
    [popConfig release];
    [popPainter release];
    [pop release];
    [super dealloc];
}

-(void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    [self drawRect:rect onContext:context];
}

-(void)drawRect:(CGRect)rect onContext:(CGContextRef)context {
    if (popPainter) {
        if (pop) {
            DECLARE_PFUTILS
            [utils markTime];
            
            [popPainter paintPop:pop 
                       onContext:context 
                      withConfig:popConfig 
                          inRect:rect
                        viewRect:self.frame];

            [utils logTime:@"Slow Paint Page" longerThan:0.1f];
            [utils markTime];
            
            for (PFPopCell *cell in pop.cells) {
                [popPainter paintCell:cell
                            onContext:context
                               inRect:rect
                           withConfig:popConfig];                        
            }
            [utils logTime:NSFormat(@"Slow Paint Cells: %d", [pop.cells count]) longerThan:0.1f];;
        } else {
            [popPainter paintEmptyPopOnContext:context 
                                    withConfig:popConfig 
                                        inRect:rect
                                      viewRect:self.frame];            
        }
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	if (([touches count] == 1) && ([[event allTouches] count] == 1)) {
		UITouch *touch = [touches anyObject];
		CGPoint position = [touch locationInView: self];
        if (delegate && [delegate respondsToSelector:@selector(onTouchDown:withPop:at:)]) {
            [delegate onTouchDown:self 
                          withPop:pop 
                               at:position];
        }
	} else {
		PFDebug(@"Not dealing with multi touch now.");
	}
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	if (([touches count] == 1) && ([[event allTouches] count] == 1)) {
		UITouch *touch = [touches anyObject];
		//CGPoint previous = [touch previousLocationInView: self];
		CGPoint position = [touch locationInView: self];
        if (delegate && [delegate respondsToSelector:@selector(onTouchDrag:withPop:at:)]) {
            [delegate onTouchDrag:self 
                          withPop:pop 
                               at:position];
        }
	} else {
		PFDebug(@"Not dealing with multi touch now.");
	}
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	if (([touches count] == 1) && ([[event allTouches] count] == 1)) {
		UITouch *touch = [touches anyObject];
		CGPoint position = [touch locationInView: self];
        if (delegate && [delegate respondsToSelector:@selector(onTouchUp:withPop:at:)]) {
            [delegate onTouchUp:self 
                        withPop:pop 
                             at:position];
        }
	} else {
		PFDebug(@"Not dealing with multi touch now.");
	}
}

@end

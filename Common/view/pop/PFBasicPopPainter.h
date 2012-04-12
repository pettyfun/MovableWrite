//
//  PFBasicPopPainter.h
//  PettyFunPop
//
//  Created by YJ Park on 1/6/11.
//  Copyright 2011 PettyFun.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PFPopView.h"
#import "PFNoteBezierCellPainter.h"

@protocol PFPopStrokePainter<NSObject>
@required
-(void) paintStroke:(PFPopStroke *)stroke
            forCell:(PFPopCell *)cell
          onContext:(CGContextRef)context
         withConfig:(PFPopConfig *)config
         background:(BOOL)backgroud;
@end

@interface PFBasicPopPainter : NSObject<PFPopPainter> {
    PFPopStroke *currentStrokeRef;
    PFPopConfig *baseConfig;
    BOOL usingCellCache;
}
@property (assign) BOOL usingCellCache;

-(void) updateBaseConfig:(PFPopConfig *)config;

-(void) resetCell:(PFPopCell *)cell
       withConfig:(PFPopConfig *)config;

-(UIImage *) _getCellImage:(PFPopCell *)cell
                withConfig:(PFPopConfig *)config 
                background:(BOOL)background;

-(void) _paintCell:(PFPopCell *)cell
         onContext:(CGContextRef)context
            inRect:(CGRect)rect
        withConfig:(PFPopConfig *)config 
        usingCache:(BOOL)usingCache
        background:(BOOL)background;
    
@end

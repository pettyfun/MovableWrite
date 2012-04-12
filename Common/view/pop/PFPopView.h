//
//  PFPopView.h
//  PettyFunPop
//
//  Created by YJ Park on 1/6/11.
//  Copyright 2011 PettyFun.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PFPop.h"

@protocol PFPopPainter<NSObject>
@required
-(void) paintPop:(PFPop *)pop
        onContext:(CGContextRef)context 
       withConfig:(PFPopConfig *)config
           inRect:(CGRect)rect
         viewRect:(CGRect)viewRect;
-(void) paintEmptyPopOnContext:(CGContextRef)context 
                    withConfig:(PFPopConfig *)config 
                        inRect:(CGRect)rect
                      viewRect:(CGRect)viewRect;    
-(void) paintCell:(PFPopCell *)cell
        onContext:(CGContextRef)context
           inRect:(CGRect)rect
       withConfig:(PFPopConfig *)config;
@end

@class PFPopView;
@protocol PFPopViewDelegate<NSObject>
@optional
-(void) onTouchDown: (PFPopView *)popView 
           withPop:(PFPop *)pop at:(CGPoint)point;
-(void) onTouchDrag: (PFPopView *)popView 
           withPop:(PFPop *)pop at:(CGPoint)point;
-(void) onTouchUp: (PFPopView *)popView 
         withPop:(PFPop *)pop at:(CGPoint)point;
@end

@interface PFPopView : UIView {
    PFPop *pop;
    PFPopConfig *popConfig;
    id<PFPopPainter> popPainter;
    id<PFPopViewDelegate> delegate;
}
@property (nonatomic, retain) PFPop *pop;
@property (nonatomic, retain) PFPopConfig *popConfig;
@property (nonatomic, retain) id<PFPopPainter> popPainter;
@property (nonatomic, assign) id<PFPopViewDelegate> delegate;

-(void)drawRect:(CGRect)rect onContext:(CGContextRef)context;

@end

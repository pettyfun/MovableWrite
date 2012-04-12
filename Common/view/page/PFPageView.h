//
//  PFPageView.h
//  PettyFunNote
//
//  Created by YJ Park on 11/9/10.
//  Copyright 2010 PettyFun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

#import "PFPage.h"
#import "PFPageConfig.h"
#import "PFUtils.h"

#define PFPAGEVIEW_PINCH_DURATION 0.5f
#define PFPAGEVIEW_PAN_DURATION 0.3f
#define PFPAGEVIEW_TURN_PAGE_ROTATE_DURATION 0.5f
#define PFPAGEVIEW_TURN_PAGE_OVER_FACTOR 3.0f

#define PFPageViewTurnPageEnableTag 100001

@protocol PFPagePainter<NSObject>
@required
-(void) paintPage:(id<PFPage>)page
        onContext:(CGContextRef)context 
           inRect:(CGRect)rect
         viewRect:(CGRect)viewRect;
-(void) paintEmptyPageOnContext:(CGContextRef)context 
                         inRect:(CGRect)rect
                       viewRect:(CGRect)viewRect;    
-(void) paintCell:(id<PFCell>)cell
        onContext:(CGContextRef)context;
-(void) setConfig:(PFPageConfig *)config;
-(void) refreshConfig;
-(id<PFCell>) getCurrentCell;
-(void) setCurrentCell:(id<PFCell>)cell;
@end

@interface PFBasePagePainter : NSObject<PFPagePainter> {
    PFPageConfig *config;
    id<PFCell> currentCell;
}
@end

@class PFPageView;

@protocol PFPageViewDelegate<NSObject>
@optional
-(void) onResize: (PFPageView *)pageView
              to:(CGSize)viewSize;

-(void) onTouchDown: (PFPageView *)pageView
           withCell: (id<PFCell>)cell at:(CGPoint)point;

-(void) onTouchDrag: (PFPageView *)pageView
           withCell:(id<PFCell>)cell at:(CGPoint)point;
-(void) onTouchDrag: (PFPageView *)pageView
           withCell:(id<PFCell>)cell1 at:(CGPoint)point1
             onCell: (id<PFCell>)cell2 at:(CGPoint)point2;
-(void) onTouchDrag: (PFPageView *)pageView
           withCell:(id<PFCell>)cell1 at:(CGPoint)point1
             onPage: (id<PFPage>)page at:(CGPoint)point2;

-(void) onTouchUp: (PFPageView *)pageView
         withCell:(id<PFCell>)cell at:(CGPoint)point;
-(void) onTouchUp: (PFPageView *)pageView 
         withCell:(id<PFCell>)cell1 at:(CGPoint)point1
           onCell: (id<PFCell>)cell2 at:(CGPoint)point2;
-(void) onTouchUp: (PFPageView *)pageView 
         withCell:(id<PFCell>)cell1 at:(CGPoint)point1
           onPage: (id<PFPage>)page at:(CGPoint)point2;
-(void) onTouchUp: (PFPageView *)pageView
    withNothingAt:(CGPoint)point;

-(void) onTouchDown: (PFPageView *)pageView 
           withPage:(id<PFPage>)page at:(CGPoint)point;
-(void) onTouchDrag: (PFPageView *)pageView 
           withPage:(id<PFPage>)page at:(CGPoint)point;
-(void) onTouchUp: (PFPageView *)pageView 
         withPage:(id<PFPage>)page at:(CGPoint)point;

-(void) onPinch:(PFPageView *)pageView
         sender:(UIPinchGestureRecognizer *)sender;
-(void) onPan:(PFPageView *)pageView
         sender:(UIPanGestureRecognizer *)sender;

-(BOOL) canTurnPage:(PFPageView *)pageView
               back:(BOOL)back;
-(BOOL) doTurnPage:(PFPageView *)pageView
              back:(BOOL)back;
@end


@interface PFPageView : UIView <UIGestureRecognizerDelegate> {
    BOOL handleTouchEvent;
    BOOL handlePinch;
    BOOL handlePan;
    
    PFPageConfig *pageConfig;
    id<PFPagePainter> pagePainter;
    id<PFPage> page;
    id<PFPageViewDelegate> delegate;
    
    id touchDownObject;
    
    CGSize lastSize;
    
    UIImageView *turnPageLeft;
    UIImageView *turnPageRight;
}
@property (nonatomic, assign) BOOL handleTouchEvent;
@property (nonatomic, assign) BOOL handlePan;
@property (nonatomic, assign) BOOL handlePinch;
@property (nonatomic, retain) PFPageConfig *pageConfig;
@property (nonatomic, retain) id<PFPagePainter> pagePainter;
@property (nonatomic, retain) id<PFPage> page;
@property (nonatomic, retain) id touchDownObject;
@property (nonatomic, assign) id<PFPageViewDelegate> delegate;

-(void) repaintCell:(id<PFCell>)cell;
-(void) drawRect:(CGRect)rect onContext:(CGContextRef)context;

-(id) getCellOrPage:(CGPoint)position;
-(CGPoint) getRelativePosition:(CGPoint)point ofCell:(id<PFCell>)cell;

-(void) initGestures;

-(void) _resetTurnPages:(BOOL)hide;
-(CGFloat) _updateTurnPages:(CGFloat)offset;
-(void) _rotateTurnPage:(BOOL)enable left:(BOOL)left;

-(void) setTurnPageLeft:(UIImage *)left right:(UIImage *)right;

@end




//
//  PFPageViewConfig.m
//  PettyFunNote
//
//  Created by YJ Park on 11/9/10.
//  Copyright 2010 PettyFun. All rights reserved.
//

#import "PFPageView.h"
#import "PFUtils.h"

@implementation PFBasePagePainter
-(id) init {
    if ((self = [super init])) {
        currentCell = nil;
    }
    return self;
}

-(void) dealloc {
    [config release];
    [currentCell release];
    [super dealloc];
}

-(void) setConfig:(PFPageConfig *)newConfig {
    if (config != newConfig) {
        [config release];
        config = [newConfig retain];
        [self refreshConfig];
    }
}

-(void) refreshConfig {
}


-(void) setCurrentCell:(id<PFCell>)cell {
    if (currentCell != cell) {
        if (currentCell) {
            [currentCell release];
        }
        if (cell) {
            currentCell = [cell retain];
        } else {
            currentCell = nil;
        }
    }
}

-(id<PFCell>) getCurrentCell {
    return currentCell;
}

-(void) paintPage:(id<PFPage>)page
        onContext:(CGContextRef)context 
           inRect:(CGRect)rect
         viewRect:(CGRect)viewRect {
    [self paintEmptyPageOnContext:context
                           inRect:rect
                         viewRect:viewRect];
}

-(void) paintEmptyPageOnContext:(CGContextRef)context 
                         inRect:(CGRect)rect
                       viewRect:(CGRect)viewRect {
}
-(void) paintCell:(id<PFCell>)cell
        onContext:(CGContextRef)context {
}
@end

@implementation PFPageView
@synthesize handleTouchEvent;
@synthesize handlePan;
@synthesize handlePinch;
@synthesize pageConfig;
@synthesize pagePainter;
@synthesize page;
@synthesize touchDownObject;
@synthesize delegate;

-(id) init {
    if ((self = [super init])) {
        self.clearsContextBeforeDrawing = YES;
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

-(void) dealloc {
    [turnPageLeft release];
    [turnPageRight release];
    [pageConfig release];
    [pagePainter release];
    [page release];
    [touchDownObject release];
    [super dealloc];
}

-(void) setPageConfig:(PFPageConfig *)newConfig {
    if (pageConfig != newConfig) {
        [pageConfig release];
        pageConfig = [newConfig retain];
        if (pagePainter) {
            [pagePainter setConfig:pageConfig];
        }
    }
}

-(void) setPagePainter:(id<PFPagePainter>)newPainter {
    if (pagePainter != newPainter) {
        [pagePainter release];
        pagePainter = [newPainter retain];
        if (pagePainter) {
            [pagePainter setConfig:pageConfig];
        }
    }    
}

-(void) setTurnPageLeft:(UIImage *)left right:(UIImage *)right {
    if (left) {
        if (turnPageLeft) {
            [turnPageLeft setImage:left];
            turnPageLeft.frame = CGRectMake(0.0f, 0.0f, left.size.width, left.size.height);
        } else {
            turnPageLeft = [[UIImageView alloc] initWithImage:left];
            [self addSubview:turnPageLeft];
        }
    }
    if (right) {
        if (turnPageRight) {
            [turnPageRight setImage:right];
            turnPageRight.frame = CGRectMake(0.0f, 0.0f, right.size.width, right.size.height);
        } else {
            turnPageRight = [[UIImageView alloc] initWithImage:right];
            [self addSubview:turnPageRight];
        }
    }
    [self _resetTurnPages:YES];
}

-(void)drawRect:(CGRect)rect {
    //PFDebug(@"PFPageView.drawRect: %@, rect=%@", self, NSStringFromCGRect(rect));
    
    if ((lastSize.width != self.frame.size.width)
        || (lastSize.height != self.frame.size.height)) {
        lastSize = self.frame.size;
        if (delegate && [delegate respondsToSelector:@selector(onResize:to:)]) {
            [delegate onResize:self to:lastSize];
        }
    }
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    [self drawRect:rect onContext:context];
}

-(void)drawRect:(CGRect)rect onContext:(CGContextRef)context {
    if (pagePainter) {
        if (page) {
            CGRect pageRect = [page getRect];
            CGRect updateRect = CGRectMake(rect.origin.x - pageRect.origin.x,
                                           rect.origin.y - pageRect.origin.y,
                                           rect.size.width, rect.size.height);
            CGRect viewRect = CGRectMake(-pageRect.origin.x,
                                         -pageRect.origin.y,
                                         self.frame.size.width,
                                         self.frame.size.height);
            CGContextTranslateCTM(context, pageRect.origin.x, pageRect.origin.y);
            
            DECLARE_PFUTILS
            [utils markTime];
            
            [pagePainter paintPage:page 
                         onContext:context 
                            inRect:updateRect
                          viewRect:viewRect];
            CGContextTranslateCTM(context, -pageRect.origin.x, -pageRect.origin.y);

            [utils logTime:@"Slow Paint Page" longerThan:0.1f];
            [utils markTime];

            NSArray *paragraphes = [page getParagraphes];
            NSInteger cellNum = 0;
            for (id<PFParagraph> paragraph in paragraphes) {
                NSArray *cells = [paragraph getCells];
                for (id<PFCell> cell in cells) {
                    CGRect cellRect = [cell getRect];
                    if ((cellRect.size.width <= 0.0f) || (cellRect.size.height <= 0.0f)) {
                        continue;
                    }
                    if (CGRectIntersectsRect(rect, cellRect)) {
                        cellNum ++;
                        float offsetX = cellRect.origin.x;
                        float offsetY = cellRect.origin.y;
                        CGContextTranslateCTM(context, offsetX, offsetY);
                        [pagePainter paintCell:cell
                                     onContext:context];                        
                        CGContextTranslateCTM(context, -offsetX, -offsetY);
                    }
                }
            }            
            [utils logTime:NSFormat(@"Slow Paint Cells: %d", cellNum) longerThan:0.1f];;
        } else {
            [pagePainter paintEmptyPageOnContext:context 
                                          inRect:rect
                                        viewRect:self.frame];            
        }

    }
}

-(id) getCellOrPage:(CGPoint)position {
    if (page) {
        NSArray *paragraphes = [page getParagraphes];
        for (id<PFParagraph> paragraph in paragraphes) {
            NSArray *cells = [paragraph getCells];
            for (id<PFCell> cell in cells) {
                CGRect cellRect = [cell getRect];
                if (CGRectContainsPoint(cellRect, position)) {
                    return cell;
                }
            }
        }
        if (CGRectContainsPoint([page getRect], position)) {
            return page;
        }
    }
    return nil;
}

-(CGPoint) getRelativePosition:(CGPoint)point ofCell:(id<PFCell>)cell {
    CGRect cellRect = [cell getRect];
    return CGPointMake((point.x - cellRect.origin.x) / pageConfig.factor,
                       (point.y - cellRect.origin.y) / pageConfig.factor); 
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if (!handleTouchEvent) return;
    
	if (([touches count] == 1) && ([[event allTouches] count] == 1)) {
		UITouch *touch = [touches anyObject];
		CGPoint position = [touch locationInView: self];
        id cellOrPage = [self getCellOrPage:position];
        if (cellOrPage) {
            self.touchDownObject = cellOrPage;
            if ([[cellOrPage class] conformsToProtocol: @protocol(PFCell)]) {
                if (delegate && [delegate respondsToSelector:@selector(onTouchDown:withCell:at:)]) {
                    [delegate onTouchDown:self 
                                 withCell:(id<PFCell>)touchDownObject 
                                       at:[self getRelativePosition:position ofCell:(id<PFCell>)touchDownObject]];
                }
            } else if ([[cellOrPage class] conformsToProtocol: @protocol(PFPage)]){
                if (delegate && [delegate respondsToSelector:@selector(onTouchDown:withPage:at:)]) {
                    [delegate onTouchDown:self 
                                 withPage:(id<PFPage>)touchDownObject 
                                       at:position];
                }
            }
        }
	} else {
		PFDebug(@"Not dealing with multi touch now.");
	}
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    if (!handleTouchEvent) return;

	if (([touches count] == 1) && ([[event allTouches] count] == 1)) {
		UITouch *touch = [touches anyObject];
		//CGPoint previous = [touch previousLocationInView: self];
		CGPoint position = [touch locationInView: self];
        id cellOrPage = [self getCellOrPage:position];
        if ([[touchDownObject class] conformsToProtocol: @protocol(PFPage)]) {
            if (delegate && [delegate respondsToSelector:@selector(onTouchDrag:withPage:at:)]) {
                [delegate onTouchDrag:self 
                             withPage:(id<PFPage>)touchDownObject 
                                   at:position];
            }
        } else if (cellOrPage == touchDownObject) {
            if (delegate && [delegate respondsToSelector:@selector(onTouchDrag:withCell:at:)]) {
                [delegate onTouchDrag:self 
                             withCell:touchDownObject 
                                   at:[self getRelativePosition:position ofCell:(id<PFCell>)touchDownObject]];
            }            
        } else if ([[cellOrPage class] conformsToProtocol: @protocol(PFCell)]) {
            if (delegate && [delegate respondsToSelector:@selector(onTouchDrag:withCell:at:onCell:at:)]) {
                [delegate onTouchDrag:self 
                             withCell:touchDownObject 
                                   at:[self getRelativePosition:position ofCell:(id<PFCell>)touchDownObject] 
                               onCell:cellOrPage 
                                   at:[self getRelativePosition:position ofCell:(id<PFCell>)cellOrPage]];
            }            
        } else if ([[cellOrPage class] conformsToProtocol: @protocol(PFPage)]) {
            if (delegate && [delegate respondsToSelector:@selector(onTouchDrag:withCell:at:onPage:at:)]) {
                [delegate onTouchDrag:self 
                             withCell:touchDownObject 
                                   at:[self getRelativePosition:position ofCell:(id<PFCell>)touchDownObject] 
                               onPage:cellOrPage 
                                   at:position];
            }            
        }
	} else {
		PFDebug(@"Not dealing with multi touch now.");
	}
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if (!handleTouchEvent) return;

	if (([touches count] == 1) && ([[event allTouches] count] == 1)) {
		UITouch *touch = [touches anyObject];
		//CGPoint previous = [touch previousLocationInView: self];
		CGPoint position = [touch locationInView: self];
        id cellOrPage = [self getCellOrPage:position];
        if ([[touchDownObject class] conformsToProtocol: @protocol(PFPage)]) {
            if (delegate && [delegate respondsToSelector:@selector(onTouchUp:withPage:at:)]) {
                [delegate onTouchUp:self 
                           withPage:(id<PFPage>)touchDownObject 
                                 at:position];
            }
        } else if (cellOrPage == touchDownObject) {
            if (delegate && [delegate respondsToSelector:@selector(onTouchUp:withCell:at:)]) {
                [delegate onTouchUp:self 
                             withCell:touchDownObject 
                                   at:[self getRelativePosition:position ofCell:(id<PFCell>)touchDownObject]];
            }            
        } else if ([[cellOrPage class] conformsToProtocol: @protocol(PFCell)]) {
            if (delegate && [delegate respondsToSelector:@selector(onTouchUp:withCell:at:onCell:at:)]) {
                [delegate onTouchUp:self 
                             withCell:touchDownObject 
                                   at:[self getRelativePosition:position ofCell:(id<PFCell>)touchDownObject] 
                               onCell:cellOrPage 
                                   at:[self getRelativePosition:position ofCell:(id<PFCell>)cellOrPage]];
            }            
        } else if ([[cellOrPage class] conformsToProtocol: @protocol(PFPage)]) {
            if (delegate && [delegate respondsToSelector:@selector(onTouchUp:withCell:at:onPage:at:)]) {
                [delegate onTouchUp:self 
                           withCell:touchDownObject 
                                 at:[self getRelativePosition:position ofCell:(id<PFCell>)touchDownObject] 
                             onPage:cellOrPage 
                                 at:position];
            }            
        } else {
            if (delegate && [delegate respondsToSelector:@selector(onTouchUp:withNothingAt:)]) {
                [delegate onTouchUp:self 
                      withNothingAt:position];
            }                                    
        }
        self.touchDownObject = nil;
	} else {
		PFDebug(@"Not dealing with multi touch now.");
	}
}

-(void) repaintCell:(id<PFCell>)cell {
    if (page) {
        [self setNeedsDisplayInRect:[page getUpdatedRect]];
        [page setUpdatedRect:CGRectNull];
    }
    if (cell) {
        [self setNeedsDisplayInRect:[cell getRect]];
    }
}

#pragma mark -
#pragma mark Gestures

-(void) initGestures {
    UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] 
                                              initWithTarget:self
                                              action:@selector(handlePinchGesture:)];
    [self addGestureRecognizer:pinchGesture]; 
    pinchGesture.delegate = self;
    [pinchGesture release];
    
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc]
                                          initWithTarget:self
                                          action:@selector(handlePanGesture:)];
    [panGesture setMaximumNumberOfTouches:1];
    panGesture.delegate = self;
    [self addGestureRecognizer:panGesture];
    [panGesture release];
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if ([gestureRecognizer isKindOfClass:[UIPinchGestureRecognizer class]]) {
        return handlePinch;
    } else if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        return handlePan;
    }
    return YES;
}

- (void)handlePinchGesture:(UIPinchGestureRecognizer *)sender {
    if (!handlePinch) return;
    
    if (UIGestureRecognizerStateBegan == [sender state]) {
        [self _resetTurnPages:YES];
    } else if (UIGestureRecognizerStateChanged == [sender state]) {
        self.transform = CGAffineTransformMakeScale(sender.scale, sender.scale);
    } else if (UIGestureRecognizerStateEnded == [sender state]) {
        PFUTILS_delayWithInterval(0.0f, nil, _onPinchEnded:);        
    } else if (UIGestureRecognizerStateCancelled == [sender state]) {
        self.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
    }

    if (delegate && [delegate respondsToSelector:@selector(onPinch:sender:)]) {
        [delegate onPinch:self sender:sender];
    }
}

- (void)_onPinchEnded:(NSTimer *)timer {
    [UIView transitionWithView:self
                      duration:PFPAGEVIEW_PINCH_DURATION
                       options:UIViewAnimationOptionTransitionNone
                                &UIViewAnimationOptionCurveEaseInOut
                    animations:^{
                        self.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
                        if (delegate && [delegate respondsToSelector:@selector(onPinch:sender:)]) {
                            [delegate onPinch:self sender:nil];
                        }                        
                    }
                    completion:^(BOOL finished){
                    }];
}

- (void)handlePanGesture:(UIPanGestureRecognizer *)sender {
    if (!handlePan) return;

    if (UIGestureRecognizerStateBegan == [sender state]) {
        [self _resetTurnPages:YES];
    } else if (UIGestureRecognizerStateChanged == [sender state]) {
        CGPoint translation = [sender translationInView:[self superview]];
        self.transform = CGAffineTransformMakeTranslation(
                         [self _updateTurnPages:translation.x], 0.0f);  
    } else if (UIGestureRecognizerStateEnded == [sender state]) {
        CGPoint translation = [sender translationInView:[self superview]];
        PFUTILS_delayWithInterval(0.0f, [NSNumber numberWithFloat:translation.x], _onPanEnded:);        
    } else if (UIGestureRecognizerStateCancelled == [sender state]) {
        self.transform = CGAffineTransformMakeTranslation(0.0f, 0.0f);
        [self _resetTurnPages:YES];
    }

    if (delegate && [delegate respondsToSelector:@selector(onPan:sender:)]) {
        [delegate onPan:self sender:sender];
    }    
}

-(CGFloat) _updateTurnPages:(CGFloat)offset {
    CGFloat result = offset;
    BOOL canTurnPage = NO;
    if (delegate && [delegate respondsToSelector:@selector(canTurnPage:back:)]) {
        canTurnPage = [delegate canTurnPage:self back:(offset > 0)];
    }
    
    if (canTurnPage && turnPageLeft && (offset > 0)) {            
        turnPageLeft.hidden = NO;
        result = turnPageLeft.frame.size.width;
        [self _rotateTurnPage:(offset > result) left:YES];
        if (offset > result) {
            result = result + (offset - result) / PFPAGEVIEW_TURN_PAGE_OVER_FACTOR;
        } else {
            result = offset;
        }
    } else if (canTurnPage && turnPageRight && (offset < 0)) {
        turnPageRight.hidden = NO;
        result = - turnPageLeft.frame.size.width;
        [self _rotateTurnPage:(offset < result) left:NO];
        if (offset < result) {
            result = result + (offset - result) / PFPAGEVIEW_TURN_PAGE_OVER_FACTOR;
        } else {
            result = offset;
        }
    } else if (!canTurnPage) {
        result = offset / PFPAGEVIEW_TURN_PAGE_OVER_FACTOR;
    }
    return result;
}

-(void) _rotateTurnPage:(BOOL)enable left:(BOOL)left {
    UIImageView *turnPage = left ? turnPageLeft : turnPageRight;
    if (enable && (turnPage.tag == PFPageViewTurnPageEnableTag)) return;
    if (!enable && (turnPage.tag != PFPageViewTurnPageEnableTag)) return;
    if (enable) {
        turnPage.tag = PFPageViewTurnPageEnableTag;
    } else {
        turnPage.tag = PFPageViewTurnPageEnableTag - 1;
    }          
    //has to use the old way for thread issue;
    [UIView beginAnimations:@"TURNPAGE_ROTATION" context:NULL];
    if (turnPage.tag == PFPageViewTurnPageEnableTag) {
        CGFloat rotation = PF_PI / 2.0f;
        if (!left) rotation *= -1;
        turnPage.transform = CGAffineTransformMakeRotation(rotation);
        
        rotation = PF_PI;
        if (!left) rotation *= -1;
        turnPage.transform = CGAffineTransformMakeRotation(rotation);
    } else {
        CGFloat rotation = PF_PI / 2.0f;
        if (!left) rotation *= -1;
        turnPage.transform = CGAffineTransformMakeRotation(rotation);
        
        turnPage.transform = CGAffineTransformMakeRotation(0.0f);                            
    }
    [UIView commitAnimations];
}

-(BOOL) _turnPages:(CGFloat)offset {
    BOOL canTurnPage = NO;
    if (delegate && [delegate respondsToSelector:@selector(canTurnPage:back:)]) {
        canTurnPage = [delegate canTurnPage:self back:(offset > 0)];
    }
    if (canTurnPage) {
        if (fabs(offset) > turnPageLeft.frame.size.width) {
            if (delegate && [delegate respondsToSelector:@selector(doTurnPage:back:)]) {
                return [delegate doTurnPage:self back:(offset > 0)];
            }
        }
    }
    return NO;
}

-(void) _resetTurnPages:(BOOL)hide {
    if (turnPageLeft) {
        turnPageLeft.tag = PFPageViewTurnPageEnableTag - 1;
        turnPageLeft.transform = CGAffineTransformMakeRotation(0.0f);                            
        CGSize size = turnPageLeft.frame.size;
        turnPageLeft.frame = CGRectMake(
                                        -size.width,
                                        (self.frame.size.height - size.height) * (1.0f - PF_GOLDEN),
                                        size.width,
                                        size.height
                                        );
        if (hide) turnPageLeft.hidden = YES;
    }
    if (turnPageRight) {
        turnPageRight.tag = PFPageViewTurnPageEnableTag - 1;
        turnPageRight.transform = CGAffineTransformMakeRotation(0.0f);                            
        CGSize size = turnPageRight.frame.size;
        turnPageRight.frame = CGRectMake(
                                         self.frame.size.width,
                                         (self.frame.size.height - size.height) * (1.0f - PF_GOLDEN),
                                         size.width,
                                         size.height
                                         );
        if (hide) turnPageRight.hidden = YES;
    }
}

- (void)_onPanEnded:(NSTimer *)timer {
    CGFloat offset = [(NSNumber *)timer.userInfo floatValue];
    BOOL turned = [self _turnPages:offset];
    CGFloat destX = self.frame.size.width;
    if (offset > 0.0f) {
        if (turnPageLeft) {
            destX += turnPageLeft.frame.size.width;
        }
    } else if (offset < 0.0f) {
        if (turnPageRight) {
            destX += turnPageRight.frame.size.width;
        }
        destX *= -1;        
    }
    CGFloat duration = PFPAGEVIEW_PAN_DURATION;
    if (!turned) {
        duration /= 2.0f;
    }
    [UIView transitionWithView:self
                      duration:duration
                       options:UIViewAnimationOptionTransitionNone
                                &UIViewAnimationOptionCurveEaseIn
                    animations:^{
                        if (turned) {
                            self.transform = CGAffineTransformMakeTranslation(destX, 0.0f);                            
                        } else {
                            self.transform = CGAffineTransformMakeTranslation(0.0f, 0.0f);                            
                            [self _resetTurnPages:NO];
                        }
                    }
                    completion:^(BOOL finished){
                        if (turned) {
                            self.transform = CGAffineTransformMakeTranslation(0.0f, 0.0f);                            
                            [self _resetTurnPages:YES];
                        }
                        if (delegate && [delegate respondsToSelector:@selector(onPan:sender:)]) {
                            [delegate onPan:self sender:nil];
                        }
                    }];
}

@end

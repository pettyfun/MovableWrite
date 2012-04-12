//
//  PFNoteCellPainter.h
//  PettyFunNote
//
//  Created by YJ Park on 2/24/11.
//  Copyright 2011 PettyFun.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PFPageView.h"
#import "PFNoteTheme.h"
#import "PFNoteStroke.h"

#define PFNOTE_CELL_CACHE_PREFIX @"cell_"

@protocol PFNoteStrokePainter<NSObject>
@required
-(void) paintStroke:(PFNoteStroke *)stroke
            forCell:(id<PFCell>)cell
          onContext:(CGContextRef)context
         withConfig:(PFPageConfig *)config 
           andTheme:(PFNoteTheme *)theme
              final:(BOOL)final;    
@end

@interface PFNoteCellPainter : NSObject {
    id<PFNoteStrokePainter> strokePainter;
    
    PFNoteStroke *currentStrokeRef;
}
@property (nonatomic, retain) id<PFNoteStrokePainter> strokePainter;

-(void) setCurrentStroke:(PFNoteStroke *)stroke
              withConfig:(PFPageConfig *)config 
          andCurrentCell:(id<PFCell>)currentCell
                andTheme:(PFNoteTheme *)theme;

-(void) clearCellCache:(id<PFCell>)cell;

-(BOOL) isCellInCache:(id<PFCell>)cell;
-(void) cacheCell:(id<PFCell>)cell
       withConfig:(PFPageConfig *)config 
         andTheme:(PFNoteTheme *)theme
     forceRepaint:(BOOL)forceRepaint;

-(void) paintCell:(id<PFCell>)cell
        onContext:(CGContextRef)context
       withConfig:(PFPageConfig *)config 
   andCurrentCell:(id<PFCell>)currentCell
         andTheme:(PFNoteTheme *)theme
       usingCache:(BOOL)usingCache;

-(UIImage *) _getCellImage:(id<PFCell>)cell
                withConfig:(PFPageConfig *)config 
                  andTheme:(PFNoteTheme *)theme
              forceRepaint:(BOOL)forceRepaint;


@end

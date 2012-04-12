//
//  PFNotePagePainter.h
//  PettyFunNote
//
//  Created by YJ Park on 12/2/10.
//  Copyright 2010 PettyFun. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "PFPageView.h"
#import "PFNoteCellPainter.h"

#define PFNOTE_PAGE_PAINTER_LOADING_CONCURRENT_COUNT 1

extern NSString *const PFNotePagePainterLoadCellNotification;
extern NSString *const PFNotePagePainterClearCellCacheNotification;

@class PFNoteGridPainter;

@interface PFNotePagePainter : PFBasePagePainter {
    PFNoteCellPainter *cellPainter;
    BOOL usingCellCache;
    NSOperationQueue* loadingQueue;
    NSMutableSet *loadingCells;
    
    PFNoteTheme *theme; //Weak Reference
    PFNoteGridPainter *gridPainter; //Weak Reference
    
    NSString *loadNotification;
    NSString *clearNotification;    
}
@property (assign, readonly) BOOL usingCellCache;
@property (nonatomic, retain) NSString *loadNotification;
@property (nonatomic, retain) NSString *clearNotification;

-(void) loadCell:(id<PFCell>)cell;

-(void) setUsingCellCache:(BOOL)value;
-(void) setCurrentStroke:(PFNoteStroke *)stroke;
-(void) clearCellCache:(id<PFCell>)cell;

@end

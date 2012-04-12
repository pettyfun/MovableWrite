//
//  PFNotePagePainter.m
//  PettyFunNote
//
//  Created by YJ Park on 12/2/10.
//  Copyright 2010 PettyFun. All rights reserved.
//

#import "PFNotePagePainter.h"
#import "PFNoteConfig.h"
#import "PFNotePainterFactory.h"
#import "PFNoteCellPainter.h"

NSString *const PFNotePagePainterLoadCellNotification = @"PFNotePagePainterLoadCellNotification";
NSString *const PFNotePagePainterClearCellCacheNotification = @"PFNotePagePainterClearCellCacheNotification";

@implementation PFNotePagePainter
@synthesize loadNotification;
@synthesize clearNotification;
@synthesize usingCellCache;

-(id) init {
    if ((self = [super init])) {
        cellPainter = [[PFNoteCellPainter alloc] init];
        usingCellCache = NO;
    }
    return self;
}

-(void) dealloc {
    [loadNotification release];
    [clearNotification release];
    [self setUsingCellCache:NO];
    [cellPainter release];
    [loadingQueue release];
    [super dealloc];
}

-(void) setUsingCellCache:(BOOL)value {
    if (usingCellCache == value) {
        return;
    }
    usingCellCache = value;
    if (usingCellCache) {
        loadingCells = [[NSMutableSet alloc] init];
        loadingQueue = [[NSOperationQueue alloc] init];
        [loadingQueue setMaxConcurrentOperationCount:PFNOTE_PAGE_PAINTER_LOADING_CONCURRENT_COUNT];
        NSString *notification = clearNotification;
        if (notification == nil) {
            notification = PFNotePagePainterClearCellCacheNotification;
        }
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onClearCellsCache:)
                                                     name:notification
                                                   object:nil];
    } else {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        if (loadingCells) {
            [loadingCells removeAllObjects];
            loadingCells = nil;
        }
        if (loadingQueue) {
            [loadingQueue cancelAllOperations];
            [loadingQueue release];
            loadingQueue = nil;
        }
    }
}

-(void) onClearCellsCache: (NSNotification *)notification {
    if (loadingQueue) {
        [loadingQueue cancelAllOperations];
        @synchronized(loadingCells) {
            [loadingCells removeAllObjects];
        }
    }
}

-(void) paintPage:(id<PFPage>)page
        onContext:(CGContextRef)context 
           inRect:(CGRect)rect
         viewRect:(CGRect)viewRect {
    if (config.showingWatermark) {
        [theme paintImageAsPattern:PFNoteThemeImageWatermark
                         onContext:context 
                            inRect:viewRect];
    }
    if (gridPainter) {
        [gridPainter paintPage:page
                     onContext:context
                    withConfig:config
                        inRect:rect
                      viewRect:viewRect
                     withTheme:theme];
    }
}

-(void) refreshConfig {
    if (config) {
        DECLARE_PFNOTE_PAINTER_FACTORY
        theme = [painterFactory getTheme:config];
        cellPainter.strokePainter = [painterFactory getStrokePainter:config];
        gridPainter = [painterFactory getGridPainter:config];
    }
}

-(void) paintCell:(id<PFCell>)cell
        onContext:(CGContextRef)context {
    if (!usingCellCache || 
        ([cell isCellLoaded] && [cellPainter isCellInCache:cell])) {
        [cellPainter paintCell:cell
                     onContext:context
                    withConfig:config
                andCurrentCell:currentCell
                      andTheme:theme
                    usingCache:usingCellCache];
    } else {
        /*
        [theme paintImageAsPattern:PFNoteThemeImageDisplayLoadingCell 
                         onContext:context 
                            inRect:[cell getContentRectWithConfig:config]];
         */
        /*
        UIColor *color = [[theme getTextColor] colorWithAlphaComponent:0.02f];
        CGContextSetFillColorWithColor(context, color.CGColor);
        CGRect rect = CGRectMake(0.0f, 0.0f,
                                 [cell getRect].size.width, 
                                 [cell getRect].size.height);
        CGContextFillRect(context, rect);
        */
        [self loadCell:cell];
    }
}

-(void) loadCell:(id<PFCell>)cell {
    @synchronized(loadingCells) {
        if ([loadingCells containsObject:cell]) return;
        [loadingCells addObject:cell];
    }
    
    NSBlockOperation *loadOp = [NSBlockOperation blockOperationWithBlock:^{
        if (usingCellCache) {
            [cell loadCell];

            //put it here, otherwise the new strokes after the paint might be ignored
            @synchronized(loadingCells) {
                [loadingCells removeObject:cell];
            }
            
            if (usingCellCache) {
                [cellPainter cacheCell:cell
                            withConfig:config
                              andTheme:theme
                          forceRepaint:currentCell == cell];
            }

            NSString *notification = loadNotification;
            if (notification == nil) {
                notification = PFNotePagePainterLoadCellNotification;
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:notification object:cell];
        }
    }];
    [loadingQueue addOperation:loadOp];
}

-(void) setCurrentStroke:(PFNoteStroke *)stroke {
    if (usingCellCache && currentCell) {
        [cellPainter setCurrentStroke:stroke
                           withConfig:config
                       andCurrentCell:currentCell
                             andTheme:theme];
        if (!stroke) {
            [self loadCell:currentCell];
            //[cellPainter clearCellCache:currentCell];
        }
    }
}

-(void) clearCellCache:(id<PFCell>)cell {
    [cellPainter clearCellCache:cell];
}

@end

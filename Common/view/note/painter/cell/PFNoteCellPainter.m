//
//  PFNoteCellPainter.m
//  PettyFunNote
//
//  Created by YJ Park on 2/24/11.
//  Copyright 2011 PettyFun.com. All rights reserved.
//

#import "PFNoteCellPainter.h"


@implementation PFNoteCellPainter
@synthesize strokePainter;

-(void) dealloc {
    [strokePainter release];
    [super dealloc];
}

-(void) clearCellCache:(id<PFCell>)cell {
    DECLARE_PFUTILS
    NSString *cellCacheKey = NSFormat(@"%@%d", PFNOTE_CELL_CACHE_PREFIX, [cell hash]);
    [utils setCache:nil forKey:cellCacheKey];
    PFDebug(@"cache cleared: %@", cellCacheKey);
}

-(BOOL) isCellInCache:(id<PFCell>)cell {
    DECLARE_PFUTILS
    NSString *cellCacheKey = NSFormat(@"%@%d", PFNOTE_CELL_CACHE_PREFIX, [cell hash]);
    UIImage *image = [utils getCache:cellCacheKey];
    return (image != nil);
}

-(void) cacheCell:(id<PFCell>)cell
       withConfig:(PFPageConfig *)config 
         andTheme:(PFNoteTheme *)theme 
     forceRepaint:(BOOL)forceRepaint {
    [self _getCellImage:cell withConfig:config
               andTheme:theme forceRepaint:forceRepaint];
}

-(void) setCurrentStroke:(PFNoteStroke *)stroke
              withConfig:(PFPageConfig *)config 
          andCurrentCell:(id<PFCell>)currentCell
                andTheme:(PFNoteTheme *)theme {
    if ((stroke == nil) && currentStrokeRef && currentCell) {
        //Has duplication here with paintCell and _getImage, quite hard
        //to clean it, and not really worth it, so leave this now.
        PFNoteCell *cell = currentCell;
        CGRect cellRect = [cell getRect];
        UIGraphicsBeginImageContext(cellRect.size);
        CGContextRef context = UIGraphicsGetCurrentContext();        
        CGContextTranslateCTM(context, 0.0f, cellRect.size.height);
        CGContextScaleCTM(context, 1.0f, -1.0f);
        
        DECLARE_PFUTILS
        NSString *cellCacheKey = NSFormat(@"%@%d", PFNOTE_CELL_CACHE_PREFIX, [cell hash]);
        UIImage *image = [[[utils getCache:cellCacheKey] retain] autorelease];
        if (image) {
            CGRect imageRect = CGRectMake(0.0f, 0.0f, image.size.width, image.size.height);
            CGContextDrawImage(context, imageRect, image.CGImage);
        }
        CGContextSetLineCap(context, kCGLineCapRound);
        CGContextSetLineJoin(context, kCGLineJoinRound);

        [strokePainter paintStroke:currentStrokeRef forCell:cell onContext:context
                        withConfig:config andTheme:theme final:NO];
        [strokePainter paintStroke:currentStrokeRef forCell:cell onContext:context
                        withConfig:config andTheme:theme final:YES];
        
        UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        [utils setCache:newImage forKey:cellCacheKey];
    }
    currentStrokeRef = stroke;
}

-(void) paintCell:(id<PFCell>)cell
        onContext:(CGContextRef)context
       withConfig:(PFPageConfig *)config 
   andCurrentCell:(id<PFCell>)currentCell
         andTheme:(PFNoteTheme *)theme
       usingCache:(BOOL)usingCache {
    CGRect cellRect = [cell getRect];
    
    if (usingCache) {
        if ([cell isControlCharactor]) {
            if (config.showingControlCharactors) {
                [theme paintControlCharactor:cell
                                   onContext:context 
                                  withConfig:config]; 
            }
        } else {
            UIImage *cellImage = [[[self _getCellImage:cell
                                            withConfig:config
                                              andTheme:theme
                                          forceRepaint:NO] retain] autorelease];
            if (cellImage) {
                CGRect imageRect = CGRectMake(0.0f, 0.0f, cellImage.size.width, cellImage.size.height);
                CGContextDrawImage(context, imageRect, cellImage.CGImage);
            }
        }        
    } else {
        if ([cell isControlCharactor]) {
            if (config.showingControlCharactors) {
                [theme paintControlCharactor:cell
                                   onContext:context 
                                  withConfig:config];                                
            }
        } else {
            CGContextSetLineCap(context, kCGLineCapRound);
            CGContextSetLineJoin(context, kCGLineJoinRound);
            
            PFNoteCell *noteCell = (PFNoteCell *)cell;
            NSArray *strokes = [noteCell.strokes copy]; //can be changed during painting
            for (PFNoteStroke *stroke in strokes) {
                if (stroke != currentStrokeRef) {
                    [strokePainter paintStroke:stroke forCell:cell onContext:context
                           withConfig:config andTheme:theme final:NO];
                }
            }        
            
            for (PFNoteStroke *stroke in strokes) {
                if (stroke != currentStrokeRef) {
                    [strokePainter paintStroke:stroke forCell:cell onContext:context
                           withConfig:config andTheme:theme final:YES];
                }
            }        
        }
    } 
    if (currentCell == cell) {
        CGContextSetLineCap(context, kCGLineCapRound);
        CGContextSetLineJoin(context, kCGLineJoinRound);
        if (currentStrokeRef) {
            [strokePainter paintStroke:currentStrokeRef forCell:cell onContext:context
                            withConfig:config andTheme:theme final:NO];
            [strokePainter paintStroke:currentStrokeRef forCell:cell onContext:context
                            withConfig:config andTheme:theme final:YES];
        }
        float lineWidth = 0.4f;
        CGContextSetLineWidth(context, lineWidth);
        UIColor *currentColor = theme.currentColor;
        CGContextSetStrokeColorWithColor(context, currentColor.CGColor);
        CGContextStrokeRect(context, CGRectMake(1, 1,
                                                (int)cellRect.size.width - 2,
                                                (int)cellRect.size.height - 2));
    }        
}

-(UIImage *) _getCellImage:(id<PFCell>)cell
                withConfig:(PFPageConfig *)config 
                  andTheme:(PFNoteTheme *)theme
              forceRepaint:(BOOL)forceRepaint {
    DECLARE_PFUTILS
    NSString *cellCacheKey = NSFormat(@"%@%d", PFNOTE_CELL_CACHE_PREFIX, [cell hash]);
    UIImage *image = nil;
    if (!forceRepaint) image = [utils getCache:cellCacheKey];
    if (!image) {
        //NSLog(@"Cache not hit: %@", cell);
        CGRect cellRect = [cell getRect];
        UIGraphicsBeginImageContext(cellRect.size);
        CGContextRef context = UIGraphicsGetCurrentContext();        
        CGContextTranslateCTM(context, 0.0f, cellRect.size.height);
        CGContextScaleCTM(context, 1.0f, -1.0f);
        
        [self paintCell:cell onContext:context withConfig:config
                andCurrentCell:nil andTheme:theme usingCache:NO];
        
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        [utils setCache:image forKey:cellCacheKey];
    }
    return image;
}

@end

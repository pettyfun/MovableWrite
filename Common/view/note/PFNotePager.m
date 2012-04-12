//
//  PFNotePager.m
//  PettyFunNote
//
//  Created by YJ Park on 11/9/10.
//  Copyright 2010 PettyFun. All rights reserved.
//

#import "PFNotePager.h"
#import "PFNotePainterFactory.h"

@implementation PFNotePager

-(NSArray *) getPages:(id<PFPagable>)content
           withConfig:(PFPageConfig *)config
              forSize:(CGSize)viewSize {
    DECLARE_PFUTILS
    [utils markTime];
    NSMutableArray *pages = [NSMutableArray array];
    PFPage *currentPage = nil;

    NSArray *paragraphes = [content getParagraphes];
    for (id<PFParagraph> paragraph in paragraphes) {
        PFPage *newPage = nil;
        if (currentPage) {
            newPage = [self createNewParagraphInPage:currentPage
                                                  withConfig:config
                                                   noNewPage:NO];
        } else {
            newPage = [self getEmptyPageWithConfig:config forSize:viewSize];
        }
        if (newPage) {
            currentPage = newPage;
            [pages addObject:currentPage];
        }

        NSArray *cells = [paragraph getCells];
        BOOL withIndent = YES;
        for (id<PFCell> cell in cells) {
            PFPage *newPage = [self appendCell:cell toPage:currentPage withConfig:config withIndent:withIndent];
            withIndent = NO;
            if (newPage) {
                currentPage = newPage;
                [pages addObject:currentPage];
            }
        }
    }
    [utils logTime:@"Paging" longerThan:0.1f];
    return pages;
}

-(id<PFPage>) createNewParagraphInPage: (id<PFPage>) page
                            withConfig: (PFPageConfig *)config
                             noNewPage: (BOOL) noNewPage{
    id<PFParagraph> lastParagraph = [page getLastParapraph];
    if (lastParagraph && [[lastParagraph getCells] count] <= 0) {
        return nil;
    }
    id<PFPage> newPage = nil;
    
    CGRect pageRect = [page getRect];
    CGRect paragraphRect = [self calculateNewParagraphRectForPage:page withConfig:config];
    BOOL needNewPage = !CGRectContainsRect(pageRect, paragraphRect);
    
    if (needNewPage && !noNewPage) {
        newPage = [self getEmptyPageWithConfig:config forSize:[page getViewSize]];
    } else {
        PFNoteParagraph *paragraph = [[[PFNoteParagraph alloc] init] autorelease];
        [paragraph setRect:paragraphRect];
        [page appendParagraph:paragraph];
    }

    return newPage;
}


-(CGRect) calculateNewParagraphRectForPage:(id<PFPage>)page
                              withConfig:(PFPageConfig *) config {    
    CGRect paragraphRect;
    id<PFParagraph> lastParagraph = [page getLastParapraph];
    CGRect pageRect = [page getRect];
    if (lastParagraph) {
        CGRect lastParagraphRect = [lastParagraph getRect];
        float paragraphY = lastParagraphRect.origin.y 
                         + lastParagraphRect.size.height 
                         + config.factor * (config.marginParagraph + config.marginLine);
        paragraphRect = CGRectMake(lastParagraphRect.origin.x, paragraphY, pageRect.size.width, 1.0);
    }else {
        paragraphRect = CGRectMake(pageRect.origin.x, pageRect.origin.y, pageRect.size.width, 1.0);
    }
    return paragraphRect;
}
    
-(id<PFPage>) appendCell: (id<PFCell>) cell
                  toPage: (id<PFPage>) page
              withConfig: (PFPageConfig *)config
              withIndent: (BOOL)withIndent {
    id<PFPage> newPage = nil;

    [self calculateCellRectFor:cell onPage:page withConfig:config withIndent:withIndent];    
    CGRect pageRect = [page getRect];
    BOOL needNewPage = !CGRectContainsRect(pageRect, [cell getRect]);
    
    if (needNewPage) {
        newPage = [self getEmptyPageWithConfig:config forSize:[page getViewSize]];
        [self calculateCellRectFor:cell onPage:newPage withConfig:config withIndent:withIndent];
        [newPage appendCell:cell];
    } else {
        [page appendCell:cell];
    }

    return newPage;
}

-(void) calculateCellRectFor:(id<PFCell>)cell
                      onPage:(id<PFPage>)page
                  withConfig:(PFPageConfig *) config
                  withIndent:(BOOL)withIndent {
    id<PFParagraph> lastParagraph = [page getLastParapraph];
    id<PFCell> lastCell = lastParagraph ? [lastParagraph getLastCell] : nil;
    [self calculateCellRectFor:cell
                        onPage:page
                     afterCell:lastCell
                  orParagraph:lastParagraph
                    withConfig:config
                    withIndent:withIndent];
}

-(void) adjustCellsOfLine:(id<PFCell>)cell
                   onPage:(id<PFPage>)page
               withConfig:(PFPageConfig *) config {
    CGRect pageRect = [page getRect];
    CGRect cellRect = [cell getRect];
    id<PFParagraph> paragraph = [page getParapraphOfCell:cell];
    NSMutableArray *lineCells = [NSMutableArray array];
    BOOL needAdjust = NO;
    if (paragraph) {
        for (id<PFCell> oneCell in [paragraph getCells]) {
            CGRect oneCellRect = [oneCell getRect];
            if (oneCellRect.origin.y == cellRect.origin.y) {
                [lineCells addObject:oneCell];
                if (((PFNoteCell *)oneCell).type == PFNOTE_CELL_TYPE_WORD) {
                    needAdjust = YES;
                }
            }
        }
    }
    if (needAdjust && ([lineCells count] > 1)) {
        CGRect updatedRect = CGRectNull;
        float lastCellRight = cellRect.origin.x + cellRect.size.width;
        float margin = pageRect.origin.x + pageRect.size.width - lastCellRight;
        if ((margin > 0.0f) &&([lineCells count] > 1)) {
            float offset = margin / [lineCells count] - 1;
            for (int i = 1; i < [lineCells count]; i++) {
                id<PFCell> oneCell = [lineCells objectAtIndex:i];
                CGRect oneCellRect = [oneCell getRect];
                updatedRect = CGRectUnion(updatedRect, oneCellRect);
                CGRect newCellRect = CGRectMake(oneCellRect.origin.x + offset * i,
                                                oneCellRect.origin.y,
                                                oneCellRect.size.width,
                                                oneCellRect.size.height);
                [oneCell setRect:newCellRect];
                updatedRect = CGRectUnion(updatedRect, newCellRect);
            }
        }
        [page setUpdatedRect:updatedRect];
    }
}    

-(void) calculateCellRectFor:(id<PFCell>)cell
                      onPage:(id<PFPage>)page
                   afterCell:(id<PFCell>)lastCell
                 orParagraph:(id<PFParagraph>)lastParagraph
                  withConfig:(PFPageConfig *)config
                  withIndent:(BOOL)withIndent {
    CGRect pageRect = [page getRect];
    CGSize cellSize = [cell getSizeWithConfig:config];
    CGRect cellRect;
    if (lastCell) {
        CGRect lastCellRect = [lastCell getRect];
        cellRect = CGRectMake(lastCellRect.origin.x + lastCellRect.size.width,
                              lastCellRect.origin.y, 
                              cellSize.width * config.factor,
                              cellSize.height * config.factor);
        BOOL needNewLine = !CGRectContainsRect(pageRect, cellRect);
        if (needNewLine) {
            [self adjustCellsOfLine:lastCell onPage:page withConfig:config];
            cellRect = CGRectMake(pageRect.origin.x,
                                  lastCellRect.origin.y 
                                  + config.factor * (1.0f + config.marginLine), 
                                  config.factor * cellSize.width,
                                  config.factor * cellSize.height);
        }
    } else if (lastParagraph) {
        CGRect paragraphRect = [lastParagraph getRect];
        cellRect = CGRectMake(paragraphRect.origin.x +
                              (withIndent ? config.factor * config.paragraphIndent : 0.0f),
                              paragraphRect.origin.y, 
                              config.factor * cellSize.width,
                              config.factor * cellSize.height);
    } else {
        cellRect = CGRectMake(pageRect.origin.x, pageRect.origin.y, 
                              config.factor * cellSize.width,
                              config.factor * cellSize.height);        
    }

    if (cellRect.origin.x + cellRect.size.width > pageRect.origin.x + pageRect.size.width) {
        cellRect = CGRectMake(cellRect.origin.x, cellRect.origin.y, 
                              pageRect.origin.x + pageRect.size.width - cellRect.origin.x,
                              cellRect.size.height);        
    }
    [cell setRect:cellRect];
}

#pragma mark -
#pragma mark Internal methods

-(id<PFPage>) getEmptyPageWithConfig: (PFPageConfig *)config
                              forSize: (CGSize)viewSize {
    PFPage *page = [[[PFPage alloc] init] autorelease];
    DECLARE_PFNOTE_PAINTER_FACTORY
    PFNoteTheme *theme = [painterFactory getTheme:config];    
    CGRect pageRect = [theme getPageRectWithConfig:config forSize:viewSize];
    [page setRect:pageRect];
    [page setViewSize:viewSize];
    [self createNewParagraphInPage:page withConfig:config noNewPage:YES];
    return page;
}

@end

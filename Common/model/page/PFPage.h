//
//  PFPage.h
//  PettyFunNote
//
//  Created by YJ Park on 11/11/10.
//  Copyright 2010 PettyFun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PFPageConfig.h"

@protocol PFCell<NSObject>
//For the pager to do the paging
@required
-(CGSize) getSizeWithConfig:(PFPageConfig *)config;
-(CGPoint) getOffsetWithConfig:(PFPageConfig *)config;
-(CGRect) getContentRectWithConfig:(PFPageConfig *)config;
//Saving paging result
-(CGRect) getRect;
-(void) setRect:(CGRect)cellRect;
-(BOOL) isCellLoaded;
-(BOOL) loadCell;
-(BOOL) isControlCharactor;
@end

@protocol PFParagraph<NSObject>
@required
-(NSArray *) getCells;
-(id<PFCell>) getFirstCell;
-(id<PFCell>) getLastCell;
-(void) appendCell:(id<PFCell>)cell;
//Saving paging result
-(CGRect) getRect;
-(void) setRect:(CGRect)cellRect;
@end

@protocol PFPagable<NSObject>
@required
-(NSArray *) getParagraphes;
@end

@protocol PFPage<PFPagable>
@required
-(void) setParagraphes:(NSArray *)pageParagraphes;
-(void) appendParagraph:(id<PFParagraph>) paragraph;
-(id<PFParagraph>) getFirstParapraph;
-(id<PFParagraph>) getLastParapraph;
-(id<PFParagraph>) getParapraphOfCell:(id<PFCell>)cell;
-(id<PFCell>) getFirstCell;
-(id<PFCell>) getLastCell;
-(void) appendCell:(id<PFCell>)cell;
-(BOOL) containsCell:(id<PFCell>)cell;
//Saving paging result
-(CGRect) getRect;
-(void) setRect:(CGRect)pageRect;
-(CGSize) getViewSize;
-(void) setViewSize:(CGSize)pageViewSize;
//Page refresh
-(CGRect) getUpdatedRect;
-(void) setUpdatedRect:(CGRect)pageUpdateRect;
@end

@protocol PFPager<NSObject>
@required
-(NSArray *) getPages:(id<PFPagable>)content
           withConfig:(PFPageConfig *)config
              forSize:(CGSize)viewSize;

-(CGRect) calculateNewParagraphRectForPage:(id<PFPage>)page
                                withConfig:(PFPageConfig *)config;

-(id<PFPage>) createNewParagraphInPage: (id<PFPage>) page
                            withConfig: (PFPageConfig *)config
                             noNewPage: (BOOL) noNewPage;

-(void) calculateCellRectFor:(id<PFCell>)cell
                      onPage:(id<PFPage>)page
                  withConfig:(PFPageConfig *)config
                  withIndent:(BOOL)withIndent;

-(void) calculateCellRectFor:(id<PFCell>)cell
                      onPage:(id<PFPage>)page
                   afterCell:(id<PFCell>)lastCell
                 orParagraph:(id<PFParagraph>)lastParagraph
                  withConfig:(PFPageConfig *) config
                  withIndent:(BOOL)withIndent;

-(id<PFPage>) appendCell: (id<PFCell>)cell
                  toPage: (id<PFPage>)page
              withConfig: (PFPageConfig *)config
              withIndent: (BOOL)withIndent;

-(id<PFPage>) getEmptyPageWithConfig: (PFPageConfig *)config
                             forSize: (CGSize)viewSize;

@end

@interface PFPage : NSObject<PFPage> {
    NSMutableArray *paragraphes;
    //Page Related
    CGRect rect;
    CGSize viewSize;
    CGRect updatedRect;
}
@end

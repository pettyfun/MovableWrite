//
//  PFPage.m
//  PettyFunNote
//
//  Created by YJ Park on 11/11/10.
//  Copyright 2010 PettyFun. All rights reserved.
//

#import "PFPage.h"

@implementation PFPage

-(id) init {
    if ((self = [super init])) {
        paragraphes = nil;
        rect = CGRectNull;
        viewSize = CGSizeZero;
        updatedRect = CGRectNull;
    }
    return self;
}

-(void) dealloc {
    [paragraphes release];
    [super dealloc];
}

-(NSArray *) getParagraphes {
    return paragraphes;
}

-(void) setParagraphes:(NSArray *)pageParagraphes {
    if (paragraphes) {
        [paragraphes release];
    }
    if ([[pageParagraphes class] isSubclassOfClass:[NSMutableArray class]]) {
        paragraphes = [pageParagraphes retain];
    } else {
        paragraphes = [pageParagraphes mutableCopyWithZone:nil];
    }
}

-(void) appendParagraph:(id<PFParagraph>) paragraph {
    if (!paragraphes) {
        paragraphes = [[NSMutableArray array] retain];
    }
    [paragraphes addObject:paragraph];
}

-(void) appendCell:(id<PFCell>)cell {
    id<PFParagraph> paragraph = [paragraphes lastObject];
    if (paragraph) {
        [paragraph appendCell:cell];
        CGRect paragraphRect = [paragraph getRect];
        CGRect cellRect = [cell getRect];
        [paragraph setRect:CGRectUnion(paragraphRect, cellRect)];
    }
}

-(id<PFParagraph>) getFirstParapraph {
    if ([paragraphes count] > 0) {
        return [paragraphes objectAtIndex:0];
    }
    return nil;
}

-(id<PFParagraph>) getLastParapraph {
    return [paragraphes lastObject];
}

-(id<PFParagraph>) getParapraphOfCell:(id<PFCell>)cell {
    id<PFParagraph> result = nil;
    for (id<PFParagraph> paragraph in paragraphes) {
        if ([[paragraph getCells] containsObject:cell]) {
            result = paragraph;
            break;
        }
    }
    return result;
}

-(id<PFCell>) getLastCell {
    id<PFCell> result = nil;
    id<PFParagraph> paragraph = [self getLastParapraph];
    if (paragraph) {
        result = [paragraph getLastCell];
    }
    return result;
}

-(id<PFCell>) getFirstCell {
    id<PFCell> result = nil;
    id<PFParagraph> paragraph = [self getFirstParapraph];
    if (paragraph) {
        result = [paragraph getFirstCell];
    }
    return result;
}

-(BOOL) containsCell:(id<PFCell>)cell {
    BOOL result = NO;
    for (id<PFParagraph> paragraph in paragraphes) {
        if ([[paragraph getCells] containsObject:cell]) {
            result = YES;
            break;
        }
    }
    return result;
}

//Saving paging result
-(CGRect) getRect {
    return rect;
}

-(void) setRect:(CGRect)cellRect {
    rect = cellRect;
}

-(CGSize) getViewSize {
    return viewSize;
}

-(void) setViewSize:(CGSize)pageViewSize {
    viewSize = pageViewSize;
}

-(CGRect) getUpdatedRect {
    return updatedRect;
}

-(void) setUpdatedRect:(CGRect)pageUpdateRect {
    updatedRect = pageUpdateRect;
}

@end

//
//  PFParagragh.m
//  PettyFunNote
//
//  Created by YJ Park on 11/8/10.
//  Copyright 2010 pettyfun.com. All rights reserved.
//

#import "PFNoteParagraph.h"
#import "PFNote.h"

NSString *const PFNOTE_CELLS = @"cells";

@implementation PFNoteParagraph
@synthesize cells;

-(NSString *) getType {
    return @"com.pettyfun.bucket.model.note.PFNoteParagraph";
}

-(void) dealloc{
    [cells release];
    [super dealloc];
}

-(void) onInit {
    [super onInit];
    cells = [[NSMutableArray alloc] init];
}
 
-(void) onInitWithData:(NSDictionary *)data {
    [super onInitWithData:data];
    PFOBJECT_GET_ARRAY(PFNOTE_CELLS, cells, PFNoteCell)
}

-(void) onGetData:(NSMutableDictionary *)data {
    [super onGetData:data];
    PFOBJECT_SET_ARRAY(PFNOTE_CELLS, cells)
}

#pragma mark -
#pragma mark Specific Methods

-(void) appendCell:(id<PFCell>)cell {
    if ([[cell class] isSubclassOfClass: [PFNoteCell class]]) {
        [cells addObject:cell];
    }
}

#pragma mark -
#pragma mark PFParagragh

-(NSArray *) getCells {
    return cells;
}

-(id<PFCell>) getFirstCell {
    if ([cells count] > 0) {
        return [cells objectAtIndex:0];
    }
    return nil;
}

-(id<PFCell>) getLastCell {
    return [cells lastObject];
}

//Saving paging result
-(CGRect) getRect {
    return rect;
}

-(void) setRect:(CGRect)cellRect {
    rect = cellRect;
}

@end

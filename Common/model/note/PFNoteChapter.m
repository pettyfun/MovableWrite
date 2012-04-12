//
//  PFChapter.m
//  PettyFunNote
//
//  Created by YJ Park on 11/8/10.
//  Copyright 2010 pettyfun.com. All rights reserved.
//

#import "PFNoteChapter.h"
#import "PFNote.h"

NSString *const PFNOTE_PARAGRAPHES = @"paragraphes";

@implementation PFNoteChapter
@synthesize paragraphes;

-(NSString *) getType {
    return @"com.pettyfun.bucket.model.note.PFNoteChapter";
}

-(void) dealloc{
    [paragraphes release];
    [super dealloc];
}

-(void) onInit {
    [super onInit];
    paragraphes = [[NSMutableArray alloc] init];
    //[self createNewParagraph];
}

-(void) onInitWithData:(NSDictionary *)data {
    [super onInitWithData:data];
    PFOBJECT_GET_ARRAY(PFNOTE_PARAGRAPHES, paragraphes, PFNoteParagraph)
}

-(void) onGetData:(NSMutableDictionary *)data {
    [super onGetData:data];
    PFOBJECT_SET_ARRAY(PFNOTE_PARAGRAPHES, paragraphes)
}

#pragma mark -
#pragma mark Specific Methods
-(PFNoteParagraph *) createNewParagraph {
    PFNoteParagraph *paragraph = [[[PFNoteParagraph alloc] init] autorelease];
    [paragraphes addObject:paragraph];
    return paragraph;
}

#pragma mark -
#pragma mark PFPagable

-(NSArray *) getParagraphes {
    return paragraphes;
}

@end

//
//  PFNoteState.m
//  PettyFunNote
//
//  Created by YJ Park on 11/9/10.
//  Copyright 2010 PettyFun. All rights reserved.
//

#import "PFNoteState.h"
#import "PFNotePoint.h"

NSString *const PFNOTE_STATE_FACTOR = @"factor";
NSString *const PFNOTE_STATE_CHAPTER = @"chapter";
NSString *const PFNOTE_STATE_PARAGRAPH = @"paragraph";
NSString *const PFNOTE_STATE_CELL = @"cell";
NSString *const PFNOTE_STATE_NAME = @"name";

@implementation PFNoteState
@synthesize factor;
@synthesize chapter;
@synthesize paragraph;
@synthesize cell;
@synthesize name;

-(NSString *) getType {
    return @"com.pettyfun.bucket.model.note.PFNoteState";
}

-(void) dealloc{
    [super dealloc];
}

-(void) onInit {
    [super onInit];    
    factor = PFNOTE_POINT_DEFAULT_FACTOR;
    chapter = 0;
    paragraph = 0;
    cell = -1;
}

-(void) onInitWithData:(NSDictionary *)data {
    [super onInitWithData:data];
    PFOBJECT_GET_FLOAT(PFNOTE_STATE_FACTOR, factor)
    if (factor == 0.0f) {
        factor = PFNOTE_POINT_DEFAULT_FACTOR;
    }
    PFOBJECT_GET_INT(PFNOTE_STATE_CHAPTER, chapter)
    PFOBJECT_GET_INT(PFNOTE_STATE_PARAGRAPH, paragraph)
    PFOBJECT_GET_INT(PFNOTE_STATE_CELL, cell)
    PFOBJECT_GET_STRING(PFNOTE_STATE_NAME, name)
}

-(void) onGetData:(NSMutableDictionary *)data {
    [super onGetData:data];
    PFOBJECT_SET_FLOAT(PFNOTE_STATE_FACTOR, factor)
    PFOBJECT_SET_INT(PFNOTE_STATE_CHAPTER, chapter)
    PFOBJECT_SET_INT(PFNOTE_STATE_PARAGRAPH, paragraph)
    PFOBJECT_SET_INT(PFNOTE_STATE_CELL, cell)
    PFOBJECT_SET_STRING(PFNOTE_STATE_NAME, name)
}

#pragma mark -
#pragma mark Specific Methods


@end

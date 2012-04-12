//
//  PFNote.h
//  PettyFunNote
//
//  Created by YJ Park on 11/8/10.
//  Copyright 2010 pettyfun.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PFItem.h"

#import "PFNoteChapter.h"
#import "PFNoteParagraph.h"
#import "PFNoteCell.h"
#import "PFNoteStroke.h"
#import "PFNotePoint.h"

#import "PFNoteConfig.h"
#import "PFNoteState.h"

#define PFNOTE_PDF_FOLDER @"pdf"
#define PFNOTE_PDF_EXTENTION @"pdf"

extern NSString *const PFNOTE_CHAPTERS;
extern NSString *const PFNOTE_CONFIG;

//Common Properties
extern NSString *const PFNOTE_WIDTH;
extern NSString *const PFNOTE_HEIGHT;

extern NSString *const PFNOTE_LINE_WIDTH_INDEX;
extern NSString *const PFNOTE_COLOR_INDEX;
extern NSString *const PFNOTE_BGCOLOR_INDEX;

extern NSString *const PFNOTE_BOLD;
extern NSString *const PFNOTE_ITALIC;
extern NSString *const PFNOTE_UNDERLINE;
extern NSString *const PFNOTE_MIDDLELINE;

//Item Type
extern NSString *const PFNOTE_ITEMTYPE_IDENTITY;
extern NSString *const PFNOTE_ITEMTYPE_URL_SCHEMA;
extern NSString *const PFNOTE_ITEMTYPE_FILE_EXTENSION;
extern NSString *const PFNOTE_ITEMTYPE_VERSION;

//to get the state from defaults
extern NSString *const PFNOTE_STATE_DEFAULT_PREFIX;

@interface PFNote : PFItem {
    NSMutableArray *chapters;
    BOOL needSave;
    PFNoteConfig *config;
    
    //Local properties
    NSString *stateDefaultKey;
    PFNoteState *state;
}
@property (readonly) NSMutableArray *chapters;
@property BOOL needSave;
@property (readonly) PFNoteConfig *config;
@property (readonly) PFNoteState *state;

-(NSString *) getFileName;
-(NSString *) getPDFName;
-(NSString *) getPDFPath;

-(PFNoteChapter *) createNewChapter;
-(PFNoteParagraph *) createNewParagraph;

-(BOOL) isEmptyNote;
-(void) seekChapterEnd;
-(void) insertCell:(PFNoteCell *)cell;
-(PFNoteCell *) getCell;
-(PFNoteCell *) removeCell;
-(void) seekCell:(PFNoteCell *)currentCell;
-(void) setFactor:(float)factor;

-(PFNoteChapter *) getChapter;
-(PFNoteParagraph *) getParagraph;
    
-(NSDictionary *)getAnalyticData;

//internal methods
-(void) _initState;
-(void) _saveState;
@end

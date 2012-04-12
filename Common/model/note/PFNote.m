//
//  PFNote.m
//  PettyFunNote
//
//  Created by YJ Park on 11/8/10.
//  Copyright 2010 pettyfun.com. All rights reserved.
//

#import "PFNote.h"

NSString *const PFNOTE_CHAPTERS = @"chapters";
NSString *const PFNOTE_CONFIG = @"config";

//Common Properties
NSString *const PFNOTE_WIDTH = @"width";
NSString *const PFNOTE_HEIGHT = @"height";

NSString *const PFNOTE_LINE_WIDTH_INDEX = @"line_width";
NSString *const PFNOTE_COLOR_INDEX = @"color";
NSString *const PFNOTE_BGCOLOR_INDEX = @"bgcolor";

NSString *const PFNOTE_BOLD = @"bold";
NSString *const PFNOTE_ITALIC = @"italic";
NSString *const PFNOTE_UNDERLINE = @"underline";
NSString *const PFNOTE_MIDDLELINE = @"middleline";

//Item Type
NSString *const PFNOTE_ITEMTYPE_IDENTITY = @"com.pettyfun.bucket.note";
NSString *const PFNOTE_ITEMTYPE_URL_SCHEMA = @"movablewrite";
NSString *const PFNOTE_ITEMTYPE_FILE_EXTENSION = @"movablewrite";
NSString *const PFNOTE_ITEMTYPE_VERSION = @"1.0";

//state
NSString *const PFNOTE_STATE_DEFAULT_PREFIX = @"state_";

static PFItemType *_pfNoteItemType = nil;

@implementation PFNote

@synthesize chapters;
@synthesize needSave;
@synthesize config;
@synthesize state;

-(NSString *) getType {
    return @"com.pettyfun.bucket.model.note.PFNote";
}

-(void) dealloc{
    [chapters release];
    [config release];
    
    [stateDefaultKey release];
    [state release];
    [super dealloc];
}

-(void) onInit {
    [super onInit];
    name = [[NSDateFormatter localizedStringFromDate:createTime 
                                          dateStyle:NSDateFormatterMediumStyle 
                                          timeStyle:NSDateFormatterShortStyle] retain];
    chapters = [[NSMutableArray alloc] init];
    PFNoteChapter *chapter = [[[PFNoteChapter alloc] init] autorelease];
    [chapters addObject:chapter];
    needSave = NO;
    config = [[PFNoteConfig alloc] init];
    [self _initState];
}

-(void) onInitWithData:(NSDictionary *)data {
    [super onInitWithData:data];
    PFOBJECT_GET_ARRAY(PFNOTE_CHAPTERS, chapters, PFNoteChapter)
    PFOBJECT_GET_OBJECT(PFNOTE_CONFIG, config, PFNoteConfig)
    needSave = NO;
    [self _initState];
}

-(void) _initState {
    stateDefaultKey = [NSFormat(@"%@%@", PFNOTE_STATE_DEFAULT_PREFIX, [self getUUID]) retain];
    DECLARE_PFUTILS
    NSDictionary *stateData = [utils getDefault:stateDefaultKey];
    if (stateData) {
        state = [[PFNoteState alloc] initWithPFData:stateData];
        config.factor = [PFNotePoint verifyFactor:state.factor];
    } else {
        state = [[PFNoteState alloc] init];
    }
    PFNoteCell *cell = [self getCell];
    if (cell == nil) {
        state.chapter = 0;
        [self seekChapterEnd];
    }
}

-(void) _saveState {
    DECLARE_PFUTILS
    [utils setDefault:[state getData] forKey:stateDefaultKey];
}

-(void) onGetData:(NSMutableDictionary *)data {
    [super onGetData:data];
    PFOBJECT_SET_ARRAY(PFNOTE_CHAPTERS, chapters)
    PFOBJECT_SET_OBJECT(PFNOTE_CONFIG, config)
}

#pragma mark -
#pragma mark Specific Methods

-(NSString *) getFileName {
    if (author && [author length] > 0) {
        return [NSString stringWithFormat:@"%@ - %@.%@",
                name, author, PFNOTE_ITEMTYPE_FILE_EXTENSION];
    }
    return [NSString stringWithFormat:@"%@.%@",
            name, PFNOTE_ITEMTYPE_FILE_EXTENSION];
}

-(NSString *) getPDFName {
    if (author && [author length] > 0) {
        return [NSString stringWithFormat:@"%@ - %@.%@",
                name, author, PFNOTE_PDF_EXTENTION];
    }
    return [NSString stringWithFormat:@"%@.%@",
            name, PFNOTE_PDF_EXTENTION];
}

-(NSString *) getPDFPath {
    DECLARE_PFUTILS
    NSString *folder = [utils getPathInDocument:PFNOTE_PDF_FOLDER];
    NSString *pdfPath = [folder stringByAppendingPathComponent:
             [NSString stringWithFormat:@"%@.%@", [self getUUID], PFNOTE_PDF_EXTENTION]];    
    return pdfPath;
}

-(PFNoteChapter *) createNewChapter {
    PFNoteChapter *chapter = [[[PFNoteChapter alloc] init] autorelease];
    state.chapter += 1;
    [chapters insertObject:chapter atIndex:state.chapter];
    state.paragraph = -1;
    state.cell = -1;
    needSave = YES;
    return chapter;
}

-(PFNoteParagraph *) createNewParagraph {
    PFNoteParagraph *paragraph = nil;
    PFNoteChapter *chapter = [self getChapter];
    if (chapter) {
        paragraph = [[[PFNoteParagraph alloc] init] autorelease];

        if (state.paragraph >= 0) {
            PFNoteParagraph *lastParagraph = [chapter.paragraphes objectAtIndex:state.paragraph];
            
            PFNoteCell *nextCell = nil;
            if (state.cell + 1 < [lastParagraph.cells count]) {
                nextCell = [lastParagraph.cells objectAtIndex:state.cell + 1];
            }
            if ((nextCell != nil) &&
                (nextCell.type == PFNOTE_CELL_TYPE_RETURN)) {
                state.cell = state.cell + 1;
            }

            NSMutableIndexSet *movedCellIndexes = [[[NSMutableIndexSet alloc] init] autorelease];
            for (int i = state.cell; i < [lastParagraph.cells count]; i++) {
                PFNoteCell *cell = [lastParagraph.cells objectAtIndex:i];
                [movedCellIndexes addIndex:i];
                [paragraph appendCell:cell];
            }
            [lastParagraph.cells removeObjectsAtIndexes:movedCellIndexes];
            
            PFNoteCell *lastCell = (PFNoteCell *)[lastParagraph.cells lastObject];
            if ((lastCell == nil) ||
                (lastCell.type != PFNOTE_CELL_TYPE_RETURN)) {
                PFNoteCell *cell = [[[PFNoteCell alloc] initWithType:PFNOTE_CELL_TYPE_RETURN] autorelease];
                [lastParagraph.cells addObject:cell];

            }
        }

        state.paragraph += 1;
        [chapter.paragraphes insertObject:paragraph atIndex:state.paragraph];
        if ([paragraph.cells count] == 0) {
            PFNoteCell *cell = [[[PFNoteCell alloc] initWithType:PFNOTE_CELL_TYPE_RETURN] autorelease];
            [paragraph.cells addObject:cell];
        }
        state.cell = 0;
        needSave = YES;
    }
    return paragraph;
}

-(PFNoteChapter *) getChapter {
    if ((state.chapter >= 0) && (state.chapter < [chapters count])) {
        return [chapters objectAtIndex:state.chapter];
    }
    return nil;
}

-(PFNoteParagraph *) getParagraph {
    PFNoteChapter *chapter = [self getChapter];
    if (chapter) {
        if ((state.paragraph >= 0) && (state.paragraph < [chapter.paragraphes count])) {
            return [chapter.paragraphes objectAtIndex:state.paragraph];
        }
    }
    return nil;
}

-(void) seekChapterEnd {
    PFNoteChapter *chapter = [self getChapter];
    if (chapter) {
        PFNoteParagraph *paragraph = [chapter.paragraphes lastObject];
        state.paragraph = [chapter.paragraphes count] - 1;
        if (paragraph) {
            state.cell = [paragraph.cells count] - 1;
        } else {
            state.cell = -1;
        }

    }
}

-(void) insertCell:(PFNoteCell *)cell {
    PFNoteParagraph *paragraph = [self getParagraph];
    if (paragraph) {
        if ((state.cell >= 0) && (state.cell < [paragraph.cells count])) {
            PFNoteCell *currentCell = [paragraph.cells objectAtIndex:state.cell];
            if (currentCell.type == PFNOTE_CELL_TYPE_RETURN) {
                state.cell --;
            }
        }
        state.cell ++;
        [paragraph.cells insertObject:cell atIndex:state.cell];
        needSave = YES;
    }
}

-(PFNoteCell *) getCell {
    PFNoteCell *result = nil;
    PFNoteParagraph *paragraph = [self getParagraph];
    if (paragraph) {
        if ((state.cell >= 0)&&(state.cell < [paragraph.cells count])) {
            result = [paragraph.cells objectAtIndex:state.cell];
        }
    }
    return result;
}

-(void) seekCell:(PFNoteCell *)currentCell {
    for (int i = 0; i<[chapters count]; i++) {
        PFNoteChapter *chapter = [chapters objectAtIndex:i];
        for (int j = 0; j<[chapter.paragraphes count]; j++) {
            PFNoteParagraph *paragraph = [chapter.paragraphes objectAtIndex:j];
            for (int k = 0; k<[paragraph.cells count]; k++) {
                PFNoteCell *cell = [paragraph.cells objectAtIndex:k];
                if (cell == currentCell) {
                    state.chapter = i;
                    state.paragraph = j;
                    state.cell = k;
                    [self _saveState];
                    return;
                }
            }
        }
    }
}

-(void) setFactor:(float)factor {
    config.factor = factor;
    state.factor = factor;
    [self _saveState];
}


-(PFNoteCell *) removeCell {
    PFNoteCell *result = nil;
    PFNoteChapter *chapter = [self getChapter];
    if (chapter) {
        PFNoteParagraph *paragraph = [self getParagraph];
        if (paragraph) {
            if ([paragraph.cells count] == 1) {
                //Remove the paragraph if the cell is the last one.
                if ([chapter.paragraphes count] > 1) {
                    [chapter.paragraphes removeObjectAtIndex:state.paragraph];
                    state.paragraph -= 1;
                    if (state.paragraph < 0) {
                        state.paragraph = 0;
                        paragraph = [chapter.paragraphes objectAtIndex:state.paragraph];
                        state.cell = 0;
                    } else {
                        paragraph = [chapter.paragraphes objectAtIndex:state.paragraph];
                        state.cell = [paragraph.cells count] - 1;
                    }
                }
            } else if (state.cell >= [paragraph.cells count]) {
                state.cell = [paragraph.cells count] - 1;
            } else {
                result = [paragraph.cells objectAtIndex:state.cell];
                if (result.type == PFNOTE_CELL_TYPE_RETURN) {
                    if (state.paragraph + 1 < [chapter.paragraphes count]) {
                        [paragraph.cells removeObjectAtIndex:state.cell];
                        state.cell -= 1;                    

                        PFNoteParagraph *nextParagraph = [chapter.paragraphes objectAtIndex:state.paragraph + 1];
                        for (PFNoteCell *cell in [nextParagraph getCells]) {
                            [paragraph appendCell:cell];                        
                        }
                        [chapter.paragraphes removeObjectAtIndex:state.paragraph + 1];
                    } else {
                        state.cell -= 1;                    
                        [paragraph.cells removeObjectAtIndex:state.cell];
                    }
                } else {
                    [paragraph.cells removeObjectAtIndex:state.cell];
                    state.cell -= 1;                    
                }
                
                if (state.cell < 0) state.cell = 0;   
            }
        }
    }
    needSave = YES;
    return result;
}


-(PFItemType *) getItemType {
    if (!_pfNoteItemType) {
        _pfNoteItemType = [[PFItemType alloc] init];
        _pfNoteItemType.identity = PFNOTE_ITEMTYPE_IDENTITY;
        _pfNoteItemType.urlSchema = PFNOTE_ITEMTYPE_URL_SCHEMA;
        _pfNoteItemType.fileExtension = PFNOTE_ITEMTYPE_FILE_EXTENSION;
        _pfNoteItemType.version = PFNOTE_ITEMTYPE_VERSION;
    }
    return _pfNoteItemType;
}

-(NSDictionary *)getAnalyticData {
    DECLARE_PFUTILS
    NSNumber *chapterNum = [utils getAnalyticNumber:[chapters count]];
    int paragraphCount = 0;
    int wordCount = 0;
    for (PFNoteChapter *chapter in chapters) {
        for (PFNoteParagraph *paragraph in chapter.paragraphes) {
            paragraphCount++;
            for (PFNoteCell *cell in paragraph.cells) {
                if (cell.type == PFNOTE_CELL_TYPE_WORD) {
                    wordCount++;
                }
            }
        }
    }
    NSNumber *paragraphNum = [utils getAnalyticNumber:paragraphCount];
    NSNumber *wordNum = [utils getAnalyticNumber:wordCount];
    
    NSDictionary *result = [NSDictionary dictionaryWithObjectsAndKeys:
                            chapterNum, @"chapter_num",
                            paragraphNum, @"paragraph_num",
                            wordNum, @"word_num",
                            nil];
    //NSLog(@"AnalyticData: %@ [%@]: %@", name, uuid, result);
    return result;
}

-(BOOL) isEmptyNote {
    for (PFNoteChapter *chapter in chapters) {
        for (PFNoteParagraph *paragraph in chapter.paragraphes) {
            for (PFNoteCell *cell in paragraph.cells) {
                if ((cell.type == PFNOTE_CELL_TYPE_WORD) && ![cell isEmptyCell]) {
                    return NO;
                }
            }
        }
    }
    return YES;
}

@end

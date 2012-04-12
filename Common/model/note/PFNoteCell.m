//
//  PFCharacter.m
//  PettyFunNote
//
//  Created by YJ Park on 11/8/10.
//  Copyright 2010 pettyfun.com. All rights reserved.
//

#import "PFNoteCell.h"
#import "PFNote.h"

NSString *const PFNOTE_CELL_TYPE = @"type";
NSString *const PFNOTE_CELL_STRING = @"string";
NSString *const PFNOTE_CELL_CANDIDATES = @"candidates";
NSString *const PFNOTE_CELL_STROKES = @"strokes";
NSString *const PFNOTE_CELL_WIDTH = @"width";

NSString *const PFNOTE_CELL_TYPE_WORD = @"word";
NSString *const PFNOTE_CELL_TYPE_SPACE = @"space";
NSString *const PFNOTE_CELL_TYPE_RETURN = @"return";

@implementation PFNoteCell
@synthesize type;
@synthesize strokes;
@synthesize width;

-(NSString *) getType {
    return @"com.pettyfun.bucket.model.note.PFNoteCell";
}

-(void) dealloc{
    [type release];
    [string release];
    [candidates release];
    [strokes release];
    [cachedStrokesData release];
    [super dealloc];
}

-(void) onInit {
    [super onInit];
    string = nil;
    candidates = [[NSMutableArray alloc] init];
    strokes = [[NSMutableArray alloc] init];
    self.type = PFNOTE_CELL_TYPE_WORD;
    width = 1.0f;
}


-(void) initType {
    NSString *_type = PFNOTE_CELL_TYPE_WORD;
    if ([type isEqualToString:PFNOTE_CELL_TYPE_RETURN]) {
        _type = PFNOTE_CELL_TYPE_RETURN;
    } else if ([type isEqualToString:PFNOTE_CELL_TYPE_SPACE]) {
        _type = PFNOTE_CELL_TYPE_SPACE;
    } else {
        _type = PFNOTE_CELL_TYPE_WORD;
    }
    if (type != _type) {
        [type release];
        type = _type;
    }
}

-(NSMutableArray *) strokes {
    if (strokes == nil) {
        if (useCachedStrokesData) {
            NSDictionary *data = cachedStrokesData;
            PFOBJECT_GET_ARRAY(PFNOTE_CELL_STROKES, strokes, PFNoteStroke)    
        } else {
            strokes = [[NSMutableArray alloc] init];    
        }
    }
    return strokes;
}

-(void) clearCachedStrokesData {
    if (useCachedStrokesData) {
        useCachedStrokesData = NO;
        [cachedStrokesData release];
        cachedStrokesData = nil;
    }
}

-(void) cacheStrokesData:(NSDictionary *)data {
    id strokesData = [data valueForKey:PFNOTE_CELL_STROKES];
    if (strokesData) {
        if (cachedStrokesData) {
            [cachedStrokesData release];
        }
        cachedStrokesData = [[NSDictionary dictionaryWithObject:strokesData forKey:PFNOTE_CELL_STROKES] retain];
        useCachedStrokesData = YES;
    }
}

-(BOOL) isCellLoaded {
    if ((type == PFNOTE_CELL_TYPE_WORD) && (strokes == nil)) {
        return NO;
    }
    return YES;
}

-(BOOL) loadCell {
    if ([self isEmptyCell]) {
        return [self.strokes count] > 0;
    }
    return NO;
}

-(void) onInitWithData:(NSDictionary *)data {
    [super onInitWithData:data];
    PFOBJECT_GET_STRING(PFNOTE_CELL_TYPE, type)
    [self initType];
    PFOBJECT_GET_STRING(PFNOTE_CELL_STRING, string)
    PFOBJECT_GET_ARRAY(PFNOTE_CELL_CANDIDATES, candidates, NSString)
    PFOBJECT_GET_FLOAT(PFNOTE_CELL_WIDTH, width)
    
    //cache the data, for faster save and lazy loading points
    [self cacheStrokesData:data];
    if (strokes) {
        [strokes release];
    }
    strokes = nil;
}

-(void) onGetData:(NSMutableDictionary *)data {
    [super onGetData:data];
    PFOBJECT_SET_STRING(PFNOTE_CELL_TYPE, type)
    PFOBJECT_SET_STRING(PFNOTE_CELL_STRING, string)
    PFOBJECT_SET_ARRAY(PFNOTE_CELL_CANDIDATES, candidates)
    PFOBJECT_SET_FLOAT(PFNOTE_CELL_WIDTH, width)

    if (useCachedStrokesData) {
        id originalStrokes = [cachedStrokesData valueForKey:PFNOTE_CELL_STROKES];
        [data setValue:originalStrokes forKey:PFNOTE_CELL_STROKES];
    } else {
        PFOBJECT_SET_ARRAY(PFNOTE_CELL_STROKES, strokes)    
        [self cacheStrokesData:data];
    }
}

#pragma mark -
#pragma mark Specific Methods

-(id) initWithType:(NSString *)cellType {
    if ((self = [self init])){
        self.type = cellType;
    }
    return self;
}

-(void) addStroke:(PFNoteStroke *)stroke {
    if (type == PFNOTE_CELL_TYPE_WORD) {
        [self.strokes addObject:stroke];
        [self clearCachedStrokesData];
    }
}

-(void) removeStroke:(PFNoteStroke *)stroke {
    if (type == PFNOTE_CELL_TYPE_WORD) {
        [self.strokes removeObject:stroke];
        [self clearCachedStrokesData];
    }
}

-(PFNoteStroke *) getLastStroke {
    return [self.strokes lastObject];
}

-(void) clearStrokes {
    if (type == PFNOTE_CELL_TYPE_WORD) {
        [self.strokes removeAllObjects];
        [self clearCachedStrokesData];
    }
}

-(void) copyStrokesFrom:(PFNoteCell *)cell {
    if (type == PFNOTE_CELL_TYPE_WORD) {
        [self.strokes removeAllObjects];
        for (PFNoteStroke *stroke in cell.strokes) {
            [self.strokes addObject:stroke];
        }
        [self clearCachedStrokesData];
    }
}

-(BOOL) isEmptyCell {
    if (type == PFNOTE_CELL_TYPE_WORD) {
        return ((strokes == nil) || [strokes count] <= 0);
    }
    return NO;
}

-(BOOL) isControlCharactor {
    return (type != PFNOTE_CELL_TYPE_WORD);
}

#pragma mark -
#pragma mark PFPage Methods
-(CGSize) getSizeWithConfig:(PFPageConfig *)config {
    if ([PFNOTE_CELL_TYPE_RETURN isEqualToString:type]) {
        if (config.showingControlCharactors) {
            return CGSizeMake(config.spaceWidth, 1.0f);
        } else {
            return CGSizeMake(0.0f, 1.0f);
        }
    } else if ([PFNOTE_CELL_TYPE_SPACE isEqualToString:type]) {
        return CGSizeMake(config.spaceWidth, 1.0f);
    } else if ([PFNOTE_CELL_TYPE_WORD isEqualToString:type]) {
        return CGSizeMake(width + config.marginWord, 1.0f);
    }

    return CGSizeMake(1.0f, 1.0f);
}

-(CGPoint) getOffsetWithConfig:(PFPageConfig *)config {
    if ([PFNOTE_CELL_TYPE_WORD isEqualToString:type]) {
        return CGPointMake(config.factor * config.marginWord / 2.0f, 0.0f);
    }
    return CGPointZero;
}

-(CGRect) getContentRectWithConfig:(PFPageConfig *)config {
    CGPoint offset = [self getOffsetWithConfig:config];
    CGRect contentRect = CGRectMake(offset.x, offset.y,
                             rect.size.width - 2.0f * offset.x, 
                             rect.size.height - 2.0f * offset.y);
    return contentRect;
}

//Saving paging result
-(CGRect) getRect {
    return rect;
}

-(void) setRect:(CGRect)cellRect {
    rect = cellRect;
}

@end

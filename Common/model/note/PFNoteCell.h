//
//  PFCharacter.h
//  PettyFunNote
//
//  Created by YJ Park on 11/8/10.
//  Copyright 2010 pettyfun.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PFObject.h"
#import "PFNoteStroke.h"
#import "PFPageView.h"

extern NSString *const PFNOTE_CELL_TYPE;
extern NSString *const PFNOTE_CELL_STRING;
extern NSString *const PFNOTE_CELL_CANDIDATES;
extern NSString *const PFNOTE_CELL_STROKES;
extern NSString *const PFNOTE_CELL_WIDTH;

extern NSString *const PFNOTE_CELL_TYPE_WORD;
extern NSString *const PFNOTE_CELL_TYPE_SPACE;
extern NSString *const PFNOTE_CELL_TYPE_RETURN;

@interface PFNoteCell : PFObject<PFCell> {
    NSString *type;
    float width;
    NSString *string;
    NSMutableArray *candidates;
    NSMutableArray *strokes;
    //Page Related
    CGRect rect;
    
    BOOL useCachedStrokesData;
    NSDictionary *cachedStrokesData;
}
@property (nonatomic, retain) NSString *type;
@property (readonly) NSMutableArray *strokes;
@property float width;

-(id) initWithType:(NSString *)cellType;

-(PFNoteStroke *) getLastStroke;
-(void) addStroke:(PFNoteStroke *)stroke;
-(void) removeStroke:(PFNoteStroke *)stroke;
-(void) clearStrokes;
-(void) copyStrokesFrom:(PFNoteCell *)cell;

-(BOOL) isEmptyCell;

-(void) initType;

-(void) clearCachedStrokesData;
-(void) cacheStrokesData:(id)strokesData;

@end

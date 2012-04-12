//
//  PFPopCell.m
//  PettyFunPop
//
//  Created by YJ Park on 1/6/11.
//  Copyright 2011 PettyFun.com. All rights reserved.
//

#import "PFPopCell.h"
#import "PFPop.h"

NSString *const PFPOP_CELL_TYPE = @"type";

NSString *const PFPOP_CELL_STROKES = @"strokes";

NSString *const PFPOP_CELL_TYPE_STROKE = @"stroke";
NSString *const PFPOP_CELL_TYPE_ICON = @"icon";

@implementation PFPopCell
@synthesize type;
@synthesize strokes;

-(NSString *) getType {
    return @"com.pettyfun.bucket.model.pop.PFPopCell";
}

-(void) dealloc{
    [type release];
    [strokes release];
    [super dealloc];
}

-(void) onInit {
    [super onInit];
    strokes = [[NSMutableArray alloc] init];
    self.type = PFPOP_CELL_TYPE_STROKE;
}

-(void) onInitWithData:(NSDictionary *)data {
    [super onInitWithData:data];
    PFOBJECT_GET_STRING(PFPOP_CELL_TYPE, type)
    PFOBJECT_GET_ARRAY(PFPOP_CELL_STROKES, strokes, PFPopStroke)    
}

-(void) onGetData:(NSMutableDictionary *)data {
    [super onGetData:data];
    PFOBJECT_SET_STRING(PFPOP_CELL_TYPE, type)
    PFOBJECT_SET_ARRAY(PFPOP_CELL_STROKES, strokes)    
}

#pragma mark -
#pragma mark Specific Methods

-(id) initWithType:(NSString *)cellType {
    if ((self = [self init])){
        self.type = cellType;
    }
    return self;
}

-(void) addStroke:(PFPopStroke *)stroke {
    [strokes addObject:stroke];
}

-(PFPopStroke *) getLastStroke {
    return [strokes lastObject];
}

-(void) clearStrokes {
    [strokes removeAllObjects];
}

-(void) copyStrokesFrom:(PFPopCell *)cell {
    [strokes removeAllObjects];
    for (PFPopStroke *stroke in cell.strokes) {
        [strokes addObject:stroke];
    }
}

-(BOOL) isEmptyCell {
    return [strokes count] <= 0;
}

@end

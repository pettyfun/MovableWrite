//
//  PFPop.m
//  PettyFunPop
//
//  Created by YJ Park on 1/6/11.
//  Copyright 2011 PettyFun.com. All rights reserved.
//

#import "PFPop.h"

NSString *const PFPOP_CELLS = @"cells";
NSString *const PFPOP_CONFIG = @"config";
NSString *const PFPOP_STATE = @"state";

//Common Properties
NSString *const PFPOP_WIDTH = @"width";
NSString *const PFPOP_HEIGHT = @"height";

NSString *const PFPOP_LINE_WIDTH = @"line_width";
NSString *const PFPOP_COLOR = @"color";
NSString *const PFPOP_BGCOLOR = @"bgcolor";

//Item Type
NSString *const PFPOP_ITEMTYPE_IDENTITY = @"com.pettyfun.bucket.pop";
NSString *const PFPOP_ITEMTYPE_URL_SCHEMA = @"pettyfunpop";
NSString *const PFPOP_ITEMTYPE_FILE_EXTENSION = @"pfp";

@implementation PFPop
@synthesize cells;
@synthesize needSave;
@synthesize config;
@synthesize state;

-(NSString *) getType {
    return @"com.pettyfun.bucket.model.note.PFPOP";
}

-(void) dealloc{
    [cells release];
    [config release];
    [state release];
    [super dealloc];
}

-(void) onInit {
    [super onInit];
    name = [[NSDateFormatter localizedStringFromDate:createTime 
                                           dateStyle:NSDateFormatterMediumStyle 
                                           timeStyle:NSDateFormatterShortStyle] retain];
    cells = [[NSMutableArray alloc] init];
    PFPopCell *cell = [[[PFPopCell alloc] init] autorelease];
    [cells addObject:cell];

    needSave = NO;
    config = [[PFPopConfig alloc] init];
    state = [[PFPopState alloc] init];
}

-(void) onInitWithData:(NSDictionary *)data {
    [super onInitWithData:data];
    PFOBJECT_GET_ARRAY(PFPOP_CELLS, cells, PFPopCell)
    PFOBJECT_GET_OBJECT(PFPOP_CONFIG, config, PFPopConfig)
    PFOBJECT_GET_OBJECT(PFPOP_STATE, state, PFPopState)
    needSave = NO;
}

-(void) onGetData:(NSMutableDictionary *)data {
    [super onGetData:data];
    PFOBJECT_SET_ARRAY(PFPOP_CELLS, cells)
    PFOBJECT_SET_OBJECT(PFPOP_CONFIG, config)
    PFOBJECT_SET_OBJECT(PFPOP_STATE, state)
}

#pragma mark -
#pragma mark Specific Methods

-(NSString *) getFileName {
    if (author && [author length] > 0) {
        return [NSString stringWithFormat:@"%@ - %@.%@",
                name, author, PFPOP_ITEMTYPE_FILE_EXTENSION];
    }
    return [NSString stringWithFormat:@"%@.%@",
            name, PFPOP_ITEMTYPE_FILE_EXTENSION];
}

-(NSString *) getPDFName {
    if (author && [author length] > 0) {
        return [NSString stringWithFormat:@"%@ - %@.%@",
                name, author, PFPOP_PDF_EXTENTION];
    }
    return [NSString stringWithFormat:@"%@.%@",
            name, PFPOP_PDF_EXTENTION];
}

-(NSString *) getPDFPath {
    DECLARE_PFUTILS
    NSString *folder = [utils getPathInDocument:PFPOP_PDF_FOLDER];
    NSString *pdfPath = [folder stringByAppendingPathComponent:
                         [NSString stringWithFormat:@"%@.%@", [self getUUID], PFPOP_PDF_EXTENTION]];    
    return pdfPath;
}

-(BOOL) isEmptyPop {
    for (PFPopCell *cell in cells) {
        if (![cell isEmptyCell]) {
            return NO;
        }
    }
    return YES;
}

-(PFPopCell *) getCell {
    PFPopCell *result = nil;
    if ((state.cell >= 0)&&(state.cell < [cells count])) {
        result = [cells objectAtIndex:state.cell];
    }
    return result;
}

@end

//
//  PFPop.h
//  PettyFunPop
//
//  Created by YJ Park on 1/6/11.
//  Copyright 2011 PettyFun.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PFItem.h"
#import "PFPopConfig.h"
#import "PFPopState.h"
#import "PFPopCell.h"

#define PFPOP_PDF_FOLDER @"pdf"
#define PFPOP_PDF_EXTENTION @"pdf"

extern NSString *const PFPOP_CELLS;
extern NSString *const PFPOP_CONFIG;
extern NSString *const PFPOP_STATE;

//Common Properties
extern NSString *const PFPOP_WIDTH;
extern NSString *const PFPOP_HEIGHT;

extern NSString *const PFPOP_LINE_WIDTH;
extern NSString *const PFPOP_COLOR;
extern NSString *const PFPOP_BGCOLOR;

//Item Type
extern NSString *const PFPOP_ITEMTYPE_IDENTITY;
extern NSString *const PFPOP_ITEMTYPE_URL_SCHEMA;
extern NSString *const PFPOP_ITEMTYPE_FILE_EXTENSION;

@interface PFPop : PFItem {
    NSMutableArray *cells;
    
    BOOL needSave;
    PFPopConfig *config;
    PFPopState *state;
}
@property (readonly) NSMutableArray *cells;
@property BOOL needSave;
@property (readonly) PFPopConfig *config;
@property (readonly) PFPopState *state;

-(BOOL) isEmptyPop;

-(PFPopCell *) getCell;

@end

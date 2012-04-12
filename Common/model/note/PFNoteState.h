//
//  PFNoteState.h
//  PettyFunNote
//
//  Created by YJ Park on 11/9/10.
//  Copyright 2010 PettyFun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PFObject.h"

extern NSString *const PFNOTE_STATE_FACTOR;
extern NSString *const PFNOTE_STATE_CHAPTER;
extern NSString *const PFNOTE_STATE_PARAGRAPH;
extern NSString *const PFNOTE_STATE_CELL;
extern NSString *const PFNOTE_STATE_NAME;

@interface PFNoteState : PFObject {
    float factor;
    int chapter;
    int paragraph;
    int cell;
    NSString *name;
}
@property float factor;
@property int chapter;
@property int paragraph;
@property int cell;
@property (nonatomic, retain) NSString *name;

@end

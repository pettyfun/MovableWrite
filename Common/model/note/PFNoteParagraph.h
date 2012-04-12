//
//  PFParagragh.h
//  PettyFunNote
//
//  Created by YJ Park on 11/8/10.
//  Copyright 2010 pettyfun.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PFObject.h"
#import "PFNoteCell.h"

extern NSString *const PFNOTE_CELLS;

@interface PFNoteParagraph : PFObject<PFParagraph> {
    NSMutableArray *cells;
    //paging related
    CGRect rect;    
}
@property (readonly) NSMutableArray *cells;

@end

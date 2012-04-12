//
//  PFChapter.h
//  PettyFunNote
//
//  Created by YJ Park on 11/8/10.
//  Copyright 2010 pettyfun.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PFObject.h"
#import "PFNoteParagraph.h"
#import "PFPageView.h"

extern NSString *const PFNOTE_PARAGRAPHES;

@interface PFNoteChapter : PFObject<PFPagable> {
    NSMutableArray *paragraphes;
}
@property (readonly) NSMutableArray *paragraphes;

-(PFNoteParagraph *) createNewParagraph;

@end

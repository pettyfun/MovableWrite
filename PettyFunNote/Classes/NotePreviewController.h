//
//  NotePreviewController.h
//  PettyFunNote
//
//  Created by YJ Park on 1/20/11.
//  Copyright 2011 PettyFun.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NoteProductController.h"
#import "PFPageView.h"
#import "PFNote.h"

#define PFNOTE_PREVIEW_PINCH_DELAY 0.0f
#define PFNOTE_PREVIEW_PINCH_DURATION 0.5f

@interface NotePreviewController : NoteProductController <PFPageViewDelegate>{
    IBOutlet PFPageView *previewPageView;
    NSMutableArray *allPages;
    PFNoteChapter *chapter;
}

-(void) _setupPreviewPageView;
-(void) _updatePreviewPage;
-(void) _onRepaintPreviewPage;

@end

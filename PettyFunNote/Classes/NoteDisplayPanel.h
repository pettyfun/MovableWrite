//
//  NoteDisplayPanel.h
//  PettyFunNote
//
//  Created by YJ Park on 11/11/10.
//  Copyright 2010 PettyFun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PFPageView.h"
#import "PFNoteTheme.h"
#import "PFNoteCell.h"

@class NoteInputPanel;

#define PFNOTE_DISPLAY_REFRESH_LOADED_CELLS_INTERVAL 0.125f
#define PFNOTE_DISPLAY_PEN_MOVE_DURATION 0.0f

@interface NoteDisplayPanel : PFViewController<PFPageViewDelegate> {
    CGPoint penOffset;
    IBOutlet PFPageView *currentPageView;
    IBOutlet UIImageView *penView;
    NoteInputPanel *inputPanel;
    
    NSTimer *refreshLoadedCellsTimer;
    NSMutableArray *loadedCells;
}

@property (nonatomic, readonly) UIView *penView;
@property (nonatomic, assign) NoteInputPanel *inputPanel;

-(void) setupCurrentPageView;
-(void) refreshCurrentCell;
-(void) calcCurrentLineRect;
-(void) refreshPenView;
-(void) resetDisplayPanel;
-(void) refreshDisplayPanel;
-(void) refreshConfig;

-(void) updateWithTheme:(PFNoteTheme *)theme;
-(void) setCurrentStroke:(PFNoteStroke *)stroke;
-(void) clearCellCache:(id<PFCell>)cell;

- (void)handleToggelInputGesture:(UIGestureRecognizer *)sender;
- (void)handlePreviewGesture:(UIGestureRecognizer *)sender;
- (void) handleTapCell:(PFNoteCell *)noteCell;
-(void) handleTapPage;

-(void) checkGestureStateBegan:(UIGestureRecognizer *)sender;

@end

//
//  NoteInputController.h
//  PettyFunNote
//
//  Created by YJ Park on 11/7/10.
//  Copyright 2010 pettyfun.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PFPageView.h"
#import "NoteDisplayPanel.h"
#import "NotePrinterPanel.h"
#import "PFNote.h"
#import "PFNoteTheme.h"
#import "PFNoteInputOptionView.h"
#import "PFNotePageNumberView.h"

#define PFNOTE_INPUT_WORD_MAX_WIDTH 9.0f

#define PFNOTE_INPUT_MAX_SAVED_OPERATIONS 500
#define PFNOTE_INPUT_REMOVE_OPERATION_LENGTH 100

#define PFNOTE_INPUT_GATE 6.0f / 256.0f

#define PFNOTE_INPUT_WORD_MARGIN_IPAD 64.0f
#define PFNOTE_INPUT_WORD_MARGIN_IPHONE 64.0f

#define PFNOTE_INPUT_COLOR_TAG_SELECET 200
#define PFNOTE_INPUT_COLOR_TAG_START 201
#define PFNOTE_INPUT_COLOR_TAG_NUM 8

#define PFNOTE_INPUT_WIDTH_TAG_SELECET 100
#define PFNOTE_INPUT_WIDTH_TAG_START 101
#define PFNOTE_INPUT_WIDTH_TAG_NUM 8

extern NSString *const NoteInputPanelLoadCellNotification;

@interface NoteInputPanel : PFViewController<PFPageViewDelegate> {
    BOOL inputEnabled;
    
    IBOutlet PFPageView *writePageView;

    IBOutlet UIToolbar *toolbar;
    IBOutlet UIBarButtonItem *hideButton;
    IBOutlet UIBarButtonItem *optionButton;
    IBOutlet UIBarButtonItem *quickOptionButton;
    IBOutlet UIBarButtonItem *undoButton;
    IBOutlet UIBarButtonItem *redoButton;
    IBOutlet UIBarButtonItem *deleteButton;          
    IBOutlet UIBarButtonItem *returnButton;          

    IBOutlet UIButton *nextWordLeftButton;
    IBOutlet UIButton *nextWordRightButton;
    IBOutlet UIButton *wrapWordLeftButton;
    IBOutlet UIButton *wrapWordRightButton;
    
    NoteDisplayPanel *displayPanel;
    CGPoint lastDragPoint;
    
    IBOutlet UIViewController *optionViewController;
    BOOL optionMode;
    NSInteger lineWidthIndex, colorIndex;
    UIView *widthSelectedIcon;
    UIView *colorSelectedIcon;
    PFNoteInputOptionView *optionStatusView;
    
    NSMutableArray *savedOperations;
    
    PFNotePageNumberView *pageNumberView;
}
@property (nonatomic, assign) NoteDisplayPanel *displayPanel;
@property (nonatomic, assign) BOOL inputEnabled;


-(IBAction) onPages:(id)sender;

-(IBAction) onHide:(id)sender;
-(IBAction) onOption:(id)sender;
-(IBAction) onQuickOption:(id)sender;
-(IBAction) onUndo:(id)sender;
-(IBAction) onRedo:(id)sender;
-(IBAction) onDelete:(id)sender;
-(IBAction) onReturn:(id)sender;
-(IBAction) onSpace:(id)sender;

-(IBAction) onWrapWordLeft:(id)sender;
-(IBAction) onWrapWordRight:(id)sender;
-(IBAction) onNextWord:(id)sender;
-(void) appendEmptyWordCell;

-(void) setupWritePageView;

-(void) resizeInputPanel:(CGSize)windowSize;
-(void) resetInputPanel;
-(void) refreshInputPanel;

-(BOOL) normalizeCurrentInputCell;

-(void) setupOptionView;

-(void) updateWithTheme:(PFNoteTheme *)theme;
-(void) refreshConfig;
-(void) onPageUpdate:(int)currentPageIndex pageNum:(int)pageNum;

-(void) setCurrentStroke:(PFNoteStroke *)stroke;

-(CGPoint)_getCellLeftRight:(PFNoteCell *)cell;
-(void) _resetInputCell;
-(void) _adjustInputCell;
-(BOOL) _adjustDisplayCell;
-(void) _adjustInputCellByStrokes;
-(float) _normalizeWordStrokesOfCell:(PFNoteCell *)cell withOffset:(float)offset;

-(void) _updateOptionViews;
-(void) _updateColorSelectedIcon;

-(void) _updateOptionViews;
-(void) _updateWidthSelectedIcon;

@end

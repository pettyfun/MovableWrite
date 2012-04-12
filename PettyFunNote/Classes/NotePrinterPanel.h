//
//  NotePrinterPanel.h
//  PettyFunNote
//
//  Created by YJ Park on 11/19/10.
//  Copyright 2010 PettyFun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PFPageView.h"
#import "PFNote.h"
#import "PFNotePageNumberView.h"

#define PFNOTE_PRINT_PAGE_DELAY 0.2f
#define PFNOTE_PRINT_HIDE_PAGENUM_DELAY 3.0f
#define PFNOTE_PRINT_TOGGLE_PAGENUM_DURATION 1.0f
#define PFNOTE_PRINT_PAGENUM_HEIGHT 30.0f

extern NSString *const NotePrinterPanelLoadCellNotification;
extern NSString *const NotePrinterPanelClearCellCacheNotification;

typedef enum {
    NotePrinterPanelModePreview,
    NotePrinterPanelModePrint
} NotePrinterPanelMode;

@protocol NotePrinterPanelDelegate<NSObject>
@required
-(void) onPreviewFinished;
-(void) onPrintFinished;
@end
    
@interface NotePrinterPanel:PFViewController<PFPageViewDelegate> {
    IBOutlet PFPageView *printPageView;
    id<NotePrinterPanelDelegate> delegate;
    CGContextRef pdfContext;
    
    NotePrinterPanelMode mode;
    int currentPageIndex;
    
    PFNotePageNumberView *pageNumberView;
    
    NSTimer *refreshLoadedCellsTimer;
    NSMutableArray *loadedCells;
}
@property (nonatomic, assign) NotePrinterPanelMode mode;
@property (nonatomic, assign) id<NotePrinterPanelDelegate> delegate;

-(void) _print;
-(void) _preview;

-(void) _setupPrintPageView;
-(void) _updatePrintPageView;
-(void) _clearCellCache;

-(void) _startPDFPrint;
-(void) _finishPDFPrint;
-(void) _beginPDFPage;
-(void) _endPDFPage;
    
-(void) _finishPDFPrint;
-(void) _notifyDelegate;

-(void) _onPrintPage:(NSTimer *)timer;
-(void) _onPrintFinished:(NSTimer *)timer;

-(void) _printNextPage:(NSTimer *)timer;
-(void) _updateHUD;

-(void) _showPageNumberView;

@end

    //
//  NotePrinterPanel.m
//  PettyFunNote
//
//  Created by YJ Park on 11/19/10.
//  Copyright 2010 PettyFun. All rights reserved.
//

#import "NotePrinterPanel.h"
#import "PFNotePainterFactory.h"
#import "PFNoteModel.h"
#import "NoteDisplayPanel.h"
#import "PFBaseBezierPainter.h"

NSString *const NotePrinterPanelLoadCellNotification = @"NotePrinterPanelLoadCellNotification";
NSString *const NotePrinterPanelClearCellCacheNotification = @"NotePrinterPanelClearCellCacheNotification";

@implementation NotePrinterPanel
@synthesize mode;
@synthesize delegate;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    [self _setupPrintPageView];
    self.wantsFullScreenLayout = YES;
    self.view.backgroundColor = [UIColor blackColor];
    self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;    
    self.modalPresentationStyle = UIModalPresentationFullScreen;

    CGRect numberFrame = CGRectMake(0.0f,
                                    self.view.bounds.size.height,
                                    self.view.bounds.size.width,
                                    PFNOTE_PRINT_PAGENUM_HEIGHT);
    pageNumberView = [[PFNotePageNumberView alloc] initWithFrame:numberFrame];
    [self.view addSubview:pageNumberView];
}

- (void)releaseViewElements {
    [super releaseViewElements];
    PF_Release_IBOutlet(printPageView)
    [pageNumberView removeFromSuperview];
    [pageNumberView release];
    pageNumberView = nil;
}

// Override to allow orientations other than the default portrait orientation.
-(BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return [UIApplication sharedApplication].statusBarOrientation == interfaceOrientation;
}

- (void)dealloc {
    [super dealloc];
}

-(void) viewDidAppear:(BOOL)animated {
    DECLARE_PFNOTE_MODEL
    model.writing = YES;
    [super viewDidAppear:animated];   
    [self _updatePrintPageView];
    
    CGRect numberFrame = CGRectMake(0.0f,
                                    self.view.bounds.size.height,
                                    self.view.bounds.size.width,
                                    PFNOTE_PRINT_PAGENUM_HEIGHT);
    pageNumberView.frame = numberFrame;

    loadedCells = [[NSMutableArray alloc] init];
    refreshLoadedCellsTimer = [[NSTimer
                                scheduledTimerWithTimeInterval:PFNOTE_DISPLAY_REFRESH_LOADED_CELLS_INTERVAL
                                target:self
                                selector:@selector(refreshLoadedCells:)
                                userInfo:nil
                                repeats:YES] retain];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onCellLoaded:)
                                                 name:NotePrinterPanelLoadCellNotification
                                               object:nil];
    if (mode == NotePrinterPanelModePrint) {
        [self _print];                
    } else if (mode == NotePrinterPanelModePreview) {
        [self _preview];
    }
}

-(void) viewDidDisappear:(BOOL)animated {
    //Have to hook to DidDisappear, for the comming mailer dialog
    [super viewDidDisappear:animated];    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [refreshLoadedCellsTimer invalidate];
    [refreshLoadedCellsTimer release];
    refreshLoadedCellsTimer = nil;
    [loadedCells release];
    loadedCells = nil;
    DECLARE_PFNOTE_MODEL
    model.writing = NO;
    [self _notifyDelegate];
}

-(void) onCellLoaded:(NSNotification *)notification {
    //return;
    id<PFCell> cell = (id<PFCell>)notification.object;
    @synchronized(loadedCells) {
        [loadedCells addObject:cell];
    }
}

-(void) refreshLoadedCells:(NSTimer *)timer {
    @synchronized(loadedCells) {
        for (id<PFCell> cell in loadedCells) {
            if ([printPageView.page containsCell:cell]) {
                [printPageView setNeedsDisplayInRect:[cell getRect]];
            }
        }
        [loadedCells removeAllObjects];
    }    
}

-(void) _clearCellCache {
    [[NSNotificationCenter defaultCenter] postNotificationName:NotePrinterPanelClearCellCacheNotification object:self];
    @synchronized(loadedCells) {
        [loadedCells removeAllObjects];
    }        
    DECLARE_PFUTILS
    [utils clearCache:PFNOTE_CELL_CACHE_PREFIX];
}

#pragma mark -
#pragma mark Specific Methods

-(void) _notifyDelegate {
    if (delegate) {
        if (mode == NotePrinterPanelModePrint) {
            [delegate onPrintFinished];
        } else if (mode == NotePrinterPanelModePreview) {
            [delegate onPreviewFinished];
        }
    }
}

-(void) _updatePrintPageView {
    DECLARE_PFNOTE_MODEL
    DECLARE_PFNOTE_PAINTER_FACTORY
    PFNoteTheme *theme = [painterFactory getThemeByType:model.note.config.themeType];
    self.view.backgroundColor = [theme getPaperColor:[model iPadLandScape]];
    pageNumberView.theme = theme;
    
    printPageView.pageConfig.showingControlCharactors = NO;
    [printPageView.pagePainter refreshConfig];

    [printPageView setTurnPageLeft:[theme getImage:PFNoteThemeImageDisplayTurnPageLeft]
                             right:[theme getImage:PFNoteThemeImageDisplayTurnPageRight]];

    PFNotePagePainter *pagePainter = (PFNotePagePainter *)printPageView.pagePainter;
    if (mode == NotePrinterPanelModePrint) {
        pagePainter.usingCellCache = NO;
        printPageView.handlePinch = NO;
        printPageView.handlePan = NO;
    } else if (mode == NotePrinterPanelModePreview) {
        pagePainter.usingCellCache = YES;
        printPageView.handlePinch = YES;
        printPageView.handlePan = YES;
    }
    
    [model resizeCurrentPageTo:printPageView.frame.size];
}

-(void) _refreshPreviewPageView {
    DECLARE_PFNOTE_MODEL
    printPageView.page = [model getPage:currentPageIndex];
    [printPageView setNeedsDisplay];    
    if ((mode == NotePrinterPanelModePreview) && (printPageView.page)) {
        pageNumberView.currentPageNumber = currentPageIndex;
        pageNumberView.totalPageNumber = [model.allPages count];
        [pageNumberView setNeedsDisplay];
        [self _showPageNumberView];
    }
}

-(void) _showPageNumberView {
    //old style for threading
    [UIView beginAnimations:@"PRINTER_SHOW_NUMBER" context:NULL];
    CGRect numberFrame = CGRectMake(0.0f,
                                    self.view.bounds.size.height - PFNOTE_PRINT_PAGENUM_HEIGHT,
                                    self.view.bounds.size.width,
                                    PFNOTE_PRINT_PAGENUM_HEIGHT);
    pageNumberView.frame = numberFrame;
    [UIView commitAnimations];
    PFUTILS_delayWithInterval(PFNOTE_PRINT_HIDE_PAGENUM_DELAY,
                              [NSNumber numberWithInt:currentPageIndex],
                              _hidePageNumberView:)    
}

-(void) _hidePageNumberView:(NSTimer *)timer {
    if (currentPageIndex == [(NSNumber *)timer.userInfo intValue]) {
        //old style for threading
        [UIView beginAnimations:@"PRINTER_HIDE_NUMBER" context:NULL];
        CGRect numberFrame = CGRectMake(0.0f,
                                        self.view.bounds.size.height,
                                        self.view.bounds.size.width,
                                        PFNOTE_PRINT_PAGENUM_HEIGHT);
        pageNumberView.frame = numberFrame;
        [UIView commitAnimations];
    }
}

-(void) _setupPrintPageView {
    DECLARE_PFNOTE_MODEL
    printPageView.pageConfig = model.config;
    DECLARE_PFNOTE_PAINTER_FACTORY
    PFNotePagePainter *pagePainter = [painterFactory factoryPagePainter];
    pagePainter.loadNotification = NotePrinterPanelLoadCellNotification;
    pagePainter.clearNotification = NotePrinterPanelClearCellCacheNotification;
    printPageView.pagePainter = pagePainter;
    printPageView.page = nil;
    printPageView.delegate = self;
    printPageView.backgroundColor = [UIColor clearColor];
    
    [printPageView initGestures];
    
    UILongPressGestureRecognizer *previewGesture = [[UILongPressGestureRecognizer alloc]
                                                    initWithTarget:self
                                                    action:@selector(handleFinishPreviewGesture:)];
    [printPageView addGestureRecognizer:previewGesture]; 
    [previewGesture release];        

    UITapGestureRecognizer *tapPreviewGesture = [[UITapGestureRecognizer alloc]
                                              initWithTarget:self
                                              action:@selector(handleFinishPreviewGesture:)];
    tapPreviewGesture.numberOfTapsRequired = 2;
    [printPageView addGestureRecognizer:tapPreviewGesture]; 
    [tapPreviewGesture release];    
}

#pragma mark -
#pragma mark Print Specific Methods

-(void) _print {
    DECLARE_PFUTILS
    [utils showProgressHUD:self.view withText:PF_L10N(@"print_printing")];
    PFUTILS_delayWithInterval(0.0f, nil, _printStart:);
}

-(void) _startPDFPrint {
    DECLARE_PFNOTE_MODEL
    CGRect pageRect = printPageView.frame;

    NSString *path = [model.note getPDFPath];
    CFURLRef url = CFURLCreateWithFileSystemPath (NULL, (CFStringRef)path,
                                         kCFURLPOSIXPathStyle, 0);
    CFMutableDictionaryRef pdfDictionary = CFDictionaryCreateMutable(NULL, 0,
                                             &kCFTypeDictionaryKeyCallBacks,
                                             &kCFTypeDictionaryValueCallBacks);
    CFDictionarySetValue(pdfDictionary, kCGPDFContextTitle, (CFStringRef)model.note.name);
    CFDictionarySetValue(pdfDictionary, kCGPDFContextCreator, CFSTR("Movable Write"));
    pdfContext = CGPDFContextCreateWithURL (url, &pageRect, pdfDictionary);
    CFRelease(pdfDictionary);
    CFRelease(url);
}
 
-(void) _beginPDFPage {
    CGRect pageRect = printPageView.frame;
    CGContextBeginPage (pdfContext, &pageRect); 
    DECLARE_PFNOTE_PAINTER_FACTORY
    DECLARE_PFNOTE_MODEL
    PFNoteTheme *theme = [painterFactory getTheme:model.config];
    UIImage *paperImage = [theme getImage:PFNoteThemeImagePaper];
    CGContextClipToRect(pdfContext, pageRect);
    if (paperImage) {
        CGContextDrawImage(pdfContext, pageRect, paperImage.CGImage);
    } else {
        CGContextSetFillColorWithColor(pdfContext, theme.backgroundColor.CGColor);
        CGContextFillRect(pdfContext, pageRect);
    }
    if (model.config.showingWatermark) {
        UIImage *watermarkImage = [theme getImage:PFNoteThemeImageWatermark];
        if (watermarkImage) {
            CGRect watermarkRect = CGRectMake(0, 0,
                                              watermarkImage.size.width,
                                              watermarkImage.size.height);
            CGContextDrawTiledImage(pdfContext, watermarkRect, watermarkImage.CGImage);
        }
        model.config.showingWatermark = NO;
    }
    CGContextTranslateCTM (pdfContext, 0.0f, pageRect.size.height);
    CGContextScaleCTM(pdfContext, 1.0f, -1.0f);
}

-(void) _endPDFPage {
    CGContextEndPage (pdfContext);
}

-(void) _finishPDFPrint {
    CGContextRelease (pdfContext);
}

-(void) _onPrintPage:(NSTimer *)timer{
    NSLog(@"page Rect = %@", NSStringFromCGRect(printPageView.frame));
    [self _beginPDFPage];
    [printPageView drawRect:printPageView.frame onContext:pdfContext];
    [self _endPDFPage];
    PFUTILS_delayWithInterval(PFNOTE_PRINT_PAGE_DELAY, nil, _printNextPage:)
}

-(void) _onPrintFinished:(NSTimer *)timer {
    [self _finishPDFPrint];
    DECLARE_PFUTILS
    [utils hideProgressHUD];
    [self dismissModalViewControllerAnimated:YES];
}

-(void) _printStart:(NSTimer *)timer {
    [self _startPDFPrint];
    printPageView.page = nil;

    currentPageIndex = -1;
    [printPageView setNeedsDisplay];
    PFUTILS_delayWithInterval(PFNOTE_PRINT_PAGE_DELAY, nil, _printNextPage:)
}

#pragma mark -
#pragma mark page flow control

-(void) _updateHUD {
    DECLARE_PFUTILS
    DECLARE_PFNOTE_MODEL
    NSString *text = PF_L10N(@"print_printing");
    if (currentPageIndex + 1 < [model.allPages count]) {
        text = NSFormat(@"%@ ( %d / %d )",
                        text,
                        (currentPageIndex + 1),
                        [model.allPages count]);
    }
    [utils updateProgressHUD:text];
}

-(void) _printNextPage:(NSTimer *)timer {
    currentPageIndex ++;
    [self _updateHUD];
    [self _refreshPreviewPageView];
    if (printPageView.page) {
        PFUTILS_delayWithInterval(PFNOTE_PRINT_PAGE_DELAY, nil, _onPrintPage:)
    } else {
        DECLARE_PFNOTE_MODEL
        if (model.iPadMode) {
            //Have to put the statusbar logic here, otherwise not work
            [UIApplication sharedApplication].statusBarHidden = NO;    
        }
        PFUTILS_delayWithInterval(PFNOTE_PRINT_PAGE_DELAY, nil, _onPrintFinished:)
    }
}

#pragma mark -
#pragma mark Preview releated

-(void) _preview {
    DECLARE_PFNOTE_MODEL
    currentPageIndex = [model getCurrentPageIndex ];
    [self _refreshPreviewPageView];
}

-(void) _onPreviewFinished:(NSTimer *)timer {
    [self dismissModalViewControllerAnimated:YES];
}

-(void) onPinch:(PFPageView *)pageView
         sender:(UIPinchGestureRecognizer *)sender {
    if (mode != NotePrinterPanelModePreview) return;    
    DECLARE_PFNOTE_MODEL
    if (UIGestureRecognizerStateBegan == [sender state]) {
        model.writing = YES;    
    } else if (UIGestureRecognizerStateChanged == [sender state]) {
    } else if (UIGestureRecognizerStateEnded == [sender state]) {
        [model scale:sender.scale];
    } else if (UIGestureRecognizerStateCancelled == [sender state]) {
        model.writing = NO;
    } else if (sender == nil) {
        currentPageIndex = [model getCurrentPageIndex];
        [self _refreshPreviewPageView];
        model.writing = NO;
    }
}

-(void) onPan:(PFPageView *)pageView
       sender:(UIPanGestureRecognizer *)sender {
    if (mode != NotePrinterPanelModePreview) return;    
    DECLARE_PFNOTE_MODEL
    if (UIGestureRecognizerStateBegan == [sender state]) {
        model.writing = YES;    
    } else if (UIGestureRecognizerStateChanged == [sender state]) {
    } else if (UIGestureRecognizerStateEnded == [sender state]) {
    } else if (UIGestureRecognizerStateCancelled == [sender state]) {
        model.writing = NO;
    } else if (sender == nil) {
        [self _refreshPreviewPageView];
        model.writing = NO;
    }
}

-(BOOL) canTurnPage:(PFPageView *)pageView
               back:(BOOL)back {
    DECLARE_PFNOTE_MODEL
    if (back) {
        return [model getCurrentPageIndex] > 0;
    } else {
        return [model getCurrentPageIndex] + 1 < [model.allPages count];
    }
}

-(BOOL) doTurnPage:(PFPageView *)pageView
              back:(BOOL)back {
    DECLARE_PFNOTE_MODEL
    BOOL result = NO;
    if (back) {
        result = [model pageUp];
    } else {
        result = [model pageDown];
    }
    if (result) {
        currentPageIndex = [model getCurrentPageIndex];
    }
    return result;
}

- (void)handleFinishPreviewGesture:(UIGestureRecognizer *)sender {
    if (mode != NotePrinterPanelModePreview) return;
    if(UIGestureRecognizerStateEnded == [sender state]) {
        DECLARE_PFNOTE_MODEL
        if (model.iPadMode) {
            //Have to put the statusbar logic here, otherwise not work
            [UIApplication sharedApplication].statusBarHidden = NO;    
        }
        PFUTILS_delayWithInterval(PFNOTE_PRINT_PAGE_DELAY, nil, _onPreviewFinished:)
    }
}

@end

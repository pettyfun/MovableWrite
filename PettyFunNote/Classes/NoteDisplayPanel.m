//
//  NoteDisplayPanel.m
//  PettyFunNote
//
//  Created by YJ Park on 11/11/10.
//  Copyright 2010 PettyFun. All rights reserved.
//

#import "NoteAppDelegate.h"
#import "NoteDisplayPanel.h"
#import "PFNoteModel.h"
#import "PFNotePainterFactory.h"
#import "NoteInputPanel.h"
#import "UIGestureRecognizer+Expanded.h"

@implementation NoteDisplayPanel
@synthesize penView;
@synthesize inputPanel;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupCurrentPageView];
    penView.hidden = YES;
    loadedCells = [[NSMutableArray alloc] init];
    refreshLoadedCellsTimer = [[NSTimer
                               scheduledTimerWithTimeInterval:PFNOTE_DISPLAY_REFRESH_LOADED_CELLS_INTERVAL
                               target:self
                               selector:@selector(refreshLoadedCells:)
                               userInfo:nil
                               repeats:YES] retain];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onClearCellsCache:)
                                                 name:PFNotePagePainterClearCellCacheNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onCellLoaded:)
                                                 name:PFNotePagePainterLoadCellNotification
                                               object:nil];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)releaseViewElements {
    [super releaseViewElements];
    [refreshLoadedCellsTimer invalidate];
    [refreshLoadedCellsTimer release];
    refreshLoadedCellsTimer = nil;
    [loadedCells release];
    loadedCells = nil;
    PF_Release_IBOutlet(currentPageView)
    PF_Release_IBOutlet(penView)
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    //Not rotate since this is used as subview
    return NO;
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc. that aren't in use.
}

- (void)dealloc {
    [super dealloc];
}

#pragma mark -
#pragma mark Specific methods

-(void) setupCurrentPageView {
    DECLARE_PFNOTE_MODEL
    currentPageView.pageConfig = model.config;
    DECLARE_PFNOTE_PAINTER_FACTORY
    PFNotePagePainter *pagePainter = [painterFactory factoryPagePainter];
    [pagePainter setUsingCellCache:YES];
    currentPageView.pagePainter = pagePainter;
    currentPageView.page = model.currentPage;
    currentPageView.delegate = self;
    currentPageView.backgroundColor = [UIColor clearColor];
    currentPageView.handlePinch = YES;
    currentPageView.handlePan = YES;
    [currentPageView initGestures];

    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]
                                                  initWithTarget:self
                                                  action:@selector(handleTapGesture:)];
    tapGesture.numberOfTapsRequired = 1;
    [currentPageView addGestureRecognizer:tapGesture]; 
    [tapGesture release];
    
    UITapGestureRecognizer *toggleInputGesture = [[UITapGestureRecognizer alloc]
                                                  initWithTarget:self
                                                  action:@selector(handleToggelInputGesture:)];
    toggleInputGesture.numberOfTapsRequired = 2;
    [currentPageView addGestureRecognizer:toggleInputGesture]; 
    [toggleInputGesture release];
    
    UILongPressGestureRecognizer *previewGesture = [[UILongPressGestureRecognizer alloc]
                                                     initWithTarget:self
                                                     action:@selector(handlePreviewGesture:)];
    [currentPageView addGestureRecognizer:previewGesture]; 
    [previewGesture release];    
}

-(void) onCellLoaded:(NSNotification *)notification {
    //return;
    id<PFCell> cell = (id<PFCell>)notification.object;
    @synchronized(loadedCells) {
        [loadedCells addObject:cell];
    }
}

-(void) refreshLoadedCells:(NSTimer *)timer {
    DECLARE_PFNOTE_MODEL
    PFNOTE_CHECK_WRITING
    @synchronized(loadedCells) {
        for (id<PFCell> cell in loadedCells) {
            if ([currentPageView.page containsCell:cell]) {
                [currentPageView setNeedsDisplayInRect:[cell getRect]];
            }
        }
        [loadedCells removeAllObjects];
    }    
}

-(void) onClearCellsCache:(NSTimer *)timer {
    @synchronized(loadedCells) {
        [loadedCells removeAllObjects];
    }    
}

-(void) calcCurrentLineRect {
    DECLARE_PFNOTE_MODEL
    PFNoteCell *currentCell = [model getCurrentCell];
    if (currentCell) {
        CGRect cellRect = [currentCell getRect];
        id<PFParagraph> paragraph = [model.currentPage getParapraphOfCell:currentCell];
        NSMutableArray *lineCells = [NSMutableArray array];
        if (paragraph) {
            for (id<PFCell> oneCell in [paragraph getCells]) {
                CGRect oneCellRect = [oneCell getRect];
                if (oneCellRect.origin.y == cellRect.origin.y) {
                    [lineCells addObject:oneCell];
                }
            }
        }
        if ([lineCells count] > 0) {
            CGRect updatedRect = CGRectNull;
            for (id<PFCell> oneCell in lineCells) {
                CGRect oneCellRect = [oneCell getRect];
                updatedRect = CGRectUnion(updatedRect, oneCellRect);
            }
            PFDebug(@"line updatedRect = %@", NSStringFromCGRect(updatedRect));
            [model.currentPage setUpdatedRect:updatedRect];
        }
    }
}

-(void) refreshCurrentCell {
    DECLARE_PFNOTE_MODEL
    id<PFCell> lastCurrentCell = [currentPageView.pagePainter getCurrentCell];
    PFNoteCell *currentCell = [model getCurrentCell];

    if (inputPanel.inputEnabled) {
        if (lastCurrentCell != currentCell) {
            [self setCurrentStroke:nil];
            [currentPageView.pagePainter setCurrentCell:currentCell];        
        }
    } else {
        [currentPageView.pagePainter setCurrentCell:nil];        
    }

    if (lastCurrentCell != currentCell) {
        [currentPageView repaintCell:lastCurrentCell];    
    }
    
    [currentPageView repaintCell:currentCell];
    [self refreshPenView];
}    

-(void) setCurrentStroke:(PFNoteStroke *)stroke {
    [((PFNotePagePainter *)currentPageView.pagePainter) setCurrentStroke:stroke];    
}

-(void) clearCellCache:(id<PFCell>)cell {
    [((PFNotePagePainter *)currentPageView.pagePainter) clearCellCache:cell];
}

-(void) refreshPenView {
    if (!inputPanel.inputEnabled) {
        return;
    }
    DECLARE_PFNOTE_MODEL
    float factor = model.config.factor;
    CGPoint penPos = CGPointZero;
    PFNoteCell *currentCell = [model getCurrentCell];

    CGRect cellRect = [currentCell getRect];
    CGPoint offset = [currentCell getOffsetWithConfig:model.config];
    float offsetX = cellRect.origin.x + offset.x;
    float offsetY = cellRect.origin.y + offset.y;
    PFNoteStroke *stroke = [currentCell getLastStroke];
    if (stroke) {
        PFPoint *point = [stroke getLastPoint];
        if (point) {
            penPos = CGPointMake(offsetX + (stroke.offset.x + point.x) * factor,
                                 offsetY + (stroke.offset.y + point.y) * factor);
        } else {
            penPos = CGPointMake(offsetX + (stroke.offset.x) * factor,
                                 offsetY + (stroke.offset.y) * factor);
        }
    } else {
        penPos = CGPointMake(offsetX + PEN_CELL_OFFSET_X * factor,
                             offsetY + PEN_CELL_OFFSET_Y * factor);                
    }
        
    //has to use the old way for thread issue;
    [UIView beginAnimations:@"PEN_MOVEMENT" context:NULL];
    if (currentCell.type == PFNOTE_CELL_TYPE_WORD) {
        penView.hidden = NO;
    } else {
        penView.hidden = YES;
    }
    penView.frame = CGRectMake(penPos.x + penOffset.x, penPos.y + penOffset.y,
                               penView.frame.size.width, penView.frame.size.height);
    //NSLog(@"pen frame = %@", NSStringFromCGRect(penView.frame));
    [UIView commitAnimations];
}

-(void) resetDisplayPanel {
    currentPageView.pageConfig.showingControlCharactors = inputPanel.inputEnabled;
    [self onResize:currentPageView to:currentPageView.frame.size];
    [self refreshDisplayPanel];
}

-(void) refreshDisplayPanel {
    [currentPageView setNeedsDisplay];
    [self refreshCurrentCell];
}

-(void) refreshConfig {
    [currentPageView.pagePainter refreshConfig];
}

#pragma mark -
#pragma mark PFPageViewDelegate
-(void) onResize: (PFPageView *)pageView
              to:(CGSize)viewSize {
    PFDebug(@"currentPage onResize: to: %@", NSStringFromCGSize(viewSize));
    DECLARE_PFNOTE_MODEL
    [model resizeCurrentPageTo:viewSize];
    [self refreshDisplayPanel];
}

#pragma mark -
#pragma mark Gesture handlers

-(void) _onPageChanged:(NSTimer *)timer {
    UIViewAnimationOptions option = UIViewAnimationOptionTransitionCurlDown;
    if (timer.userInfo && [(NSNumber *)timer.userInfo boolValue]) {
        option = UIViewAnimationOptionTransitionCurlUp;
    }
    [UIView transitionWithView:self.view
                      duration:0.5f
                       options:option
                    animations:^{
                        DECLARE_PFNOTE_MODEL
                        model.writing = YES;
                        currentPageView.page = nil;                        
                        [self refreshDisplayPanel];
                    }
                    completion:^(BOOL finished){
                        DECLARE_PFNOTE_MODEL
                        model.writing = NO;
                        if (inputPanel.inputEnabled) {
                            [inputPanel resetInputPanel];
                        }
                        currentPageView.page = model.currentPage;
                        [self refreshDisplayPanel];
                    }];
}

-(void) checkGestureStateBegan:(UIGestureRecognizer *)sender {
    DECLARE_PFNOTE_MODEL
    BOOL resetPage = NO;
    if (inputPanel.inputEnabled) {
        resetPage = [inputPanel normalizeCurrentInputCell];
    }
    if (resetPage) {
        [model resetPages];
        [self refreshDisplayPanel];
        [inputPanel resetInputPanel];
        [sender pf_cancel];
    } else {
        model.writing = YES;    
    }
}

-(void) onPan:(PFPageView *)pageView
         sender:(UIPanGestureRecognizer *)sender {
    DECLARE_PFNOTE_MODEL
    
    if (UIGestureRecognizerStateBegan == [sender state]) {
        [self checkGestureStateBegan:sender];
    } else if (UIGestureRecognizerStateChanged == [sender state]) {
    } else if (UIGestureRecognizerStateEnded == [sender state]) {
    } else if (UIGestureRecognizerStateCancelled == [sender state]) {
        model.writing = NO;
    } else if (sender == nil) {
        [self refreshDisplayPanel];
        if (inputPanel.inputEnabled) {
            [inputPanel resetInputPanel];
        }
        model.writing = NO;        
    }
}

-(void) onPinch:(PFPageView *)pageView
         sender:(UIPinchGestureRecognizer *)sender {
    DECLARE_PFNOTE_MODEL

    if (UIGestureRecognizerStateBegan == [sender state]) {
        [self checkGestureStateBegan:sender];
    } else if (UIGestureRecognizerStateChanged == [sender state]) {
    } else if (UIGestureRecognizerStateEnded == [sender state]) {
        [model scale:sender.scale];
    } else if (UIGestureRecognizerStateCancelled == [sender state]) {
        model.writing = NO;
    } else if (sender == nil) {
        [self refreshDisplayPanel];
        if (inputPanel.inputEnabled) {
            [inputPanel refreshInputPanel];
        }
        model.writing = NO;        
    }
}

- (void)handleTapGesture:(UITapGestureRecognizer *)sender {
    DECLARE_PFNOTE_MODEL
    PFNOTE_CHECK_WRITING
    id cellOrPage = [currentPageView getCellOrPage:[sender locationInView:currentPageView]];
    if (cellOrPage && [[cellOrPage class] isSubclassOfClass:[PFNoteCell class]]) {
        [self handleTapCell:(PFNoteCell *)cellOrPage];
    } else {
        [self handleTapPage];
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
    return result;
}

-(void) handleTapCell:(PFNoteCell *)noteCell {
    DECLARE_PFNOTE_MODEL
    if (!inputPanel.inputEnabled) {
        [model.note seekCell:noteCell];
        return;
    }    
    PFNOTE_CHECK_WRITING
    PFNoteCell *currentCell = [model getCurrentCell];
    if (currentCell != noteCell) {
        BOOL resetPage = [inputPanel normalizeCurrentInputCell];
        [model.note seekCell:noteCell];
        if (resetPage) {
            [model resetPages];
            [self refreshDisplayPanel];
        } else {
            [self refreshCurrentCell];
        }
        [inputPanel resetInputPanel];
    } else {
        [self refreshCurrentCell];        
    }
}

-(void) handleTapPage {
    if (inputPanel.inputEnabled) {
        penView.hidden = YES;
    }
}

- (void)handleToggelInputGesture:(UIGestureRecognizer *)sender {
    DECLARE_PFNOTE_MODEL
    PFNOTE_CHECK_WRITING
    if(UIGestureRecognizerStateEnded == [sender state]) {
        NoteAppDelegate *delegate = (NoteAppDelegate *)[UIApplication sharedApplication].delegate;
        [delegate onToggleInput:nil];
    }
}

- (void)handlePreviewGesture:(UIGestureRecognizer *)sender {
    DECLARE_PFNOTE_MODEL
    PFNOTE_CHECK_WRITING
    if(UIGestureRecognizerStateEnded == [sender state]) {
        NoteAppDelegate *delegate = (NoteAppDelegate *)[UIApplication sharedApplication].delegate;
        [delegate onPreview:nil];
    }
}

-(void) updateWithTheme:(PFNoteTheme *)theme {
    DECLARE_PFNOTE_MODEL
    self.view.backgroundColor = [theme getPaperColor:[model iPadLandScape]];
    UIImage *image = [theme getImage:PFNoteThemeImageDisplayHand];
    if (image) {
        [penView setImage:image];
        penView.frame = CGRectMake(0.0f, 0.0f, image.size.width, image.size.height);
        penOffset = [theme getDisplayHandOffset];
    }
    [currentPageView setTurnPageLeft:[theme getImage:PFNoteThemeImageDisplayTurnPageLeft]
                               right:[theme getImage:PFNoteThemeImageDisplayTurnPageRight]];
    [self refreshConfig];
}

@end

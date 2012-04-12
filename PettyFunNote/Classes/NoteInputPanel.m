
//
//  NoteInputController.m
//  PettyFunNote
//
//  Created by YJ Park on 11/7/10.
//  Copyright 2010 pettyfun.com. All rights reserved.
//

#import "PFToolBar.h"
#import "NoteInputPanel.h"
#import "PFNotePainterFactory.h"
#import "PFNoteModel.h"
#import "NoteAppDelegate.h"

NSString *const NoteInputPanelLoadCellNotification = @"NoteInputPanelLoadCellNotification";

@implementation NoteInputPanel

@synthesize displayPanel;
@synthesize inputEnabled;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupWritePageView];
    [self setupOptionView];
    PF_L10N_VIEW(198, @"input_option_color");
    PF_L10N_VIEW(298, @"input_option_width");
    wrapWordLeftButton.hidden = YES;
    wrapWordRightButton.hidden = YES;
    savedOperations = [[NSMutableArray alloc] init];

    DECLARE_PFNOTE_MODEL
    CGFloat optionWidth = model.iPadMode ? 128 : 80;
    CGRect rect = CGRectMake(0.0f, 0.0f, optionWidth, 48.0f);
    optionStatusView = [[PFNoteInputOptionView alloc] initWithFrame:rect];
    [optionStatusView addTarget:quickOptionButton.target
                         action:quickOptionButton.action
               forControlEvents:UIControlEventTouchUpInside];
    quickOptionButton.customView = optionStatusView;
    
    if (model.iPadMode) {
        CGRect numberFrame = CGRectMake(0.0f, 0.0f,
                                        toolbar.frame.size.width,
                                        toolbar.frame.size.height);
        pageNumberView = [[PFNotePageNumberView alloc] initWithFrame:numberFrame];
        [toolbar addSubview:pageNumberView];
        [toolbar sendSubviewToBack:pageNumberView];
        [pageNumberView addTarget:self
                           action:@selector(onPages:)
                 forControlEvents:UIControlEventTouchUpInside];    
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onCellLoaded:)
                                                 name:NoteInputPanelLoadCellNotification
                                               object:nil];
    
    self.view.clipsToBounds = YES;
}

- (void)releaseViewElements {
    [super releaseViewElements];
    [optionStatusView removeFromSuperview];
    PF_Release_And_Nil(optionStatusView);
    
    [pageNumberView removeFromSuperview];
    PF_Release_And_Nil(pageNumberView);    

    PF_Release_IBOutlet(hideButton);
    PF_Release_IBOutlet(optionButton)
    PF_Release_IBOutlet(quickOptionButton)
    PF_Release_IBOutlet(undoButton)
    PF_Release_IBOutlet(redoButton)
    PF_Release_IBOutlet(deleteButton)
    PF_Release_IBOutlet(returnButton)
    PF_Release_IBOutlet(nextWordLeftButton)
    PF_Release_IBOutlet(nextWordRightButton)
    PF_Release_IBOutlet(wrapWordLeftButton)
    PF_Release_IBOutlet(wrapWordRightButton)
}

- (void)dealloc {
    [savedOperations release];
    [super dealloc];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    //Not rotate since this is used as subview
    return NO;
}

#pragma mark -
#pragma mark Specific methods

-(void) onCellLoaded:(NSNotification *)notification {
    DECLARE_PFNOTE_MODEL
    if (!model.writing) {
        [self performSelectorOnMainThread:@selector(refreshInputPanel) withObject:nil waitUntilDone:NO];
    }
}

- (void) setupWritePageView {
    ((PFToolBar *)toolbar).transparent = YES;
    toolbar.backgroundColor = [UIColor clearColor];
    
    DECLARE_PFNOTE_MODEL
    writePageView.pageConfig = model.inputPageConfig;
    DECLARE_PFNOTE_PAINTER_FACTORY
    PFNotePagePainter *pagePainter = [painterFactory factoryPagePainter];
    [pagePainter setCurrentCell:model.currentInputCell];
    [pagePainter setUsingCellCache:YES];
    pagePainter.loadNotification = NoteInputPanelLoadCellNotification;
    writePageView.pagePainter = pagePainter;
    writePageView.page = model.inputPage;
    writePageView.delegate = self;
    writePageView.backgroundColor = [UIColor clearColor];
    writePageView.handleTouchEvent = YES;
}

-(void) setCurrentStroke:(PFNoteStroke *)stroke {
    [((PFNotePagePainter *)writePageView.pagePainter) setCurrentStroke:stroke];  
    [displayPanel setCurrentStroke:stroke];
}

-(void) setupOptionByStroke:(PFNoteStroke *)stroke {
    if (stroke) {
        colorIndex = [stroke getColorIndex];
        lineWidthIndex = [stroke getLineWidthIndex];
        if (optionMode) {
            [self _updateOptionViews];
        }
        if ((optionStatusView.colorIndex != colorIndex) ||
            (optionStatusView.lineWidthIndex != lineWidthIndex)) {
            optionStatusView.colorIndex = colorIndex;
            optionStatusView.lineWidthIndex = lineWidthIndex;
            [optionStatusView pushCurrentValues];
            [optionStatusView setNeedsDisplay];                    
        }
    }
}

-(void) resizeInputPanel:(CGSize)windowSize {
    DECLARE_PFNOTE_MODEL
    if (model.iPadMode && IPAD_SUPPORT_LANDSCAPE) {
        writePageView.frame = CGRectMake(writePageView.frame.origin.x,
                                         writePageView.frame.origin.y,
                                         windowSize.width - wrapWordLeftButton.frame.size.width
                                         - wrapWordRightButton.frame.size.width,
                                         writePageView.frame.size.height);
        toolbar.frame = CGRectMake(toolbar.frame.origin.x, 
                                   toolbar.frame.origin.y,
                                   windowSize.width,
                                   toolbar.frame.size.height);
        wrapWordRightButton.frame = CGRectMake(windowSize.width - wrapWordRightButton.frame.size.width,
                                               wrapWordRightButton.frame.origin.y,
                                               wrapWordRightButton.frame.size.width,
                                               wrapWordRightButton.frame.size.height);
        nextWordRightButton.frame = CGRectMake(windowSize.width - nextWordRightButton.frame.size.width,
                                               nextWordRightButton.frame.origin.y,
                                               nextWordRightButton.frame.size.width,
                                               nextWordRightButton.frame.size.height);
        CGRect numberFrame = CGRectMake(0.0f, 0.0f,
                                        windowSize.width,
                                        toolbar.frame.size.height);
        [pageNumberView updateWithFrame:numberFrame];
    }
}

-(void) resetInputPanel {
    if (!inputEnabled) {
        return;
    }
    DECLARE_PFNOTE_MODEL
    [self setCurrentStroke:nil];
    PFNoteCell *currentNoteCell = [model getCurrentCell];
    if (currentNoteCell) {
        model.currentInputCell.type = currentNoteCell.type;
        if (currentNoteCell.type == PFNOTE_CELL_TYPE_WORD) {
            [self _resetInputCell];
            
            [model.currentInputCell copyStrokesFrom:currentNoteCell];
            model.currentInputCell.width = currentNoteCell.width;
            [self _adjustInputCell];

            PFNoteStroke *stroke = [currentNoteCell getLastStroke];
            [self setupOptionByStroke:stroke];
        } else {
            [model.currentInputCell setRect:CGRectZero];
            [model.currentInputCell clearStrokes];
            [writePageView setNeedsDisplay];
            wrapWordLeftButton.hidden = YES;
            wrapWordRightButton.hidden = YES;
            //setup stroke option by last cell
            PFNoteParagraph *paragraph = [model.note getParagraph];
            for (int i = model.note.state.cell - 1; i >= 0; i--) {
                PFNoteCell *cell = [paragraph.cells objectAtIndex:i];
                if (cell.type == PFNOTE_CELL_TYPE_WORD) {
                    PFNoteStroke *stroke = [cell getLastStroke];
                    [self setupOptionByStroke:stroke];                    
                }
            }
        }
    }    
}

-(void) refreshInputPanel {
    [writePageView setNeedsDisplay];
}

-(IBAction) onQuickOption:(id)sender {
    if ([optionStatusView circleCurrentValues]) {
        [optionStatusView setNeedsDisplay];
    }
    colorIndex = optionStatusView.colorIndex;
    lineWidthIndex = optionStatusView.lineWidthIndex;
    if (optionMode) {
        [self _updateOptionViews];
    }
}

-(IBAction) onPages:(id)sender {
    DECLARE_PFNOTE_MODEL
    PFNOTE_CHECK_WRITING
    NoteAppDelegate *delegate = (NoteAppDelegate *)[UIApplication sharedApplication].delegate;
    [delegate onPages:sender];
}

-(IBAction) onHide:(id)sender {
    DECLARE_PFNOTE_MODEL
    PFNOTE_CHECK_WRITING
    NoteAppDelegate *delegate = (NoteAppDelegate *)[UIApplication sharedApplication].delegate;
    [delegate onToggleInput:nil];
}

-(IBAction) onOption:(id)sender {
    DECLARE_PFNOTE_MODEL
    PFNOTE_CHECK_WRITING
    if (optionMode) {
        writePageView.hidden = NO;
        nextWordLeftButton.hidden = NO;
        nextWordRightButton.hidden = NO;
        wrapWordLeftButton.hidden = NO;
        wrapWordRightButton.hidden = NO;
        optionViewController.view.hidden = YES;
        [self.view sendSubviewToBack:optionViewController.view];
        [optionStatusView pushCurrentValues];
        optionMode = NO;
        [self refreshInputPanel];
    } else {
        [self _updateOptionViews];
        writePageView.hidden = YES;
        nextWordLeftButton.hidden = YES;
        nextWordRightButton.hidden = YES;
        wrapWordLeftButton.hidden = YES;
        wrapWordRightButton.hidden = YES;
        optionViewController.view.hidden = NO;
        [self.view bringSubviewToFront:optionViewController.view];
        optionMode = YES;
    }
}

-(void) _updateOptionViews {
    DECLARE_PFNOTE_PAINTER_FACTORY
    DECLARE_PFNOTE_MODEL
    PFNoteTheme *theme = [painterFactory getTheme:model.config];
    for (int i = 0; i < PFNOTE_INPUT_COLOR_TAG_NUM; i++) {
        int tag = PFNOTE_INPUT_COLOR_TAG_START + i;
        UIView *colorButton = [optionViewController.view viewWithTag:tag];
        if (colorButton) {
            colorButton.backgroundColor = [theme getColor:i];
        }
    }
    [self _updateColorSelectedIcon];
    [self _updateWidthSelectedIcon];
}

-(void) _updateColorSelectedIcon {
    int tag = PFNOTE_INPUT_COLOR_TAG_START + colorIndex;
    UIView *colorButton = [optionViewController.view viewWithTag:tag];
    if (colorButton) {
        colorSelectedIcon.frame = CGRectMake(
            colorButton.frame.origin.x + colorButton.frame.size.width - colorSelectedIcon.frame.size.width,
            colorButton.frame.origin.y + colorButton.frame.size.height - colorSelectedIcon.frame.size.height,
            colorSelectedIcon.frame.size.width,
            colorSelectedIcon.frame.size.height);
        colorSelectedIcon.hidden = NO;
    } else {
        colorSelectedIcon.hidden = YES;
    }
}

-(void) _updateWidthSelectedIcon {
    int tag = PFNOTE_INPUT_WIDTH_TAG_START + lineWidthIndex;
    UIView *widthButton = [optionViewController.view viewWithTag:tag];
    if (widthButton) {
        widthSelectedIcon.frame = CGRectMake(
                                             widthButton.frame.origin.x + widthButton.frame.size.width - widthSelectedIcon.frame.size.width,
                                             widthButton.frame.origin.y + widthButton.frame.size.height - widthSelectedIcon.frame.size.height,
                                             widthSelectedIcon.frame.size.width,
                                             widthSelectedIcon.frame.size.height);
        widthSelectedIcon.hidden = NO;
    } else {
        widthSelectedIcon.hidden = YES;
    }
}

-(IBAction) onUndo:(id)sender {
    DECLARE_PFNOTE_MODEL
    PFNOTE_CHECK_WRITING
    
    if ([savedOperations count] > PFNOTE_INPUT_MAX_SAVED_OPERATIONS) {
        NSRange range;
        range.location = 0;
        range.length = PFNOTE_INPUT_REMOVE_OPERATION_LENGTH;
        [savedOperations removeObjectsInRange:range];
    }
    
    PFNoteCell *inputCell = model.currentInputCell;
    PFNoteCell *displayCell = [model getCurrentCell];
    if (inputCell && displayCell) {
        if ([inputCell isEmptyCell] && [displayCell isEmptyCell]) {
            [self onDelete:sender];
        } else {
            PFNoteStroke *inputStroke = [inputCell getLastStroke];
            PFNoteStroke *displayStroke = [displayCell getLastStroke];
            if (inputStroke && (inputStroke == displayStroke)) {
                [savedOperations addObject:inputStroke];
                [inputCell removeStroke:inputStroke];
                [displayCell removeStroke:displayStroke];
                [self setCurrentStroke:nil];
                [writePageView setNeedsDisplay];
                [displayPanel refreshCurrentCell];
            }
        }
    }
}

-(IBAction) onRedo:(id)sender {
    DECLARE_PFNOTE_MODEL
    PFNOTE_CHECK_WRITING
    BOOL resetPage = NO;
    BOOL refreshPage = NO;
    BOOL refreshCell = NO;
    NSObject *lastOperation = [savedOperations lastObject];
    if (lastOperation) {
        if ([[lastOperation class] isSubclassOfClass:[PFNoteCell class]]) {
            resetPage = [self normalizeCurrentInputCell];
            PFNoteCell *newCell = (PFNoteCell *)lastOperation;
            if (newCell.type == PFNOTE_CELL_TYPE_RETURN) {
                refreshPage = [model appendNewParagraphToCurrentPage];                
            } else {
                refreshPage = [model appendCellToCurrentPage:newCell];                
            }
            refreshCell = YES;
        } else if ([[lastOperation class] isSubclassOfClass:[PFNoteStroke class]]) {
            PFNoteStroke *stroke = (PFNoteStroke *)lastOperation;
            PFNoteCell *inputCell = model.currentInputCell;
            PFNoteCell *displayCell = [model getCurrentCell];
            if (inputCell && displayCell) {
                [inputCell addStroke:stroke];
                [displayCell addStroke:stroke];
            }
            refreshCell = YES;
        }
        [savedOperations removeLastObject];
    }
    if (resetPage) {
        [model resetPages];
        [displayPanel refreshDisplayPanel];
    } else if (refreshPage) {
        [displayPanel refreshDisplayPanel];
    } else if (refreshCell) {
        [displayPanel refreshCurrentCell];
    }
    if (resetPage || refreshPage || refreshCell) {
        [self resetInputPanel];
    }
}

-(IBAction) onDelete:(id)sender {
    DECLARE_PFNOTE_MODEL
    PFNOTE_CHECK_WRITING
    PFNoteCell *currentCell = [model getCurrentCell];
    [savedOperations addObject:currentCell];
    [model removeCurrentCell];

    [self resetInputPanel];
    [displayPanel refreshDisplayPanel];
    [displayPanel refreshCurrentCell];
}

-(IBAction) onReturn:(id)sender {
    DECLARE_PFNOTE_MODEL
    PFNOTE_CHECK_WRITING
    
    BOOL resetPage = [self normalizeCurrentInputCell];
    [model appendNewParagraphToCurrentPage];
    PFNoteParagraph *paragraph = [model.note getParagraph];
    if (paragraph && ([paragraph.cells count] == 1)) {
        [self appendEmptyWordCell];
    } else {
        if (resetPage) {
            [model resetPages];
        }        
    }
    [self resetInputPanel];
    [displayPanel refreshDisplayPanel];
}

-(IBAction) onSpace:(id)sender {
    DECLARE_PFNOTE_MODEL
    PFNOTE_CHECK_WRITING

    [self normalizeCurrentInputCell];
    PFNoteCell *newCell = [[[PFNoteCell alloc] initWithType:PFNOTE_CELL_TYPE_SPACE] autorelease];
    [model appendCellToCurrentPage:newCell];
    [self appendEmptyWordCell];
    [self resetInputPanel];
    [displayPanel refreshDisplayPanel];
}

#pragma mark -
#pragma mark PFPageViewDelegate
-(void) onResize: (PFPageView *)pageView
              to:(CGSize)viewSize {
    PFDebug(@"input onResize: to: %@", NSStringFromCGSize(viewSize));
    CGRect pageRect = CGRectMake(0, 0, viewSize.width, viewSize.height);
    [writePageView.page setRect:pageRect];
    [self _adjustInputCell];
    CGRect wrapFrame = wrapWordRightButton.frame;
    wrapWordRightButton.frame = CGRectMake(self.view.frame.size.width - wrapFrame.size.width,
                                      wrapFrame.origin.y,
                                      wrapFrame.size.width, wrapFrame.size.height);
}

-(void) onTouchDown: (PFPageView *)pageView
           withCell: (id<PFCell>)cell at:(CGPoint)point {
    PFDebug(@"input onTouchDown: withCell:%@ at:%@", cell, NSStringFromCGPoint(point));
    DECLARE_PFNOTE_MODEL
    if (model.currentInputCell.type != PFNOTE_CELL_TYPE_WORD) return;
    model.writing = YES;
    model.note.needSave = YES;
    PFNoteCell *noteCell = (PFNoteCell *)cell;
    PFNoteStroke *stroke = [[[PFNoteStroke alloc] init] autorelease];
    [stroke setColorIndex:colorIndex];
    [stroke setLineWidthIndex:lineWidthIndex];
    [stroke startStroke:point withPressure:PFNOTE_DEFAULT_PRESSURE];
    [noteCell addStroke:stroke];
    PFNoteCell *currentDisplayCell = [model getCurrentCell];
    [currentDisplayCell addStroke:stroke];
    [self setCurrentStroke:stroke];
    [self _adjustInputCell];
    lastDragPoint.x = NSNotFound;
}

-(void) onTouchDrag: (PFPageView *)pageView
           withCell:(id<PFCell>)cell at:(CGPoint)point {
    PFDebug(@"input onTouchDrag: withCell:%@ at:%@", cell, NSStringFromCGPoint(point));
    DECLARE_PFNOTE_MODEL
    if (model.currentInputCell.type != PFNOTE_CELL_TYPE_WORD) return;
    PFNoteCell *noteCell = (PFNoteCell *)cell;
    PFNoteStroke *stroke = [noteCell getLastStroke];
    if (stroke) {
        PFNotePoint *lastPoint = [stroke getLastPoint];
        float distantFromLastPoint = hypotf(point.x - stroke.offset.x - lastPoint.x, 
                                            point.y - stroke.offset.y - lastPoint.y);
        if (distantFromLastPoint > PFNOTE_INPUT_GATE) {
            [stroke addPoint:point withPressure:PFNOTE_DEFAULT_PRESSURE];
            [self _adjustInputCell];
            lastDragPoint.x = NSNotFound;
        } else {
            lastDragPoint.x = point.x;
            lastDragPoint.y = point.y;
        }
    }        
}

-(void) onTouchUp: (PFPageView *)pageView
         withCell:(id<PFCell>)cell at:(CGPoint)point {
    PFDebug(@"input onTouchUp: withCell:%@ at:%@", cell, NSStringFromCGPoint(point));
    DECLARE_PFNOTE_MODEL
    if (model.currentInputCell.type == PFNOTE_CELL_TYPE_WORD) {
        PFNoteCell *noteCell = (PFNoteCell *)cell;
        PFNoteStroke *stroke = [noteCell getLastStroke];
        if (stroke && (lastDragPoint.x != NSNotFound)) {
            [stroke addPoint:lastDragPoint withPressure:PFNOTE_DEFAULT_PRESSURE];
            [self _adjustInputCell];
            lastDragPoint.x = NSNotFound;
        } else {
            [writePageView setNeedsDisplay];
        }
    }
    [self onTouchUp:pageView withNothingAt:point];
}

-(void) onTouchUp: (PFPageView *)pageView withNothingAt:(CGPoint)point {
    DECLARE_PFNOTE_MODEL
    [self setCurrentStroke:nil];
    model.writing = NO;    
}

-(void) onTouchDown: (PFPageView *)pageView 
           withPage:(id<PFPage>)page at:(CGPoint)point {
    [self onNextWord:nil];
    id cell = [pageView getCellOrPage:point];
    if (cell && [[cell class] conformsToProtocol: @protocol(PFCell)]) {
        pageView.touchDownObject = cell;
        CGPoint position = [pageView getRelativePosition:point ofCell:cell];
        [self onTouchDown:pageView withCell:cell at:position];
    }
}

-(IBAction) onWrapWordLeft:(id)sender {
    DECLARE_PFNOTE_MODEL
    PFNOTE_CHECK_WRITING
    float factor = model.inputPageConfig.factor;
    float pageWidth = writePageView.frame.size.width;
    float wordMargin = model.iPadMode ? PFNOTE_INPUT_WORD_MARGIN_IPAD : PFNOTE_INPUT_WORD_MARGIN_IPHONE;
    float addCellWidth = (pageWidth - wordMargin * 2.0f) / factor;

    CGRect cellRect = [model.currentInputCell getRect];
    float cellX = cellRect.origin.x + addCellWidth * factor;
    if (cellX > 0.0f) {
        cellX = 0.0f;
    }
    CGRect newInputCellRect = CGRectMake(cellX,
                                         cellRect.origin.y,
                                         cellRect.size.width,
                                         cellRect.size.height);
    [model.currentInputCell setRect:newInputCellRect];
    [self setCurrentStroke:nil];
    [self _adjustInputCell];
}

-(IBAction) onWrapWordRight:(id)sender {
    DECLARE_PFNOTE_MODEL
    PFNOTE_CHECK_WRITING
    CGPoint leftRight = [self _getCellLeftRight:model.currentInputCell];
    
    float factor = model.inputPageConfig.factor;
    float pageWidth = writePageView.frame.size.width;
    float wordMargin = model.iPadMode ? PFNOTE_INPUT_WORD_MARGIN_IPAD : PFNOTE_INPUT_WORD_MARGIN_IPHONE;
    float addCellWidth = (pageWidth - wordMargin * 2.0f) / factor;
    if (model.currentInputCell.width < (leftRight.y + addCellWidth)) {
        model.currentInputCell.width += addCellWidth;
        if (model.currentInputCell.width > PFNOTE_INPUT_WORD_MAX_WIDTH) {
            model.currentInputCell.width = PFNOTE_INPUT_WORD_MAX_WIDTH;
        }
    }
    CGRect cellRect = [model.currentInputCell getRect];
    float cellX = cellRect.origin.x - addCellWidth * factor;
    if (cellX > 0.0f) {
        cellX = 0.0f;
    }
    float cellWidth = model.currentInputCell.width * factor;
    if ((cellX + cellWidth) < pageWidth) {
        cellX = pageWidth - cellWidth;
    }
    CGRect newInputCellRect = CGRectMake(cellX,
                                         cellRect.origin.y,
                                         cellWidth,
                                         cellRect.size.height);
    [model.currentInputCell setRect:newInputCellRect];
    [self setCurrentStroke:nil];
    [self _adjustInputCell];
}

-(BOOL) normalizeCurrentInputCell {
    if (!inputEnabled) {
        return NO;
    }
    
    DECLARE_PFNOTE_MODEL
    if (model.currentInputCell.type != PFNOTE_CELL_TYPE_WORD) {
        return NO;
    }
    
    if ([model.currentInputCell isEmptyCell]) {
        PFNoteCell *currentCell = [model.note getCell];
        if (currentCell && [currentCell isEmptyCell]) {
            [model.note removeCell];
            return YES;
        }
    }

    float delta = [self _normalizeWordStrokesOfCell:model.currentInputCell withOffset:0.0f];
    [self _adjustDisplayCell];
    return (fabsf(delta)> PFNOTE_POINT_CHANGE_THRESHOLD);
}

-(void) appendEmptyWordCell {
    DECLARE_PFNOTE_MODEL
    PFNoteCell *cell = [[[PFNoteCell alloc] initWithType:PFNOTE_CELL_TYPE_WORD] autorelease];
    cell.width =  (self.view.frame.size.width
                   - wrapWordLeftButton.frame.size.width
                   - wrapWordRightButton.frame.size.width) / writePageView.frame.size.height;
    [model appendCellToCurrentPage:cell];
}

-(IBAction) onNextWord:(id)sender {
    DECLARE_PFNOTE_MODEL
    PFNOTE_CHECK_WRITING
    if ([model.currentInputCell isEmptyCell]) {
        [self onSpace:sender];
        return;
    }
    [self normalizeCurrentInputCell];
    [self appendEmptyWordCell];
    [self resetInputPanel];
    [displayPanel refreshDisplayPanel];
}

-(CGPoint)_getCellLeftRight:(PFNoteCell *)cell {
    BOOL hasPoint = NO;
    float left = 0.0f, right = 0.0f;
    for (PFNoteStroke *stroke in cell.strokes) {
        float lineWidth = [stroke getLineWidth];
        PFNotePoint *offset = stroke.offset;
        if (!hasPoint) {
            hasPoint = YES;
            left = offset.x - lineWidth;
            right = offset.x + lineWidth;
        } else {
            if (left > offset.x - lineWidth) left = offset.x - lineWidth;
            if (right < offset.x + lineWidth) right = offset.x + lineWidth;
        }
        for (PFNotePoint *point in stroke.points) {
            if (left > offset.x + point.x - lineWidth) left = offset.x + point.x - lineWidth;
            if (right < offset.x + point.x + lineWidth) right = offset.x + point.x + lineWidth;            
        }
    }
    return CGPointMake(left, right);
}

-(float) _normalizeWordStrokesOfCell:(PFNoteCell *)cell withOffset:(float)offset {
    if (!cell || [cell.strokes count] == 0) {
        return 0.0f;
    }
    CGPoint leftRight = [self _getCellLeftRight:cell];
    float left = leftRight.x, right = leftRight.y;
    float delta = left - offset;
    float oldWidth = cell.width;
    cell.width = right - delta + 2.0f / PFNOTE_POINT_BASE_FACTOR;
    float widthDelta = cell.width - oldWidth;
    if (fabsf(delta)> PFNOTE_POINT_CHANGE_THRESHOLD) {
        for (PFNoteStroke *stroke in cell.strokes) {
            CGPoint newOffsetPoint = CGPointMake(stroke.offset.x - delta,
                                                 stroke.offset.y);
            [stroke.offset setPoint:newOffsetPoint];
        }
        return delta;
    } else if (fabsf(widthDelta)> PFNOTE_POINT_CHANGE_THRESHOLD) {
        return widthDelta;
    }

    return 0.0f;
}

-(void) _adjustInputCellByStrokes {
    DECLARE_PFNOTE_MODEL
    PFNoteCell *cell = model.currentInputCell;
    if ([cell.strokes count] == 0) {
        return;
    }
    CGPoint leftRight = [self _getCellLeftRight:cell];
    if (cell.width < leftRight.y) {
        cell.width = leftRight.y;
    }

    [writePageView setNeedsDisplay];

    float cellX = [cell getRect].origin.x;
    float factor = model.inputPageConfig.factor;
    float wordMargin = model.iPadMode ? PFNOTE_INPUT_WORD_MARGIN_IPAD : PFNOTE_INPUT_WORD_MARGIN_IPHONE;

    if ((cell.width < PFNOTE_INPUT_WORD_MAX_WIDTH)
        && ((leftRight.y * factor
             + cellX + wordMargin * 2.0f)
            > writePageView.frame.size.width)) {
        wrapWordRightButton.hidden = NO;
    } else if ((cellX + cell.width * factor) > writePageView.frame.size.width) {
        wrapWordRightButton.hidden = NO;
    } else {
        wrapWordRightButton.hidden = YES;
    }
    if (cellX < 0.0f) {
        wrapWordLeftButton.hidden = NO;
    } else {
        wrapWordLeftButton.hidden = YES;
    }
}

-(void) _adjustInputCell {
    [self _adjustInputCellByStrokes];
    BOOL resetPage = [self _adjustDisplayCell];
    if (resetPage) {
        DECLARE_PFNOTE_MODEL
        [model resetPages];
        [displayPanel refreshDisplayPanel];
    } else {
        [displayPanel refreshCurrentCell];        
    }
}
 
-(BOOL) _adjustDisplayCell {
    DECLARE_PFNOTE_MODEL
    PFNoteCell *currentDisplayCell = [model getCurrentCell];
    if (currentDisplayCell) {
        float oldWidth = currentDisplayCell.width;
        currentDisplayCell.width = model.currentInputCell.width;
        if (fabsf(oldWidth - currentDisplayCell.width) > PFNOTE_POINT_CHANGE_THRESHOLD) {
            [displayPanel clearCellCache:currentDisplayCell];
            model.note.needSave = YES;
            return YES;
        }
    }
    return NO;
}

-(void) _resetInputCell {
    DECLARE_PFNOTE_MODEL
    CGRect cellRect = CGRectMake(0.0f, 0.0f, 
                                 writePageView.frame.size.width,
                                 writePageView.frame.size.height);
    model.currentInputCell.width = writePageView.frame.size.width / writePageView.frame.size.height;
    [model.currentInputCell setRect:cellRect];
    [writePageView setNeedsDisplay];        
    wrapWordLeftButton.hidden = YES;
    wrapWordRightButton.hidden = YES;
}

#pragma mark -
#pragma mark Option related
                  
-(void) setupOptionView {
    optionMode = NO;
    optionViewController.view.frame = CGRectMake(
        nextWordLeftButton.frame.origin.x,
        nextWordLeftButton.frame.origin.y,
        nextWordRightButton.frame.origin.x + nextWordRightButton.frame.size.width,
                                                 writePageView.frame.size.height);
    optionViewController.view.hidden = YES;
    [self.view addSubview:optionViewController.view];
    [self.view sendSubviewToBack:optionViewController.view];

    colorSelectedIcon = [optionViewController.view viewWithTag:PFNOTE_INPUT_COLOR_TAG_SELECET];
    widthSelectedIcon = [optionViewController.view viewWithTag:PFNOTE_INPUT_WIDTH_TAG_SELECET];

    for (int i = 0; i < PFNOTE_INPUT_COLOR_TAG_NUM; i++) {
        int tag = PFNOTE_INPUT_COLOR_TAG_START + i;
        UIButton *colorButton = (UIButton *)[optionViewController.view viewWithTag:tag];
        if (colorButton) {
            [colorButton addTarget:self action:@selector(onColorSelected:event:)
                forControlEvents:(UIControlEvents)UIControlEventTouchUpInside];
        }
    }    
    
    for (int i = 0; i < PFNOTE_INPUT_WIDTH_TAG_NUM; i++) {
        int tag = PFNOTE_INPUT_WIDTH_TAG_START + i;
        UIButton *widthButton = (UIButton *)[optionViewController.view viewWithTag:tag];
        if (widthButton) {
            [widthButton addTarget:self action:@selector(onWidthSelected:event:)
                  forControlEvents:(UIControlEvents)UIControlEventTouchUpInside];
        }
    }    
    
    [optionViewController.view viewWithTag:99].backgroundColor = [UIColor clearColor];
    [optionViewController.view viewWithTag:199].backgroundColor = [UIColor clearColor];
}

-(IBAction) onColorSelected:(id)sender event:(UIEvent*)event {
    UIButton *colorButton = (UIButton *)sender;
    int newColorIndex = colorButton.tag - PFNOTE_INPUT_COLOR_TAG_START;
    if (newColorIndex == colorIndex) {
        [self onOption:sender];
    } else {
        colorIndex = newColorIndex;
        [self _updateColorSelectedIcon];
        optionStatusView.colorIndex = newColorIndex;
        [optionStatusView setNeedsDisplay];
    }
}

-(IBAction) onWidthSelected:(id)sender event:(UIEvent*)event {
    UIButton *widthButton = (UIButton *)sender;
    int newLineWidthIndex = widthButton.tag - PFNOTE_INPUT_WIDTH_TAG_START;
    if (newLineWidthIndex == lineWidthIndex) {
        [self onOption:sender];
    } else {
        lineWidthIndex = newLineWidthIndex;
        [self _updateWidthSelectedIcon];
        optionStatusView.lineWidthIndex = newLineWidthIndex;
        [optionStatusView setNeedsDisplay];
    }
}

-(void) refreshConfig {
    DECLARE_PFNOTE_MODEL
    NSString *strokeType = [model.config getStrokeType];
    [optionStatusView.config setStrokeType:strokeType];

    [writePageView.pagePainter refreshConfig];
    [optionStatusView refreshConfig];
}

-(void) updateWithTheme:(PFNoteTheme *)theme {
    DECLARE_PFNOTE_MODEL
    PFNoteThemeImage inputImage = [model iPadLandScape] ? PFNoteThemeImageInputIPadLandscape
                                                        : PFNoteThemeImageInput;
    self.view.backgroundColor = [theme getImageAsColor:inputImage
                                          defaultColor:theme.backgroundColor];
    [theme updateButtonImage:PFNoteThemeImageInputHide button:hideButton];
    [theme updateButtonImage:PFNoteThemeImageInputOption button:optionButton];
    [theme updateButtonImage:PFNoteThemeImageInputUndo button:undoButton];
    [theme updateButtonImage:PFNoteThemeImageInputRedo button:redoButton];
    [theme updateButtonImage:PFNoteThemeImageInputDelete button:deleteButton];
    [theme updateButtonImage:PFNoteThemeImageInputReturn button:returnButton];

    [theme updateButtonImage:PFNoteThemeImageInputNextWordLeft button:nextWordLeftButton];
    [theme updateButtonImage:PFNoteThemeImageInputNextWordRight button:nextWordRightButton];
    [theme updateButtonImage:PFNoteThemeImageInputWrapWordLeft button:wrapWordLeftButton];
    [theme updateButtonImage:PFNoteThemeImageInputWrapWordRight button:wrapWordRightButton];
    [toolbar setNeedsLayout];
    [toolbar setNeedsDisplay];
    
    ((UILabel *)[self.view viewWithTag:198]).textColor = [theme getTextColor];
    ((UILabel *)[self.view viewWithTag:298]).textColor = [theme getTextColor];
    
    [self refreshConfig];
    
    optionStatusView.theme = theme;
    [optionStatusView setNeedsDisplay];
    
    pageNumberView.theme = theme;
    [pageNumberView setNeedsDisplay];
}

-(void) onPageUpdate:(int)currentPageIndex pageNum:(int)pageNum {
    pageNumberView.currentPageNumber = currentPageIndex;
    pageNumberView.totalPageNumber = pageNum;
    [pageNumberView setNeedsDisplay];
}
@end

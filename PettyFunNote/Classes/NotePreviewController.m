//
//  NotePreviewController.m
//  PettyFunNote
//
//  Created by YJ Park on 1/20/11.
//  Copyright 2011 PettyFun.com. All rights reserved.
//

#import "NotePreviewController.h"
#import "PFNoteModel.h"
#import "PFNotePainterFactory.h"

@implementation NotePreviewController
-(void) dealloc {
    [allPages release];
    [chapter release];
    [super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self _setupPreviewPageView];
    
    self.navigationItem.rightBarButtonItem = \
    [[[UIBarButtonItem alloc] initWithTitle:
      PF_L10N(@"buy") style:UIBarButtonItemStyleBordered target:self action:@selector(onBuy)] autorelease];
}

- (void)releaseViewElements {
    [super releaseViewElements];
    PF_Release_IBOutlet(previewPageView)
    self.navigationItem.rightBarButtonItem = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.title = [productInfo valueForKey:NOTE_PRODUCT_TITLE];
    DECLARE_PFNOTE_MODEL
    chapter = [[model.note getChapter] copyWithZone:nil];
    [self _updatePreviewPage]; 
}

-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.navigationItem.rightBarButtonItem.enabled = YES;
    DECLARE_PFUTILS
    [utils hideProgressHUD];
}

-(void) _setupPreviewPageView {
    previewPageView.pageConfig = [[PFNoteConfig alloc] init];
    DECLARE_PFNOTE_PAINTER_FACTORY
    previewPageView.pagePainter = [painterFactory factoryPagePainter];
    previewPageView.page = nil;
    previewPageView.delegate = self;    
    previewPageView.backgroundColor = [UIColor clearColor];
    previewPageView.handlePinch = YES; 
    [previewPageView initGestures];
}

-(void) _updatePreviewPage {
    DECLARE_PFNOTE_MODEL
    [previewPageView.pageConfig updateTo:model.config];
    previewPageView.pageConfig.showingControlCharactors = NO;
    
    if ([productInfo valueForKey:NOTE_PRODUCT_TYPE] == PFNoteProductTypeTheme) {
        NSString *themeType = [productInfo valueForKey:NOTE_PRODUCT_NAME];
        PFNoteConfig *noteConfig = (PFNoteConfig *)previewPageView.pageConfig;
        noteConfig.themeType = themeType;
        DECLARE_PFNOTE_PAINTER_FACTORY
        PFNoteTheme *theme = [painterFactory getThemeByType:themeType];
        DECLARE_PFNOTE_MODEL
        self.view.backgroundColor = [theme getPaperColor:[model iPadLandScape]];
    }
    
    [previewPageView.pagePainter refreshConfig];

    [self _onRepaintPreviewPage];
}

-(void) _onRepaintPreviewPage {
    DECLARE_PFNOTE_MODEL
    CGSize viewSize = previewPageView.frame.size;
    if (allPages) {
        [allPages release];
    }
    allPages = [[model.pager getPages:chapter withConfig:previewPageView.pageConfig forSize:viewSize] retain];
    previewPageView.page = [allPages objectAtIndex:0];
    [previewPageView setNeedsDisplay];
    DECLARE_PFUTILS
    [utils hideProgressHUD];
}

-(void) onPinch:(PFPageView *)pageView
         sender:(UIPinchGestureRecognizer *)sender {
    if (UIGestureRecognizerStateBegan == [sender state]) {
    } else if (UIGestureRecognizerStateChanged == [sender state]) {
    } else if (UIGestureRecognizerStateEnded == [sender state]) {
        previewPageView.pageConfig.factor = [PFNotePoint getFactor:previewPageView.pageConfig.factor scale:sender.scale];
    } else if (UIGestureRecognizerStateCancelled == [sender state]) {
    } else if (sender == nil) {
        [self _onRepaintPreviewPage];
    }
}

-(void) onProductPurchased:(NSNotification *)notification {
    self.navigationItem.rightBarButtonItem.enabled = NO;
}

@end

//
//  PFNoteModel.h
//  PettyFunNote
//
//  Created by YJ Park on 11/9/10.
//  Copyright 2010 PettyFun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>
#import "PFNote.h"
#import "PFNotePager.h"
#import "PFPageView.h"
#import "PFNotePainterFactory.h"
#import "UIColor-Expanded.h"

//DEBUG purpose
#define PFNOTE_ENABLE_DEBUG_UI NO
#define PFNOTE_DISABLE_WATERMARK NO

//related to large file warning
#define PFNOTE_LARGE_FILE_WARNING_WORDNUM 1500

//default folders
#define NOTE_FOLDER_INBOX @"inbox"
#define NOTE_FOLDER_ARCHIVE @"archive"

//
#define NOTE_DEFAULT_AUTHOR @"com.pettyfun.bucket.note.author"
#define NOTE_DEFAULT_LAST_NOTE_PATH @"com.pettyfun.bucket.note.last_note_path"
#define NOTE_DEFAULT_CONFIG @"com.pettyfun.bucket.note.config"

#define NOTE_PRODUCT_FORMAT @"com.pettyfun.movablewrite.%@.%@"

#define NOTE_PRODUCT_NONE @""
//products
#define NOTE_PRODUCT_ADFREE @"adfree"

#define NOTE_PRODUCT_KEY @"key"
#define NOTE_PRODUCT_TYPE @"type"
#define NOTE_PRODUCT_NAME @"name"
#define NOTE_PRODUCT_TITLE @"title"
#define NOTE_PRODUCT_DESCRIPTION @"description"
#define NOTE_PRODUCT_ICON @"icon"
#define NOTE_PRODUCT_PRICE @"price"
#define NOTE_PRODUCT_SKPRODUCT @"skproduct"

extern NSString *const PFNoteProductTypeGeneral;
extern NSString *const PFNoteProductTypeTheme;
extern NSString *const PFNoteProductTypeStroke;

//redeem
#define NOTE_REDEEM_URL_PATTERN @"https://pettyfungiftcodes.appspot.com/redeem?device_id=%@&code=%@"

#define _PF_L10N(l10nKey) [l10n localizedStringForKey:l10nKey value:l10nKey table:nil]
#define _PF_L10N_(l10nKey, l10nValue) [l10n localizedStringForKey:l10nKey value:l10nValue table:nil]

#define PF_L10N(l10nKey) [[PFNoteModel getInstance].l10n localizedStringForKey:l10nKey value:l10nKey table:nil]

#define PF_L10N_(l10nKey, l10nValue) [[PFNoteModel getInstance].l10n localizedStringForKey:l10nKey value:l10nValue table:nil]

#define PF_L10N_VIEW(tagValue, l10nKey) \
[[PFUtils getInstance] l10nView:self.view \
                   bundle:[PFNoteModel getInstance].l10n \
                      tag:tagValue \
                      key:l10nKey]

#define PFNOTE_MODAL_BACKGROUDCOLOR [UIColor blackColor]

#define PFNOTE_POPUP_BACKGROUDCOLOR \
 [PFNoteModel getInstance].iPadMode ? [[UIColor grayColor] colorWithAlphaComponent:0.04f] : [UIColor colorWithHexString:@"161E30"]

#define PFNOTE_POPUP_TEXTCOLOR [UIColor whiteColor]
#define PFNOTE_POPUP_TABLE_SEPARATOR_COLOR [UIColor clearColor]

#define PF_SET_VIEW_BACKGROUNDCOLOR(tagValue, colorValue) \
[self.view viewWithTag:tagValue].backgroundColor = colorValue;

#define PF_SET_LABEL_TEXTCOLOR(tagValue, colorValue) \
    if ([self.view viewWithTag:tagValue]) \
        ((UILabel *)[self.view viewWithTag:tagValue]).textColor = colorValue;

#define PF_SET_TEXTVIEW_TEXTCOLOR(tagValue, colorValue) \
((UITextView *)[self.view viewWithTag:tagValue]).textColor = colorValue;

#define PF_SET_VIEW_BACKGROUNDCOLOR(tagValue, colorValue) \
[self.view viewWithTag:tagValue].backgroundColor = colorValue;

#define DECLARE_PFNOTE_MODEL PFNoteModel *model = [PFNoteModel getInstance];

#define PFNOTE_CHECK_WRITING if (model.writing) return;

#define PFNOTE_DEFAULT_PRESSURE 1.0f

#define PEN_CELL_OFFSET_X 0.25f
#define PEN_CELL_OFFSET_Y 0.25f

#define FACTOR_STEP 8.0f;

#define INDEX_FILE @"PettyFunNote.index"

#define PAGE_CACHE_PREFIX @"page_"

#define IPAD_SUPPORT_LANDSCAPE YES

@protocol PFNoteModelDelegate
@required
-(void) onPageUpdate:(int)currentPageIndex pageNum:(int)pageNum;
-(void) onConfigUpdate;
@end

@interface PFNoteModel : NSObject {
    id<PFNoteModelDelegate> delegate;
    
    //l10n
    NSBundle *l10n;

    //Index
    NSMutableDictionary *noteIndex;
    
    //Note stuffs
    PFNoteConfig *defaultConfig;
    PFNote *note;
    PFNoteConfig *config;
    //PFNoteState *state;
    PFNotePager *pager;
    
    //current
    NSMutableArray *allPages;
    int currentPageIndex;
    PFPage *currentPage;
    
    //Input stuffs
    BOOL writing;
    float inputCellHeight;
    PFPage *inputPage;
    PFNoteCell *currentInputCell; //weak reference
    PFNoteConfig *inputPageConfig;
    
    //Store stuffs
    NSMutableArray *productList;
    NSMutableDictionary *products;
    
    //Universal stuffs
    BOOL iPadMode;
}
@property (assign) id<PFNoteModelDelegate> delegate;
@property (readonly) NSBundle *l10n;

@property (readonly) NSDictionary *noteIndex;
@property (readonly) PFNote *note;
@property (readonly) PFNoteConfig *defaultConfig;
@property (readonly) PFNoteConfig *config;
@property (readonly) PFNotePager *pager;

@property (readonly) NSMutableArray *allPages;
@property (readonly) PFPage *currentPage;

@property BOOL writing;
@property (readonly) PFPage *inputPage;
@property (readonly) PFNoteConfig *inputPageConfig;
@property (readonly) PFNoteCell *currentInputCell;

@property (readonly) BOOL iPadMode;

+(PFNoteModel *) getInstance;

-(BOOL) appendCellToCurrentPage:(PFNoteCell *)cell;
-(BOOL) appendNewParagraphToCurrentPage;
-(void) resizeCurrentPageTo:(CGSize) viewSize;
-(void) resetPages;
-(PFNoteCell *) removeCurrentCell;
-(void) refreshCurrentPage;
-(id<PFCell>) getCurrentCell;

-(int) getPageNum;
-(int) getCurrentPageIndex;
-(id<PFPage>) getPage:(int)index;
-(BOOL) setCurrentPageIndex:(int)index;

-(BOOL) pageUp;
-(BOOL) pageDown;

-(void) scale:(CGFloat)scale;

-(void) saveConfigAsDefault;
-(BOOL) saveNote;
-(void) newNote;
-(BOOL) loadNote:(NSString *)path;

-(void) rebuildNoteIndex;
-(void) updateNoteIndex:(PFNote *)oneNote save:(BOOL)save;
-(void) refreshNoteIndexForFolders;

-(void) clearCache;
-(void) clearCellCache;
-(void) clearPageCache;
//store relate
-(void) clearAllPurchasedProducts; //for debug only
-(NSString *)getProductKey:(NSString *)productID withType:(NSString *)productType;
-(BOOL) hadPurchased:(NSString *)productKey;
-(void) purchase:(NSString *)productKey;
-(void) unlock:(NSString *)productKey;
-(BOOL) hadPurchased:(NSString *)productID withType:(NSString *)productType;
-(NSArray *) getAvailableProductKeys;
-(NSDictionary *) getProductInfo:(NSString *)productKey;
-(void) onInvalidProductIdentifier:(NSString *)productKey;
-(void) onSKProduct:(SKProduct *)product;
-(NSArray *) getUnpurchasedProductsInConfig:(PFNoteConfig *)checkedConfig;
-(NSString *) getProductTitles:(NSArray *)productInfos;
-(void) logProductEvent:(NSString *)event productInfo:(NSDictionary *)productInfo;
-(void) logProductEvent:(NSString *)event productKey:(NSString *)productKey;


-(void) refreshConfig;

//Internal methods
- (void) _initNoteStuff;
- (void) _initCurrentStuff;
-(void) _updateCurrentPage:(PFPage *)page;

- (void) _initInputStuff;

- (void) _initProducts;
- (void) _addProduct:(NSString *)name 
                type:(NSString *)type;
- (NSString *) _getIcon:(NSString *)name 
                   type:(NSString *)type;

//Universal stuffs
-(BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation;
-(BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
                              supportLandscape:(BOOL)supportLandscape;
-(CGSize) getWindowSize;
-(BOOL) iPadLandScape;


@end

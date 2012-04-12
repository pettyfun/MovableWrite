//
//  PFNoteModel.m
//  PettyFunNote
//
//  Created by YJ Park on 11/9/10.
//  Copyright 2010 PettyFun. All rights reserved.
//

#import "FlurryAPI.h"

#import "PFNoteModel.h"
#import "PFUtils.h"
#import "PFNoteTheme.h"

NSString *const PFNoteProductTypeGeneral = @"general";
NSString *const PFNoteProductTypeTheme = @"theme";
NSString *const PFNoteProductTypeStroke = @"stroke";

static PFNoteModel *_modelInstance = nil;

@implementation PFNoteModel
@synthesize delegate;
@synthesize l10n;
@synthesize noteIndex;
@synthesize note;
@synthesize defaultConfig;
@synthesize config;
@synthesize pager;
@synthesize allPages;
@synthesize currentPage;
@synthesize inputPage;
@synthesize inputPageConfig;
@synthesize currentInputCell;
@synthesize writing;
@synthesize iPadMode;

+ (PFNoteModel *) getInstance {
	@synchronized(self) {
		if (_modelInstance == nil) {
			_modelInstance = [[PFNoteModel alloc] init];
		}
	}
	return _modelInstance;
}

- (id) init {
	if ((self = [super init])) {
        iPadMode = NO;
        if ([[UIDevice currentDevice].model hasPrefix:@"iPad"]) {
            iPadMode = YES;
        }
        
        NSString* path = [[[NSBundle mainBundle] resourcePath]
                          stringByAppendingPathComponent:@"PettyFunNoteL10n.bundle"];
        l10n = [NSBundle bundleWithPath:path];
        DECLARE_PFUTILS
        NSMutableDictionary *savedIndex = nil;
        @try {
            savedIndex = [NSMutableDictionary dictionaryWithContentsOfFile:[utils getPathInLibrary:INDEX_FILE]];
        }
        @catch (NSException * e) {
            savedIndex = nil;
        }        
        
        if (savedIndex) {
            noteIndex = [savedIndex retain];
        } else {
            noteIndex = [[NSMutableDictionary alloc] init];
            [self rebuildNoteIndex];
        }
        pager = [[PFNotePager alloc] init];
        allPages = nil;
        [self _initNoteStuff];
        [self _initCurrentStuff];
        [self _initInputStuff];
        [self _initProducts];
        [utils createPathesInDocument:[NSArray arrayWithObjects:
               PFITEM_DATA_FOLDER, PFITEM_BACKUP_FOLDER, PFITEM_CACHE_FOLDER,
               PFNOTE_PDF_FOLDER, nil]];         
	}
	return self;
}

-(void) rebuildNoteIndex {
    //TODO
    [noteIndex removeAllObjects];
    
    [self updateNoteIndex:nil save:YES];
}

-(void) updateNoteIndex:(PFNote *)oneNote save:(BOOL)save{
    DECLARE_PFUTILS
    if (oneNote) {
        [noteIndex setValue:oneNote.name forKey:oneNote.path];
    }
    if (save) {
        [noteIndex writeToFile:[utils getPathInLibrary:INDEX_FILE] atomically:YES];
    }
}

-(void) refreshNoteIndexForFolders {
    DECLARE_PFUTILS
    NSString *folder = [utils getPathInDocument:PFITEM_DATA_FOLDER];
    [noteIndex setValue:_PF_L10N(@"folder_home") forKey:folder];
    [noteIndex setValue:_PF_L10N(@"folder_inbox") forKey:[folder stringByAppendingPathComponent:NOTE_FOLDER_INBOX]];
    [noteIndex setValue:_PF_L10N(@"folder_archive") forKey:[folder stringByAppendingPathComponent:NOTE_FOLDER_ARCHIVE]];
}

- (void) dealloc {
    [pager release];
    [note release];
    [defaultConfig release];
    [config release];
    [allPages release];
    [currentPage release];
    [inputPage release];
    [inputPageConfig release];
	[super dealloc];
}

- (void) _initNoteStuff {
    DECLARE_PFUTILS
    NSDictionary *defaultConfigData = [utils getDefault:NOTE_DEFAULT_CONFIG];
    if (defaultConfigData) {
        defaultConfig = [[PFNoteConfig alloc] initWithPFData:defaultConfigData];
    } else {
        defaultConfig = [[PFNoteConfig alloc] init];
        [defaultConfig setGridType:PFNOTE_LINE_GRID_PAINTER];
    }
    
    note = [[PFNote alloc] init];
    [note.config updateTo:defaultConfig];
    
    config = [[PFNoteConfig alloc] init];
    [config updateTo:note.config];
}

- (void) _initCurrentStuff {
    CGSize size = self.iPadMode ? CGSizeMake(768, 960) : CGSizeMake(480, 276);
    currentPage = [[pager getEmptyPageWithConfig:config forSize:size] retain];
}

- (void) _initInputStuff {
    inputCellHeight = iPadMode ? 256 : 156;
    
    inputPage = [[PFPage alloc] init];
    PFNoteParagraph *paragraph = [[[PFNoteParagraph alloc] init] autorelease];
    PFNoteCell *cell = [[[PFNoteCell alloc] initWithType:PFNOTE_CELL_TYPE_WORD] autorelease];
    CGRect cellRect = CGRectMake(0, 0, 0, inputCellHeight);
    [cell setRect:cellRect];
    [paragraph appendCell:cell];
    NSArray *inputParagraphes = [NSArray arrayWithObject:paragraph];
    [inputPage setParagraphes:inputParagraphes];
    
    currentInputCell = cell;
    
    inputPageConfig = [[PFNoteConfig alloc] init];
    inputPageConfig.factor = inputCellHeight;
    inputPageConfig.marginLeft = 0.0f;
    inputPageConfig.marginRight = 0.0f;
    inputPageConfig.marginTop = 0.0f;
    inputPageConfig.marginBottom = 0.0f;
    inputPageConfig.marginParagraph = 0.0f;
    inputPageConfig.marginLine = 0.0f;
    inputPageConfig.marginWord = 0.0f;    
    inputPageConfig.paragraphIndent = 0.0f;
    [inputPageConfig setGridType:PFNOTE_BOX_GRID_PAINTER];
}

-(void) _updateCurrentPage:(PFPage *)page {
    if (![allPages containsObject:page]) {
        if (currentPageIndex == NSNotFound) {
            currentPageIndex = [allPages count] - 1;
        }
        [allPages insertObject:page atIndex:currentPageIndex + 1];
    }
    currentPageIndex = [allPages indexOfObject:page];
    [currentPage setViewSize:[page getViewSize]];
    [currentPage setRect:[page getRect]];
    [currentPage setParagraphes:[page getParagraphes]];
    PFNoteCell *currentCell = [note getCell];
    if ((!currentCell) || (![currentPage containsCell:currentCell])) {
        if (currentPageIndex == [allPages count] - 1) {
            currentCell = [currentPage getLastCell];
        } else {
            currentCell = [currentPage getFirstCell];
        }
        [note seekCell:currentCell];
    }    
    if (delegate) {
        [delegate onPageUpdate:currentPageIndex pageNum:[allPages count]];
    }
}

-(id<PFCell>) getCurrentCell {
    return [note getCell];
}

#pragma mark -
#pragma mark Specific mothods

-(void) resetPages {
    [self resizeCurrentPageTo:[currentPage getViewSize]];    
}

-(void) resizeCurrentPageTo:(CGSize) viewSize {
    PFNoteChapter *chapter = [note getChapter];
    if (allPages) {
        [allPages release];
    }
    [self clearPageCache];
    allPages = [[pager getPages:chapter withConfig:config forSize:viewSize] retain];
    [self refreshCurrentPage];
}

-(void) refreshCurrentPage {
    PFPage *newCurrentPage = nil;
    PFNoteCell *currentCell = [note getCell];
    if (currentCell) {
        for (PFPage *page in allPages) {
            if ([page containsCell:currentCell]) {
                newCurrentPage = page;
                break;
            }
        }
    } else {
        if ([allPages count] > 0) {
            newCurrentPage = [allPages objectAtIndex:0];
        }
    }

    if (newCurrentPage) {
        //little hacky here, since want to keep currentPage consistent
        [self _updateCurrentPage:newCurrentPage];
    }
}

-(BOOL) appendNewParagraphToCurrentPage {
    BOOL refreshPage = YES;

    PFNoteCell *currentCell = [note getCell];
    if ([currentCell isEmptyCell]) {
        [note removeCell];
    }
    
    [note createNewParagraph];
    [self resetPages];

    return refreshPage;
}

-(BOOL) appendCellToCurrentPage:(PFNoteCell *)cell {
    BOOL refreshPage = NO;
    PFNoteCell *currentCell = [note getCell];
    if ([currentCell isEmptyCell]) {
        [note removeCell];
        refreshPage = YES;
    }
    if (cell) {
        [note insertCell:cell];
        [self resetPages];
        refreshPage = YES;
    }
    return refreshPage;
}

-(PFNoteCell *) removeCurrentCell {
    PFNoteCell *removedCell = [note removeCell];
    [self resetPages];
    return removedCell;
}

-(void) saveConfigAsDefault {
    DECLARE_PFUTILS
    [defaultConfig updateTo:config];
    [utils setDefault:[defaultConfig getData] forKey:NOTE_DEFAULT_CONFIG];
}
        
-(BOOL) saveNote {
    DECLARE_PFUTILS
    if (note.needSave && ![note isEmptyNote]) {
        [utils setDefault:note.path forKey:NOTE_DEFAULT_LAST_NOTE_PATH];
        
        PFNoteCell *currentCell = [note getCell];
        if (currentCell && [currentCell isEmptyCell]) {
            [note removeCell];
        }
        
        [note save];
        note.needSave = NO;
        [self updateNoteIndex:note save:YES];
        return YES;
    }
    return NO;
}

-(void) newNote {
    [self saveNote];
    [self clearCache];
    [note release];
    note = [[PFNote alloc] init];
    [note.config updateTo:defaultConfig];
    [config updateTo:note.config];
    [inputPageConfig setGridColorIndex:[config getGridColorIndex]];
    [note seekChapterEnd];
    [self appendNewParagraphToCurrentPage];
    [self resetPages];
    [self refreshConfig];
}

-(BOOL) loadNote:(NSString *)path {
    [self saveNote];
    
    DECLARE_PFUTILS
    PFNote *newNote = nil;
    @try {
        newNote = [[PFNote alloc] initFromPath:path];
    }
    @catch (NSException * e) {
        NSLog(@"Failed to load: %@, error: %@", path, e);
        newNote = nil;
    }
    
    if (newNote) {
        if ([newNote.chapters count] == 0) {
            NSLog(@"Bad Note: %@\n %@", newNote.path, [newNote getData]);
            newNote.state.chapter = -1;
            newNote.state.paragraph = -1;
            newNote.state.cell = -1;
            [newNote createNewChapter];
            [newNote createNewParagraph];
            PFUTILS_showAlertMsg(_PF_L10N(@"app_error"),
                                 _PF_L10N(@"model_load_failed"),
                                 _PF_L10N(@"ok"), nil);
        }
        [self clearCache];
        [note release]; 
        note = newNote;
        [config updateTo:note.config];
        [inputPageConfig setGridColorIndex:[config getGridColorIndex]];
        [self resetPages];
        [utils setDefault:path forKey:NOTE_DEFAULT_LAST_NOTE_PATH];
        [self refreshConfig];

        if (![noteIndex valueForKey:note.path]) {
            [self updateNoteIndex:note save:YES];
        }

        return YES;
    } else {
        PFUTILS_showAlertMsg(_PF_L10N(@"app_error"),
                             _PF_L10N(@"model_load_failed"),
                             _PF_L10N(@"ok"), nil);
    }
    return NO;
}

-(BOOL) pageUp {
    BOOL result = NO;
    if ((currentPageIndex != NSNotFound)
               &&(currentPageIndex > 0)) {
        [self clearCellCache];
        [self _updateCurrentPage:[allPages objectAtIndex:currentPageIndex - 1]];
        result = YES;
    }
    return result;
}

-(BOOL) pageDown {
    BOOL result = NO;
    if ((currentPageIndex != NSNotFound)&&(currentPageIndex < [allPages count] - 1)) {
        [self clearCellCache];
        [self _updateCurrentPage:[allPages objectAtIndex:currentPageIndex + 1]];
        result = YES;
    }    
    return result;
}

-(void) clearCache {
    [self clearCellCache];
    [self clearPageCache];
}

-(void) clearCellCache {
    DECLARE_PFUTILS
    [utils clearCache:PFNOTE_CELL_CACHE_PREFIX];
    [[NSNotificationCenter defaultCenter] postNotificationName:PFNotePagePainterClearCellCacheNotification object:self];
}

-(void) clearPageCache {
    DECLARE_PFUTILS
    [utils clearCache:PAGE_CACHE_PREFIX];
}

-(void) scale:(CGFloat)scale {
    if (scale == 1.0f) {
        return;
    }
    config.factor = [PFNotePoint getFactor:config.factor scale:scale];
    [note setFactor:config.factor];
    [self resetPages];
    [self clearCellCache];
}

-(int) getPageNum {
    int result = 0;
    if (allPages) {
        result = [allPages count];
    }
    return result;
}

-(id<PFPage>) getPage:(int)index {
    id<PFPage> result = nil;
    if (allPages) {
        if ((index >=0) && (index < [allPages count])) {
            result = [allPages objectAtIndex:index];
        }
    }
    return result;
}

-(int) getCurrentPageIndex {
    return currentPageIndex;
}

-(BOOL) setCurrentPageIndex:(int)index {
    BOOL result = NO;
    if (allPages) {
        if ((index != NSNotFound) && (index >=0) && (index < [allPages count]) && (index != currentPageIndex)) {
            [self clearCellCache];
            id<PFPage> newCurrentPage = [allPages objectAtIndex:index];
            [self _updateCurrentPage:newCurrentPage];
            result = YES;
        }
    }
    return result;
}

-(void) refreshConfig {
    inputPageConfig.themeType = config.themeType;
    [inputPageConfig setStrokeType:[config getStrokeType]];
    [self clearCache];
    if (delegate) {
        [delegate onConfigUpdate];
    }
}


#pragma mark -
#pragma mark products 
-(NSString *)getProductKey:(NSString *)productID withType:(NSString *)productType {
    return [NSString stringWithFormat:NOTE_PRODUCT_FORMAT, productType, productID];
}

-(BOOL) hadPurchased:(NSString *)productKey {
    NSDictionary *productInfo = [products valueForKey:productKey];
    if (!productInfo) {
        //Treat an unexist product as purchased.
        return YES;
    }
    DECLARE_PFUTILS
    id purchased = [utils getDefault:productKey];
    if (purchased && [@"yes" isEqualToString:purchased]) {
        return YES;
    }
    return NO;
}

-(BOOL) hadPurchased:(NSString *)productID withType:(NSString *)productType {
    NSString *productKey = [self getProductKey:productID withType:productType];
    return [self hadPurchased:productKey];
}

-(void) purchase:(NSString *)productKey {
    [self unlock:productKey];

    NSDictionary *productInfo = [self getProductInfo:productKey];

    if (productInfo) {
        PFUTILS_showAlertMsg(_PF_L10N(@"purchase_finished_title"),
                             NSFormat(_PF_L10N(@"purchase_finished_description_%@"),
                                      [productInfo valueForKey:NOTE_PRODUCT_TITLE]),
                             _PF_L10N(@"ok"), nil);
    } else {
        [self logProductEvent:@"invalid-purchase:" productKey:productKey];
    }
}

-(void) unlock:(NSString *)productKey {
    DECLARE_PFUTILS
    [utils setDefault:@"yes" forKey:productKey];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:productKey object:nil];
}

-(NSArray *) getUnpurchasedProductsInConfig:(PFNoteConfig *)checkedConfig {
    NSMutableArray *result = nil;

    //checking strokeType
    NSString *strokeType = [checkedConfig getStrokeType];
    if (strokeType) {
        NSString *productKey = [self getProductKey:strokeType withType:PFNoteProductTypeStroke];
        if (![self hadPurchased:productKey]) {
            if (result == nil) result = [[[NSMutableArray alloc] init] autorelease];
            [result addObject:[self getProductInfo:productKey]];
            [self logProductEvent:@"try:" productKey:productKey];
        }
    }
    
    //checking themeType
    NSString *themeType = checkedConfig.themeType;
    if (themeType) {
        NSString *productKey = [self getProductKey:themeType withType:PFNoteProductTypeTheme];
        if (![self hadPurchased:productKey]) {
            if (result == nil) result = [[[NSMutableArray alloc] init] autorelease];
            [result addObject:[self getProductInfo:productKey]];
            [self logProductEvent:@"try:" productKey:productKey];
        }
    }
    return result;
}

-(NSString *) getProductTitles:(NSArray *)productInfos {
    NSMutableArray *titles = [[[NSMutableArray alloc] init] autorelease];
    for (NSDictionary *productInfo in productInfos) {
        [titles addObject:NSFormat(@"[%@]", [productInfo valueForKey:NOTE_PRODUCT_TITLE])];
    }
    return [titles componentsJoinedByString:@", "];
}

-(NSArray *) getAvailableProductKeys {
    NSMutableArray *result = [[[NSMutableArray alloc] init] autorelease];
    for (NSString *productKey in productList) {
        if (![self hadPurchased:productKey]) {
            [result addObject:productKey];
        }
    }
    return result;
}

-(NSDictionary *) getProductInfo:(NSString *)productKey {
    NSDictionary *productInfo = [products valueForKey:productKey];
    return productInfo;
}

-(void) logProductEvent:(NSString *)event productInfo:(NSDictionary *)productInfo {
    [self logProductEvent:event productKey:[productInfo valueForKey:NOTE_PRODUCT_KEY]];
}

-(void) logProductEvent:(NSString *)event productKey:(NSString *)productKey {
    NSDictionary *parameters = [NSDictionary dictionaryWithObject:productKey forKey:@"product"];
    [FlurryAPI logEvent:event withParameters:parameters];
}

-(void) onInvalidProductIdentifier:(NSString *)productKey {
    NSMutableDictionary *productInfo = [products valueForKey:productKey];
    [productInfo setValue:nil forKey:NOTE_PRODUCT_SKPRODUCT];
    [productInfo setValue:_PF_L10N(@"product_price_invalid") forKey:NOTE_PRODUCT_PRICE];
}

-(void) onSKProduct:(SKProduct *)product {
    NSMutableDictionary *productInfo = [products valueForKey:product.productIdentifier];
    [productInfo setValue:product forKey:NOTE_PRODUCT_SKPRODUCT];
    
    NSNumberFormatter *numberFormatter = [[[NSNumberFormatter alloc] init] autorelease];
    [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [numberFormatter setLocale:product.priceLocale];
    NSString *formattedString = [numberFormatter stringFromNumber:product.price];
    [productInfo setValue:formattedString forKey:NOTE_PRODUCT_PRICE];
}

-(NSString *) _getIcon:(NSString *)name 
                  type:(NSString *)type {
    if (type == PFNoteProductTypeTheme) {
        return [PFNoteTheme getIconPath:name];
    }
    return NOTE_PRODUCT_NONE;
}


-(void) _addProduct:(NSString *)name 
               type:(NSString *)type {
    NSString *productKey = [self getProductKey:name withType:type];
    NSDictionary *productInfo = nil;
    NSString *title = _PF_L10N_(NSFormat(@"product_%@_%@_title", type, name), name);
    NSString *description = _PF_L10N_(NSFormat(@"product_%@_%@_description", type, name), @"");
    NSString *price = _PF_L10N(@"product_price_loading");
    NSString *icon = [self _getIcon:name type:type];
    productInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                   productKey, NOTE_PRODUCT_KEY,
                   type, NOTE_PRODUCT_TYPE,
                   name, NOTE_PRODUCT_NAME,
                   title, NOTE_PRODUCT_TITLE,
                   description, NOTE_PRODUCT_DESCRIPTION,
                   icon, NOTE_PRODUCT_ICON,
                   price, NOTE_PRODUCT_PRICE, 
                   nil];
    [products setValue:productInfo forKey:productKey];
    [productList addObject:productKey];
    
}

- (void) _initProducts {
    products = [[NSMutableDictionary alloc] init];
    productList = [[NSMutableArray alloc] init];
    //General products
    [self _addProduct:NOTE_PRODUCT_ADFREE
                 type:PFNoteProductTypeGeneral];
    //Stroke products
    [self _addProduct:PFNOTE_POP_STROKE
                 type:PFNoteProductTypeStroke];
    //Theme products
    [self _addProduct:PFNOTE_THEME_A
                 type:PFNoteProductTypeTheme];
    [self _addProduct:PFNOTE_THEME_C
                 type:PFNoteProductTypeTheme];
    
    //For debug only
    //[self clearAllPurchasedProducts];
}

-(void) clearAllPurchasedProducts {
    DECLARE_PFUTILS
    for (NSString *productKey in productList) {
        if ([self hadPurchased:productKey]) {
            [utils setDefault:@"no" forKey:productKey];
        }
    }    
}

#pragma mark - Universal related
-(BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return [self shouldAutorotateToInterfaceOrientation:interfaceOrientation supportLandscape:NO];
}

-(BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
                              supportLandscape:(BOOL)supportLandscape {
    if (self.iPadMode) {
        if (IPAD_SUPPORT_LANDSCAPE && supportLandscape) {
            return YES;
        } else if (UIInterfaceOrientationIsPortrait(interfaceOrientation)) {
            return YES;
        }
    } else {
        if (interfaceOrientation == UIInterfaceOrientationLandscapeRight) {
            return YES;
        }
    }
    return NO;
}

-(BOOL) iPadLandScape {
    return self.iPadMode && UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation);
}

-(CGSize) getWindowSize {
    if (self.iPadMode) {
        if (UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation)) {
            return CGSizeMake(768, 1004);
        } else {
            return CGSizeMake(1024, 748);
        }
    } else {
        return CGSizeMake(480, 320);
    }
}

@end

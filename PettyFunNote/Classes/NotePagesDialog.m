//
//  NotePagesDialog.m
//  PettyFunNote
//
//  Created by YJ Park on 12/9/10.
//  Copyright 2010 PettyFun. All rights reserved.
//

#import "NotePagesDialog.h"
#import "PFNoteModel.h"
#import "AQGridViewCell.h"
#import "PFUtils.h"

@implementation NotePagesDialog
@synthesize delegate;

#pragma mark -
#pragma mark Initialization

-(NotePagesDialog *) initWithDisplayPanel:(NoteDisplayPanel *)noteDisplayPanel {
	if ((self = [self initWithNibName: nil bundle: nil])) {
        displayPanel = [noteDisplayPanel retain];
        [self _initThumbnailView];
    }
    return self;
}

- (void)dealloc {
    [thumbnailFont release];
    [displayPanel release];
    [thumbnailView release];
    [super dealloc];
}

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    UIColor *backgroundColor = PFNOTE_POPUP_BACKGROUDCOLOR;
    
    self.view.backgroundColor = backgroundColor;
    
    DECLARE_PFUTILS
    [utils showProgressHUDInView:self.view withText:@""];

    PFUTILS_delayWithInterval(PFNOTE_PAGES_SELECT_PAGE_DELAY, nil, reloadThumbnails:)
    //loaded = NO;
    //[self.gridView reloadData];
}
 
- (void)viewDidDisappear:(BOOL)animated {
    loaded = NO;
    [self.gridView reloadData];
    [super viewDidDisappear:animated];
}

-(void) reloadThumbnails:(NSTimer *)timer {
    loaded = YES;
    [self.gridView reloadData];
    PFUTILS_delayWithInterval(PFNOTE_PAGES_SELECT_PAGE_DELAY, nil, selectCurrentPage:)
}

#pragma mark -
#pragma mark AQGridView Related

- (CGSize) portraitGridCellSizeForGridView: (AQGridView *) aGridView
{
    return cellSize;
}

- (NSUInteger) numberOfItemsInGridView: (AQGridView *) aGridView
{
    if (!loaded) {
        return 0;
    }
    DECLARE_PFNOTE_MODEL
    return ( [model getPageNum] );
}

-(void) selectCurrentPage:(NSTimer *)timer {
    DECLARE_PFNOTE_MODEL
    NSInteger index = [model getCurrentPageIndex];
    if (index >= 0) {
        if ([self.gridView indexOfSelectedItem] == index) {
            [self.gridView scrollToItemAtIndex:index atScrollPosition:AQGridViewScrollPositionMiddle animated:NO];
        } else {
            [self.gridView selectItemAtIndex:index animated:NO scrollPosition:YES];
        }
    }    
    DECLARE_PFUTILS
    [utils hideProgressHUD];
}

- (AQGridViewCell *) gridView: (AQGridView *) aGridView cellForItemAtIndex: (NSUInteger) index
{    
    static NSString *CellIdentifier = @"PagesThumbnailCell";
    
	AQGridViewCell * cell = [aGridView dequeueReusableCellWithIdentifier: CellIdentifier];
    CGRect cellRect = CGRectMake(0, 0, thumbnailSize.width, thumbnailSize.height);
    if (cell == nil) {
		cell = [[[AQGridViewCell alloc] initWithFrame: cellRect
                                      reuseIdentifier: CellIdentifier] autorelease];
        cell.selectionGlowColor = [UIColor yellowColor];
    } else {
		cell.frame = cellRect;
        UIView *thumbnail = [cell.contentView viewWithTag:NOTE_PAGE_THUMBNAIL_TAG];
        if (thumbnail) {
            [thumbnail removeFromSuperview];
        }
    }

	// Configure the cell.
    UIImage *thumbnailImage = [self _getThumbnailImage:index];
    UIImageView *thumbnail = [[[UIImageView alloc] initWithImage:thumbnailImage] autorelease];
    thumbnail.tag = NOTE_PAGE_THUMBNAIL_TAG;
	[cell.contentView addSubview: thumbnail];
    return cell;
}

- (NSUInteger) gridView: (AQGridView *) gridView willDeselectItemAtIndex: (NSUInteger) index {
    //A little hacky this way, though don't want to change AQGridView too much.
    PFUTILS_delayWithInterval(PFNOTE_PAGES_SELECT_PAGE_DELAY, nil, onPageSelected:)
    return index;
}

-(void) onPageSelected: (NSTimer *)timer {
    int index = [self.gridView indexOfSelectedItem];
    if (delegate) {
        [delegate onPageSelected:index];
    }
}

#pragma mark -
#pragma mark Public Methods
-(CGSize) getContentSize {
    [self _updateThumbnailView];
    return contentSize;
}

#pragma mark -
#pragma mark Internal Methods
-(void)_initThumbnailView {
    /*
    UIImage *desktopImage = [[UIImage imageWithContentsOfFile:
                              [[NSBundle mainBundle] 
                               pathForResource:@"pages-pattern"
                               ofType:@"jpg"]] retain];
    self.gridView.backgroundColor = [UIColor colorWithPatternImage:desktopImage];
    self.gridView.requiresSelection = YES;
    */
    
    thumbnailView = [[PFPageView alloc] init];
    thumbnailView.pageConfig = [[[PFNoteConfig alloc] init] autorelease];
    DECLARE_PFNOTE_PAINTER_FACTORY
    thumbnailView.pagePainter = [painterFactory factoryPagePainter];
    thumbnailView.page = nil;
    thumbnailView.delegate = self;
}

-(void)_updateThumbnailView {
    CGSize pageSize = displayPanel.view.frame.size;
    DECLARE_PFNOTE_MODEL
    [thumbnailView.pageConfig updateTo:[model config]];
    [(PFNoteConfig *)thumbnailView.pageConfig setStrokeType:nil];
    [thumbnailView.pagePainter refreshConfig];
    
    thumbnailView.frame = CGRectMake(0, 0,
                                     pageSize.width,
                                     pageSize.height);
    
    CGFloat contentScale = model.iPadMode ? NOTE_PAGE_CONTENT_SCALE_IPAD : NOTE_PAGE_CONTENT_SCALE_IPHONE;
    contentSize = CGSizeMake(pageSize.width * contentScale,
                      pageSize.height * contentScale);
    
    cellSize = CGSizeMake(contentSize.width / NOTE_PAGE_THUMBNAIL_NUM,
                      contentSize.height / NOTE_PAGE_THUMBNAIL_NUM);

    thumbnailSize = CGSizeMake(contentSize.width * NOTE_PAGE_THUMBNAIL_SCALE,
                               contentSize.height * NOTE_PAGE_THUMBNAIL_SCALE);     
    
    if (thumbnailFont) [thumbnailFont release];
    thumbnailFont = [[UIFont boldSystemFontOfSize: thumbnailSize.height / 3.0f] retain];
}

-(void) _drawText:(NSString *)text
        onContext:(CGContextRef)context
           inRect:(CGRect)rect
         withFont:(UIFont *)font
            color:(UIColor *)color 
           shadow:(BOOL)shadow {
    CGSize textSize = [text sizeWithFont:font
                       constrainedToSize:rect.size
                           lineBreakMode:UILineBreakModeCharacterWrap];
    CGRect textRect = CGRectMake((rect.size.width - textSize.width) / 2.0f,
                                 (rect.size.height - textSize.height) / 2.0f,
                                 textSize.width,
                                 textSize.height);
    
    
    [color set];
    if (shadow) {
        CGContextSetShadow(context, CGSizeMake(6.0f, 4.0f), 4.0f);
    } else {
        CGContextSetShadowWithColor(context, CGSizeMake(6.0f, 4.0f), 4.0f, NULL);
    }
    
    [text drawInRect:textRect
            withFont:font
       lineBreakMode:UILineBreakModeCharacterWrap
           alignment:UITextAlignmentCenter];
}

-(UIImage *)_getThumbnailImage:(NSInteger)index {
    DECLARE_PFUTILS
    NSString *pageCacheKey = NSFormat(@"%@%d", PAGE_CACHE_PREFIX, index);
    UIImage *image = [utils getCache:pageCacheKey];
    if (!image) {
        //NSLog(@"Page cache not hit: %d", index);
        image = [self _getThumbnailImageNoCache:index];
        [utils setCache:image forKey:pageCacheKey];
    }
    return image;
}

-(UIImage *)_getThumbnailImageNoCache:(NSInteger)index {
    DECLARE_PFNOTE_PAINTER_FACTORY
    DECLARE_PFNOTE_MODEL
    PFNoteTheme *theme = [painterFactory getTheme:model.config];
    thumbnailView.page = [model getPage:index];
    
    UIGraphicsBeginImageContext(thumbnailSize); 

    CGFloat contentScale = model.iPadMode ? NOTE_PAGE_CONTENT_SCALE_IPAD : NOTE_PAGE_CONTENT_SCALE_IPHONE;

    float scale = contentScale * NOTE_PAGE_THUMBNAIL_SCALE;    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGRect thumbnailRect = CGRectMake(0, 0, thumbnailSize.width, thumbnailSize.height);

    UIImage *paperImage = [theme getImage:PFNoteThemeImagePaper];
    if (paperImage) {
        CGContextTranslateCTM (context, 0.0f, thumbnailRect.size.height);
        CGContextScaleCTM(context, 1.0f, -1.0f);
        CGImageRef scaledPaperImage = CGImageCreateWithImageInRect(paperImage.CGImage,
                                                            thumbnailView.frame); 
        CGContextDrawImage(context, thumbnailRect, scaledPaperImage);
        CGContextScaleCTM(context, 1.0f, -1.0f);
        CGContextTranslateCTM (context, 0.0f, -thumbnailRect.size.height);
    } else {
        CGContextSetFillColorWithColor(context, theme.backgroundColor.CGColor);
        CGContextFillRect(context, thumbnailRect);
    }

    CGContextScaleCTM(context, scale, scale);
    
    [thumbnailView drawRect:thumbnailView.frame onContext:context];
    
    CGContextScaleCTM(context, 1.0f / scale, 1.0f / scale);

    NSString *pageNum = [NSString stringWithFormat:@"%d", index + 1];
    [self _drawText:pageNum onContext:context inRect:thumbnailRect
           withFont:thumbnailFont color:[theme getTextColor] shadow:YES];
    
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return result;
}

-(BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    DECLARE_PFNOTE_MODEL
    return [model shouldAutorotateToInterfaceOrientation:interfaceOrientation];
}

@end

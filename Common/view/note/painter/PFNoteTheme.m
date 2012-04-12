//
//  PFNoteBaseTheme.m
//  PettyFunNote
//
//  Created by YJ Park on 12/16/10.
//  Copyright 2010 PettyFun. All rights reserved.
//

#import "PFNoteTheme.h"
#import "PFUtils.h"

static NSDictionary  *_PFNoteThemeImageNames = nil;

@implementation PFNoteTheme
@synthesize currentColor;
@synthesize backgroundColor;
@synthesize colors;
@synthesize gridColors;
@synthesize extraConfig;


+(NSString *) getIconPath:(NSString *)themeID {
    return [PFNoteTheme getImagePath:PFNOTE_THEME_ICON_NAME forTheme:themeID];
}

+(NSString *) getImagePath:(NSString *)imageName forTheme:(NSString *)themeID {
    DECLARE_PFUTILS
    if (!utils.iPadMode) {
        NSString *result = [[[[PFUtils getPathInCommonResource:PFNOTE_THEME_IMAGE_PATH]
                             stringByAppendingPathComponent:themeID]
                            stringByAppendingPathComponent:@"iPhone"]
                            stringByAppendingPathComponent:imageName];
        if ([utils isPathExist:result]) {
            return result;
        }
    }
    return [[[PFUtils getPathInCommonResource:PFNOTE_THEME_IMAGE_PATH]
             stringByAppendingPathComponent:themeID]
            stringByAppendingPathComponent:imageName];
}

-(id) initWithThemeID:(NSString *)theThemeID {
    if ((self = [super init])) {
        themeID = [theThemeID copy];
        parentThemeID = [[self _getParentThemeID] copy];
        currentColor = [[self _getCurrentColor] retain];
        backgroundColor = [[self _getBackgroundColor] retain];
        [self _initImageNames];
        [self _initColors];
        [self _initGridColors];
        [self _initExtraConfig];
    }
    return self;
}

-(void) dealloc {
    [themeID release];
    [currentColor release];
    [backgroundColor release];
    [colors release];
    [gridColors release];
    [extraConfig release];
    [super dealloc];
}

-(UIColor *) getColor:(NSInteger)colorIndex {
    if (colorIndex >= 0 && colorIndex < [colors count]) {
        return [colors objectAtIndex:colorIndex];
    }
    return [colors objectAtIndex:0];
}

-(UIColor *) getGridColor:(NSInteger)gridColorIndex {
    if (gridColorIndex >= 0 && gridColorIndex < [gridColors count]) {
        return [gridColors objectAtIndex:gridColorIndex];
    }
    return [gridColors objectAtIndex:0];
}

-(UIColor *) getTextColor {
    return [colors objectAtIndex:0];
}

-(void) _initColors {
    colors = [[NSArray arrayWithObjects: 
               [self _getDefaultColor],
               [UIColor colorWithHexString:@"ff0036"],
               [UIColor colorWithHexString:@"ed441c"],
               [UIColor colorWithHexString:@"ffba00"],
               [UIColor colorWithHexString:@"98f739"],
               [UIColor colorWithHexString:@"62b78e"],
               [UIColor colorWithHexString:@"005b7f"],
               [UIColor colorWithHexString:@"531d4b"],
               nil] retain];
}

-(void) _initGridColors {
    gridColors = [[NSArray arrayWithObjects: 
                   [UIColor colorWithHexString:@"3295EA"],
                   [UIColor colorWithHexString:@"9a9a9a"],
                   [UIColor colorWithHexString:@"b9b0a5"],
                   [UIColor colorWithHexString:@"d8c4b2"],
                   [UIColor colorWithHexString:@"90acac"],
                   nil] retain];
}

-(NSString *) _getParentThemeID {
    return PFNOTE_DEFAULT_THEME_ID;
}

-(UIColor *) _getCurrentColor {
    return [UIColor blueColor];
}

-(UIColor *) _getDefaultColor {
    return [UIColor colorWithHexString:@"131313"];
}

-(UIColor *)_getBackgroundColor {
    return [UIColor whiteColor];
}

-(void) _initExtraConfig {
    extraConfig = [[PFPageConfig alloc] init];

    extraConfig.factor = 0.0f;
    extraConfig.marginLeft = 0.0f;
    extraConfig.marginRight = 0.0f;
    extraConfig.marginTop = 0.0f;
    extraConfig.marginBottom = 0.0f;
    
    extraConfig.marginParagraph = 0.0f;
    extraConfig.marginLine = 0.0f;
    extraConfig.marginWord = 0.0f;    
    extraConfig.paragraphIndent = 0.0f;    
}

-(void) _initImageNames {
    if (_PFNoteThemeImageNames == nil) {
        _PFNoteThemeImageNames = [[NSMutableDictionary dictionary] retain];
        PFNoteThemeAddImageName(PFNoteThemeImagePreview, @"preview.png");
        PFNoteThemeAddImageName(PFNoteThemeImageWatermark, @"watermark.png");
        PFNoteThemeAddImageName(PFNoteThemeImagePaper, @"paper.png");
        PFNoteThemeAddImageName(PFNoteThemeImageInput, @"input.png");
        //Buttons on app toolbar
        PFNoteThemeAddImageName(PFNoteThemeImageToolBar, @"toolbar.png");
        PFNoteThemeAddImageName(PFNoteThemeImageToggelInput, @"show_input.png");
        PFNoteThemeAddImageName(PFNoteThemeImageSetup, @"setup.png");
        PFNoteThemeAddImageName(PFNoteThemeImageStore, @"store.png");
        PFNoteThemeAddImageName(PFNoteThemeImageBrowse, @"browse.png");
        //Buttons on input toolbar
        PFNoteThemeAddImageName(PFNoteThemeImageInputHide, @"hide_input.png");
        PFNoteThemeAddImageName(PFNoteThemeImageInputOption, @"option.png");
        PFNoteThemeAddImageName(PFNoteThemeImageInputUndo, @"undo.png");
        PFNoteThemeAddImageName(PFNoteThemeImageInputRedo, @"redo.png");
        PFNoteThemeAddImageName(PFNoteThemeImageInputDelete, @"delete.png");
        PFNoteThemeAddImageName(PFNoteThemeImageInputReturn, @"return.png");
        PFNoteThemeAddImageName(PFNoteThemeImageInputNextWordLeft, @"next_left.png");
        PFNoteThemeAddImageName(PFNoteThemeImageInputNextWordRight, @"next_right.png");
        PFNoteThemeAddImageName(PFNoteThemeImageInputWrapWordLeft, @"wrap_left.png");
        PFNoteThemeAddImageName(PFNoteThemeImageInputWrapWordRight, @"wrap_right.png");
        //Images on display panel
        PFNoteThemeAddImageName(PFNoteThemeImageDisplayHand, @"hand.png");
        PFNoteThemeAddImageName(PFNoteThemeImageDisplayLoadingCell, @"loading.png");
        PFNoteThemeAddImageName(PFNoteThemeImageDisplaySpaceCell, @"space.png");
        PFNoteThemeAddImageName(PFNoteThemeImageDisplayReturnCell, @"enter.png");
        PFNoteThemeAddImageName(PFNoteThemeImageDisplayTurnPageLeft, @"turn_left.png");
        PFNoteThemeAddImageName(PFNoteThemeImageDisplayTurnPageRight, @"turn_right.png");
        
        //Page number images
        PFNoteThemeAddImageName(PFNoteThemeImagePageNumber0, @"page_number_0.png");
        PFNoteThemeAddImageName(PFNoteThemeImagePageNumber1, @"page_number_1.png");
        PFNoteThemeAddImageName(PFNoteThemeImagePageNumber2, @"page_number_2.png");
        PFNoteThemeAddImageName(PFNoteThemeImagePageNumber3, @"page_number_3.png");
        PFNoteThemeAddImageName(PFNoteThemeImagePageNumber4, @"page_number_4.png");
        PFNoteThemeAddImageName(PFNoteThemeImagePageNumber5, @"page_number_5.png");
        PFNoteThemeAddImageName(PFNoteThemeImagePageNumber6, @"page_number_6.png");
        PFNoteThemeAddImageName(PFNoteThemeImagePageNumber7, @"page_number_7.png");
        PFNoteThemeAddImageName(PFNoteThemeImagePageNumber8, @"page_number_8.png");
        PFNoteThemeAddImageName(PFNoteThemeImagePageNumber9, @"page_number_9.png");
        PFNoteThemeAddImageName(PFNoteThemeImagePageNumberLeft, @"page_number_left.png");
        PFNoteThemeAddImageName(PFNoteThemeImagePageNumberMiddle, @"page_number_middle.png");
        PFNoteThemeAddImageName(PFNoteThemeImagePageNumberRight, @"page_number_right.png");

        //iPad Landscape
        PFNoteThemeAddImageName(PFNoteThemeImagePaperIPadLandscape, @"paper_l.png");
        PFNoteThemeAddImageName(PFNoteThemeImageInputIPadLandscape, @"input_l.png");   
        PFNoteThemeAddImageName(PFNoteThemeImageToolBarIPadLandscape, @"toolbar_l.png");   
    }    
}

-(NSString *) getImagePath:(PFNoteThemeImage)imageID {
    NSString *result = nil;
    NSString *imageName = [_PFNoteThemeImageNames valueForKey:NSFormat(@"%d", imageID)];
    if (imageName) {
        NSString *imagePath = [PFNoteTheme getImagePath:imageName forTheme:themeID];
        DECLARE_PFUTILS
        if ([utils isPathExist:imagePath]) {
            result = imagePath;
        } else {
            imagePath = [PFNoteTheme getImagePath:imageName forTheme:parentThemeID];
            if ([utils isPathExist:imagePath]) {
                result = imagePath;
            } else {
                imagePath = [PFNoteTheme getImagePath:imageName forTheme:PFNOTE_DEFAULT_THEME_ID];
                if ([utils isPathExist:imagePath]) {
                    result = imagePath;
                }
            }
        }
    }
    return result;
}

-(UIImage *) getImage:(PFNoteThemeImage)imageID {
    NSString *imagePath = [self getImagePath:imageID];
    UIImage *result = nil;

    if (imagePath && (![imagePath isEqualToString:@""])) {
        NSString *themeCacheKey = NSFormat(@"%@%@", PFNOTE_THEME_IMAGE_CACHE_PREFIX, imagePath);
        DECLARE_PFUTILS
        if (PFNOTE_THEME_USE_CACHE) result = [utils getCache:themeCacheKey];
        if (result == nil) {
            result = [UIImage imageWithContentsOfFile:imagePath];
            if (PFNOTE_THEME_USE_CACHE) [utils setCache:result forKey:themeCacheKey];
        }
    }
    return result;
}

-(UIColor *) getPaperColor:(BOOL)iPadLandscape {
    if (iPadLandscape) {
        return [self getImageAsColor:PFNoteThemeImagePaperIPadLandscape defaultColor:backgroundColor];
    } else {
        return [self getImageAsColor:PFNoteThemeImagePaper defaultColor:backgroundColor];        
    }
}

-(UIColor *) getPreviewColor {
    return [self getImageAsColor:PFNoteThemeImagePreview defaultColor:backgroundColor];
}

-(UIColor *) getImageAsColor:(PFNoteThemeImage)imageID defaultColor:(UIColor *)color {
    NSString *imagePath = [self getImagePath:imageID];
    if (!imagePath) {
        return color;
    }
    NSString *themeCacheKey = NSFormat(@"%@%@", PFNOTE_THEME_COLOR_CACHE_PREFIX, imagePath);
    DECLARE_PFUTILS
    UIColor *result = nil;
    if (PFNOTE_THEME_USE_CACHE) result = [utils getCache:themeCacheKey];
    if (result == nil) {
        UIImage *image = [self getImage:imageID];
        if (image) {
            result = [UIColor colorWithPatternImage:image];
            if (PFNOTE_THEME_USE_CACHE) [utils setCache:result forKey:themeCacheKey];
        }
    }
    if (!result) {
        result = color;
    }
    return result;
}

-(void) paintControlCharactor:(PFNoteCell *)cell
                    onContext:(CGContextRef)context
                   withConfig:(PFPageConfig *)config {
    if (cell.type == PFNOTE_CELL_TYPE_SPACE) {
        [self paintImageAsPattern:PFNoteThemeImageDisplaySpaceCell 
                         onContext:context 
                            inRect:[cell getContentRectWithConfig:config]];
    } else if (cell.type == PFNOTE_CELL_TYPE_RETURN) {
        [self paintImageAsPattern:PFNoteThemeImageDisplayReturnCell 
                         onContext:context 
                            inRect:[cell getContentRectWithConfig:config]];
    }
}

-(void) paintImageAsPattern:(PFNoteThemeImage)imageID 
                  onContext:(CGContextRef)context 
                     inRect:(CGRect)rect {
    UIImage *pattern = [self getImage:imageID];
    if (pattern) {
        UIGraphicsPushContext(context);
        [pattern drawAsPatternInRect:rect];
        UIGraphicsPopContext();
    }    
}

-(void) updateButtonImage:(PFNoteThemeImage)imageID button:(id)button {
    UIImage *image = [self getImage:imageID];
    if (image) {
        if ([[button class] isSubclassOfClass:[UIBarButtonItem class]]) {
            UIBarButtonItem *barButton = (UIBarButtonItem *)button;
            UIButton *imageButton = nil;
            if (NO && barButton.customView
                && ([[barButton.customView class] isSubclassOfClass:[UIButton class]])) {
                imageButton = (UIButton *)barButton.customView;
            } else {                
                imageButton = [UIButton buttonWithType:UIButtonTypeCustom];
                [imageButton addTarget:barButton.target
                                action:barButton.action
                      forControlEvents:UIControlEventTouchUpInside];
                imageButton.frame = CGRectMake(0, 0, image.size.width, image.size.height);
                barButton.customView = imageButton;
            }
            [imageButton setImage:image forState:UIControlStateNormal];
        } else if ([[button class] isSubclassOfClass:[UIButton class]]) {
            [(UIButton *)button setImage:image forState:UIControlStateNormal];
        }
    }
}

-(CGRect) getPageRectWithConfig: (PFPageConfig *)config
                         forSize: (CGSize)viewSize {
    float left = config.marginLeft + self.extraConfig.marginLeft;
    float top = config.marginTop + self.extraConfig.marginTop;
    float right = config.marginRight + self.extraConfig.marginRight;
    float bottom = config.marginBottom + self.extraConfig.marginBottom;
    
    float pageWidth = truncf(viewSize.width - left - right);
    float lineHeight = config.factor * (1.0f + config.marginLine);
    float pageHeight = lineHeight * truncf((viewSize.height - top - bottom + config.factor * config.marginLine) / lineHeight)
                        - config.factor * config.marginLine;
    CGRect pageRect = CGRectMake(left + (viewSize.width - pageWidth - left - right) / 2.0f,
                                 top + (viewSize.height - pageHeight - top - bottom) / 2.0f,
                                 ceilf(pageWidth),
                                 ceilf(pageHeight));
    return pageRect;
}

-(CGPoint) getDisplayHandOffset {
    return CGPointMake(-31.0f, -150.0f);
}

@end

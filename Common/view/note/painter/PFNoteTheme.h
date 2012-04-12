//
//  PFNoteBaseTheme.h
//  PettyFunNote
//
//  Created by YJ Park on 12/16/10.
//  Copyright 2010 PettyFun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PFNoteCell.h"
#import "UIColor-Expanded.h"

#define PFNOTE_THEME_IMAGE_PATH @"Note-Themes"
#define PFNOTE_DEFAULT_THEME_ID @"default"
#define PFNOTE_THEME_ICON_NAME @"icon.png"

#define PFNOTE_THEME_USE_CACHE YES
#define PFNOTE_THEME_IMAGE_CACHE_PREFIX @"theme_image_"
#define PFNOTE_THEME_COLOR_CACHE_PREFIX @"theme_color_"

#define PFNoteThemeAddImageName(imageKey, imageName) \
[_PFNoteThemeImageNames setValue:imageName forKey:[NSString stringWithFormat:@"%d", imageKey]];

typedef enum {
	PFNoteThemeImagePreview,
	PFNoteThemeImageWatermark,
	PFNoteThemeImagePaper,
	PFNoteThemeImageInput,    
    //Buttons on app toolbar
	PFNoteThemeImageToolBar,
	PFNoteThemeImageToggelInput,
	PFNoteThemeImageSetup,
	PFNoteThemeImageStore,
	PFNoteThemeImageBrowse,
    //Buttons on input toolbar
	PFNoteThemeImageInputHide,
	PFNoteThemeImageInputOption,
	PFNoteThemeImageInputUndo,
	PFNoteThemeImageInputRedo,
	PFNoteThemeImageInputDelete,
	PFNoteThemeImageInputReturn,
	PFNoteThemeImageInputNextWordLeft,
	PFNoteThemeImageInputNextWordRight,
	PFNoteThemeImageInputWrapWordLeft,
	PFNoteThemeImageInputWrapWordRight,
    //Images on display panel
	PFNoteThemeImageDisplayHand,
	PFNoteThemeImageDisplayLoadingCell,    
    PFNoteThemeImageDisplaySpaceCell,
    PFNoteThemeImageDisplayReturnCell,
	PFNoteThemeImageDisplayTurnPageLeft,
	PFNoteThemeImageDisplayTurnPageRight,
    //Page number images
    PFNoteThemeImagePageNumber0,
    PFNoteThemeImagePageNumber1,
    PFNoteThemeImagePageNumber2,
    PFNoteThemeImagePageNumber3,
    PFNoteThemeImagePageNumber4,
    PFNoteThemeImagePageNumber5,
    PFNoteThemeImagePageNumber6,
    PFNoteThemeImagePageNumber7,
    PFNoteThemeImagePageNumber8,
    PFNoteThemeImagePageNumber9,
    PFNoteThemeImagePageNumberLeft,
    PFNoteThemeImagePageNumberMiddle,
    PFNoteThemeImagePageNumberRight,
    //iPad Landscape images
	PFNoteThemeImagePaperIPadLandscape,
	PFNoteThemeImageInputIPadLandscape,    
	PFNoteThemeImageToolBarIPadLandscape,    
} PFNoteThemeImage;

@interface PFNoteTheme : NSObject {
    NSString *themeID;
    NSString *parentThemeID;
    
    NSMutableDictionary *imagePathes;

    //BackgroundColor
    UIColor *backgroundColor;    
    //Color for the current cell's border
    UIColor *currentColor;

    NSArray *colors;
    NSArray *gridColors;
    PFPageConfig *extraConfig;
}
@property (readonly) NSArray *colors;
@property (readonly) NSArray *gridColors;
@property (readonly) PFPageConfig *extraConfig;
@property (readonly) UIColor *currentColor;
@property (readonly) UIColor *backgroundColor;

+(NSString *) getIconPath:(NSString *)themeID;
+(NSString *) getImagePath:(NSString *)imageName forTheme:(NSString *)themeID;

-(id) initWithThemeID:(NSString *)theThemeID;

-(CGRect) getPageRectWithConfig: (PFPageConfig *)config
                        forSize: (CGSize)viewSize;

//Indexed color for strokes
-(UIColor *) getColor:(NSInteger)colorIndex;

//Indexed color for grid
-(UIColor *) getGridColor:(NSInteger)gridColorIndex;

//first strokeColor (used by preview)
-(UIColor *) getTextColor;
-(UIColor *) getPaperColor:(BOOL)iPadLandscape;
-(UIColor *) getPreviewColor;

-(CGPoint) getDisplayHandOffset;

-(UIImage *) getImage:(PFNoteThemeImage)imageID;
-(NSString *) getImagePath:(PFNoteThemeImage)imageID;
-(void) _initImageNames;

-(UIColor *) getImageAsColor:(PFNoteThemeImage)imageID defaultColor:(UIColor *)color;
-(void) updateButtonImage:(PFNoteThemeImage)imageID button:(id)button;
-(void) paintImageAsPattern:(PFNoteThemeImage)imageID 
                  onContext:(CGContextRef)context 
                     inRect:(CGRect)rect;
-(void) paintControlCharactor:(id<PFCell>)cell
                    onContext:(CGContextRef)context
                   withConfig:(PFPageConfig *)config;

//Can be override
-(void) _initColors;
-(void) _initGridColors;
-(void) _initExtraConfig;
-(NSString *) _getParentThemeID;
-(UIColor *) _getDefaultColor;
-(UIColor *) _getCurrentColor;
-(UIColor *) _getBackgroundColor;

@end

//
//  PFNotePainter.h
//  PettyFunNote
//
//  Created by YJ Park on 11/11/10.
//  Copyright 2010 PettyFun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PFPageView.h"
#import "PFNotePagePainter.h"
#import "PFNoteTheme.h"
#import "UIColor-Expanded.h"

#define DECLARE_PFNOTE_PAINTER_FACTORY PFNotePainterFactory *painterFactory = [PFNotePainterFactory getInstance];

#define PFNOTE_PAINTER_FACTORY_ADD_THEME(themeID, themeClass) \
    theme = [[[themeClass alloc] initWithThemeID:themeID] autorelease]; \
    [themeList addObject:themeID]; \
    [themes setValue:theme forKey:themeID];

extern NSString *const PFNOTE_DEFAULT_THEME;
extern NSString *const PFNOTE_THEME_A;
extern NSString *const PFNOTE_THEME_B;
extern NSString *const PFNOTE_THEME_C;

extern NSString *const PFNOTE_LINE_GRID_PAINTER;
extern NSString *const PFNOTE_BOX_GRID_PAINTER;
extern NSString *const PFNOTE_CROSS_GRID_PAINTER;

extern NSString *const PFNOTE_TIAN_GE_GRID_PAINTER;

extern NSString *const PFNOTE_BASIC_STROKE;
extern NSString *const PFNOTE_POP_STROKE;

@interface PFNoteGridPainter : NSObject {
}
-(void) paintPage:(id<PFPage>)page
        onContext:(CGContextRef)context 
       withConfig:(PFPageConfig *)config
           inRect:(CGRect)rect
         viewRect:(CGRect)viewRect 
        withTheme:(PFNoteTheme *)theme;
@end

@interface PFNotePainterFactory : NSObject {
    //page painters
    NSMutableArray *themeList;
    NSMutableDictionary *themes;
    NSMutableDictionary *gridPainters;
    NSMutableDictionary *strokePainters;
}

@property (readonly) NSMutableArray *themeList;

+(PFNotePainterFactory *) getInstance;

-(PFNotePagePainter *) factoryPagePainter;

-(PFNoteTheme *) getTheme:(PFPageConfig *)config;
-(PFNoteTheme *) getThemeByType:(NSString *)type;

-(PFNoteGridPainter *) getGridPainter:(PFPageConfig *)config;
-(id<PFNoteStrokePainter>) getStrokePainter:(PFPageConfig *)config;

-(void) _initThemes;
-(void) _initGridPainters;
-(void) _initStrokePainters;

@end

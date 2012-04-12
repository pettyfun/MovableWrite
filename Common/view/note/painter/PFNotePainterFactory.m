//
//  PFNotePainter.m
//  PettyFunNote
//
//  Created by YJ Park on 11/11/10.
//  Copyright 2010 PettyFun. All rights reserved.
//

#import "PFNotePainterFactory.h"
#import "PFNotePagePainter.h"
#import "PFNoteConfig.h"

#import "PFNoteTianGeGridPainter.h"
#import "PFNoteBoxGridPainter.h"
#import "PFNoteLineGridPainter.h"
#import "PFNoteCrossGridPainter.h"

#import "PFNoteDefaultTheme.h"
#import "PFNoteThemeA.h"
#import "PFNoteThemeB.h"
#import "PFNoteThemeC.h"

#import "PFNoteBezierStrokePainter.h"
#import "PFNotePopBezierStrokePainter.h"

NSString *const PFNOTE_DEFAULT_THEME = @"default";
NSString *const PFNOTE_THEME_A = @"a";
NSString *const PFNOTE_THEME_B = @"b";
NSString *const PFNOTE_THEME_C = @"c";
NSString *const PFNOTE_THEME_D = @"d";

NSString *const PFNOTE_LINE_GRID_PAINTER = @"line";
NSString *const PFNOTE_BOX_GRID_PAINTER = @"box";
NSString *const PFNOTE_CROSS_GRID_PAINTER = @"cross";

NSString *const PFNOTE_TIAN_GE_GRID_PAINTER = @"tian_ge";

NSString *const PFNOTE_BASIC_STROKE = @"basic";
NSString *const PFNOTE_POP_STROKE = @"pop";

static PFNotePainterFactory *_painterFactoryInstance = nil;

@implementation PFNoteGridPainter
-(void) paintPage:(id<PFPage>)page
        onContext:(CGContextRef)context 
       withConfig:(PFPageConfig *)config
           inRect:(CGRect)rect
         viewRect:(CGRect)viewRect 
        withTheme:(PFNoteTheme *)theme {
}
@end

@implementation PFNotePainterFactory

@synthesize themeList;

+ (PFNotePainterFactory *) getInstance {
	@synchronized(self) {
		if (_painterFactoryInstance == nil) {
			_painterFactoryInstance = [[PFNotePainterFactory alloc] init];
		}
	}
	return _painterFactoryInstance;
}

- (id) init {
	if ((self = [super init])) {
        [self _initThemes];
        [self _initGridPainters];
        [self _initStrokePainters];
	}
	return self;
}

- (void) dealloc {
    [themes release];
    [themeList release];
    [gridPainters release];
	[super dealloc];
}

-(PFNotePagePainter *) factoryPagePainter {
    return [[[PFNotePagePainter alloc] init] autorelease];
}

-(void) _initGridPainters {
    gridPainters = [[NSMutableDictionary alloc] init];
    PFNoteGridPainter *painter = nil;

    painter = [[[PFNoteTianGeGridPainter alloc] init] autorelease];
    [gridPainters setValue:painter forKey:PFNOTE_TIAN_GE_GRID_PAINTER];

    painter = [[[PFNoteLineGridPainter alloc] init] autorelease];
    [gridPainters setValue:painter forKey:PFNOTE_LINE_GRID_PAINTER];
    
    painter = [[[PFNoteBoxGridPainter alloc] init] autorelease];
    [gridPainters setValue:painter forKey:PFNOTE_BOX_GRID_PAINTER];
    
    painter = [[[PFNoteCrossGridPainter alloc] init] autorelease];
    [gridPainters setValue:painter forKey:PFNOTE_CROSS_GRID_PAINTER];
}

-(void) _initStrokePainters {
    strokePainters = [[NSMutableDictionary alloc] init];
    id<PFNoteStrokePainter> painter = nil;
    
    painter = [[[PFNoteBezierStrokePainter alloc] init] autorelease];
    [strokePainters setValue:painter forKey:PFNOTE_BASIC_STROKE];
    
    painter = [[[PFNotePopBezierStrokePainter alloc] init] autorelease];
    [strokePainters setValue:painter forKey:PFNOTE_POP_STROKE];
}

-(PFNoteTheme *) getTheme:(PFPageConfig *)config {
    PFNoteConfig *noteConfig = (PFNoteConfig *)config;
    return [self getThemeByType:noteConfig.themeType];
}

-(PFNoteTheme *) getThemeByType:(NSString *)type {
    PFNoteTheme *theme = [themes valueForKey:type];
    if (!theme) {
        theme = [themes valueForKey:PFNOTE_DEFAULT_THEME];
    }
    return theme;
}

-(PFNoteGridPainter *) getGridPainter:(PFPageConfig *)config {
    PFNoteConfig *noteConfig = (PFNoteConfig *)config;
    PFNoteGridPainter *painter = [gridPainters valueForKey:[noteConfig getGridType]];
    return painter;
}

-(id<PFNoteStrokePainter>) getStrokePainter:(PFPageConfig *)config {
    PFNoteConfig *noteConfig = (PFNoteConfig *)config;
    id<PFNoteStrokePainter> painter = [strokePainters valueForKey:[noteConfig getStrokeType]];
    if (!painter) {
        painter = [strokePainters valueForKey:PFNOTE_BASIC_STROKE];
    }
    return painter;
}

-(void) _initThemes {
    themes = [[NSMutableDictionary alloc] init];
    themeList = [[NSMutableArray alloc] init];
    PFNoteTheme *theme = nil;
    
    PFNOTE_PAINTER_FACTORY_ADD_THEME(PFNOTE_DEFAULT_THEME, PFNoteDefaultTheme)
    PFNOTE_PAINTER_FACTORY_ADD_THEME(PFNOTE_THEME_A, PFNoteThemeA)
    PFNOTE_PAINTER_FACTORY_ADD_THEME(PFNOTE_THEME_B, PFNoteThemeB)
    PFNOTE_PAINTER_FACTORY_ADD_THEME(PFNOTE_THEME_C, PFNoteThemeC)
}

@end

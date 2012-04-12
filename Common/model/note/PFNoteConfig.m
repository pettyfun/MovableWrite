//
//  PFNoteConfig.m
//  PettyFunNote
//
//  Created by YJ Park on 11/9/10.
//  Copyright 2010 PettyFun. All rights reserved.
//

#import "PFNoteConfig.h"
#import "PFNote.h"
#import "UIColor-Expanded.h"

NSString *const PFNOTECONFIG_THEME_TYPE = @"theme_type";

NSString *const PFNOTECONFIG_PROPERTY_GRID_TYPE = @"grid_type";
NSString *const PFNOTECONFIG_PROPERTY_GRID_COLOR_INDEX = @"grid_color_index";

NSString *const PFNOTECONFIG_PROPERTY_STROKE_TYPE = @"stroke_type";

@implementation PFNoteConfig
@synthesize themeType;

-(NSString *) getType {
    return @"com.pettyfun.bucket.view.note.PFNoteConfig";
}

-(void) dealloc {
    [themeType release];
    [super dealloc];
}

-(void) onInit {
    [super onInit];    
}

-(void) onInitWithData:(NSDictionary *)data {
    [super onInitWithData:data];
    PFOBJECT_GET_STRING(PFNOTECONFIG_THEME_TYPE, themeType)
}

-(void) onGetData:(NSMutableDictionary *)data {
    [super onGetData:data];
    PFOBJECT_SET_STRING(PFNOTECONFIG_THEME_TYPE, themeType)
}

#pragma mark -
#pragma mark Specific Methods

-(void) setToDefaultValues {
    [super setToDefaultValues];
}

-(void) updateTo:(id) config {
    [super updateTo:config];
    if ([[config class] isSubclassOfClass: [PFNoteConfig class]]) {
        [themeType release];
        
        PFNoteConfig *noteConfig = (PFNoteConfig *) config;
        themeType = [noteConfig.themeType copy];
        
        [self updateProperty:PFNOTECONFIG_PROPERTY_GRID_TYPE to:config];
        [self updateProperty:PFNOTECONFIG_PROPERTY_GRID_COLOR_INDEX to:config];
        [self updateProperty:PFNOTECONFIG_PROPERTY_STROKE_TYPE to:config];
    }
}

-(void) setGridType:(NSString *)gridType {
    [self setProperty:gridType forKey:PFNOTECONFIG_PROPERTY_GRID_TYPE];
}

-(NSString *) getGridType {
    return [self getProperty:PFNOTECONFIG_PROPERTY_GRID_TYPE];
}

-(void) setStrokeType:(NSString *)strokeType {
    [self setProperty:strokeType forKey:PFNOTECONFIG_PROPERTY_STROKE_TYPE];
}

-(NSString *) getStrokeType {
    return [self getProperty:PFNOTECONFIG_PROPERTY_STROKE_TYPE];
}

-(void) setGridColorIndex:(NSInteger)gridColorIndex {
    NSString *value = [[NSNumber numberWithInt:gridColorIndex] stringValue];
    [self setProperty:value forKey:PFNOTECONFIG_PROPERTY_GRID_COLOR_INDEX];
}

-(NSInteger) getGridColorIndex {
    NSInteger result = 0;
    NSString *value = [self getProperty:PFNOTECONFIG_PROPERTY_GRID_COLOR_INDEX];
    if (value) {
        result = [value intValue];
    }
    return result;
}

@end

//
//  PFNoteConfig.h
//  PettyFunNote
//
//  Created by YJ Park on 11/9/10.
//  Copyright 2010 PettyFun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PFPageConfig.h"

extern NSString *const PFNOTECONFIG_THEME_TYPE;

extern NSString *const PFNOTECONFIG_PROPERTY_GRID_TYPE;
extern NSString *const PFNOTECONFIG_PROPERTY_GRID_COLOR_INDEX;

extern NSString *const PFNOTECONFIG_PROPERTY_STROKE_TYPE;

@interface PFNoteConfig : PFPageConfig {
    NSString *themeType;
}
@property (retain, nonatomic) NSString *themeType;

-(void) setGridType:(NSString *)gridType;
-(NSString *) getGridType;

-(void) setGridColorIndex:(NSInteger)gridColorIndex;
-(NSInteger) getGridColorIndex;

-(void) setStrokeType:(NSString *)strokeType;
-(NSString *) getStrokeType;

@end

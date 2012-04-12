//
//  PFPageViewConfig.h
//  PettyFunNote
//
//  Created by YJ Park on 11/9/10.
//  Copyright 2010 PettyFun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PFObject.h"

extern NSString *const PFPAGECONFIG_FACTOR;
extern NSString *const PFPAGECONFIG_MARGIN_LEFT;
extern NSString *const PFPAGECONFIG_MARGIN_RIGHT;
extern NSString *const PFPAGECONFIG_MARGIN_TOP;
extern NSString *const PFPAGECONFIG_MARGIN_BOTTOM;
extern NSString *const PFPAGECONFIG_MARGIN_PARAGRAPH;
extern NSString *const PFPAGECONFIG_MARGIN_LINE;
extern NSString *const PFPAGECONFIG_MARGIN_WORD;
extern NSString *const PFPAGECONFIG_SPACE_WIDTH;
extern NSString *const PFPAGECONFIG_PARAGRAPH_INDENT;

@interface PFPageConfig : PFObject {
    float factor;
    float marginLeft, marginRight;
    float marginTop, marginBottom;
    float marginParagraph, marginLine;
    float marginWord;
    float spaceWidth;
    float paragraphIndent;
    BOOL showingControlCharactors;
    BOOL showingWatermark;
}
@property float factor;
@property float marginLeft;
@property float marginRight;
@property float marginTop;
@property float marginBottom;
@property float marginParagraph;
@property float marginLine;
@property float marginWord;
@property float spaceWidth;
@property float paragraphIndent;
@property BOOL showingControlCharactors;
@property BOOL showingWatermark;

-(void) updateTo:(id) config;
-(void) updateProperty:(NSString *)key to:(id)config;
-(void) setToDefaultValues;

@end

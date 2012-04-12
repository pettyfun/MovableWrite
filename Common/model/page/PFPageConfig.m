//
//  PFPageViewConfig.m
//  PettyFunNote
//
//  Created by YJ Park on 11/9/10.
//  Copyright 2010 PettyFun. All rights reserved.
//

#import "PFPageConfig.h"

NSString *const PFPAGECONFIG_FACTOR = @"factor";
NSString *const PFPAGECONFIG_MARGIN_LEFT = @"margin.left";
NSString *const PFPAGECONFIG_MARGIN_RIGHT = @"margin.right";
NSString *const PFPAGECONFIG_MARGIN_TOP = @"margin.top";
NSString *const PFPAGECONFIG_MARGIN_BOTTOM = @"margin.bottom";
NSString *const PFPAGECONFIG_MARGIN_PARAGRAPH = @"margin.paragraph";
NSString *const PFPAGECONFIG_MARGIN_LINE = @"margin.line";
NSString *const PFPAGECONFIG_MARGIN_WORD = @"margin.word";
NSString *const PFPAGECONFIG_SPACE_WIDTH = @"space.width";
NSString *const PFPAGECONFIG_PARAGRAPH_INDENT = @"paragraph.indent";

@implementation PFPageConfig
@synthesize factor;
@synthesize marginLeft;
@synthesize marginRight;
@synthesize marginTop;
@synthesize marginBottom;
@synthesize marginParagraph;
@synthesize marginLine;
@synthesize marginWord;
@synthesize spaceWidth;
@synthesize paragraphIndent;
@synthesize showingControlCharactors;
@synthesize showingWatermark;

-(NSString *) getType {
    return @"com.pettyfun.bucket.view.base.PFPageConfig";
}

-(void) dealloc{
    [super dealloc];
}

-(void) onInit {
    [super onInit];
    [self setToDefaultValues];
}

-(void) onInitWithData:(NSDictionary *)data {
    [super onInitWithData:data];
    [self setToDefaultValues];
    PFOBJECT_GET_FLOAT(PFPAGECONFIG_FACTOR, factor)
    PFOBJECT_GET_FLOAT(PFPAGECONFIG_MARGIN_LEFT, marginLeft)
    PFOBJECT_GET_FLOAT(PFPAGECONFIG_MARGIN_RIGHT, marginRight)
    PFOBJECT_GET_FLOAT(PFPAGECONFIG_MARGIN_TOP, marginTop)
    PFOBJECT_GET_FLOAT(PFPAGECONFIG_MARGIN_BOTTOM, marginBottom)
    PFOBJECT_GET_FLOAT(PFPAGECONFIG_MARGIN_PARAGRAPH, marginParagraph)
    PFOBJECT_GET_FLOAT(PFPAGECONFIG_MARGIN_LINE, marginLine)
    PFOBJECT_GET_FLOAT(PFPAGECONFIG_MARGIN_WORD, marginWord)
    PFOBJECT_GET_FLOAT(PFPAGECONFIG_SPACE_WIDTH, spaceWidth)
    PFOBJECT_GET_FLOAT(PFPAGECONFIG_PARAGRAPH_INDENT, paragraphIndent)
}

-(void) onGetData:(NSMutableDictionary *)data {
    [super onGetData:data];
    PFOBJECT_SET_FLOAT(PFPAGECONFIG_FACTOR, factor)
    PFOBJECT_SET_FLOAT(PFPAGECONFIG_MARGIN_LEFT, marginLeft)
    PFOBJECT_SET_FLOAT(PFPAGECONFIG_MARGIN_RIGHT, marginRight)
    PFOBJECT_SET_FLOAT(PFPAGECONFIG_MARGIN_TOP, marginTop)
    PFOBJECT_SET_FLOAT(PFPAGECONFIG_MARGIN_BOTTOM, marginBottom)
    PFOBJECT_SET_FLOAT(PFPAGECONFIG_MARGIN_PARAGRAPH, marginParagraph)
    PFOBJECT_SET_FLOAT(PFPAGECONFIG_MARGIN_LINE, marginLine)
    PFOBJECT_SET_FLOAT(PFPAGECONFIG_MARGIN_WORD, marginWord)
    PFOBJECT_SET_FLOAT(PFPAGECONFIG_SPACE_WIDTH, spaceWidth)
    PFOBJECT_SET_FLOAT(PFPAGECONFIG_PARAGRAPH_INDENT, paragraphIndent)
}

#pragma mark -
#pragma mark Specific Methods

-(void) setToDefaultValues {
    DECLARE_PFUTILS
    factor = utils.iPadMode ? 40.0f : 24.0f;
    marginLeft = utils.iPadMode ? 20.0f : 8.0f;
    marginRight = utils.iPadMode ? 20.0f : 8.0f;
    marginTop = utils.iPadMode ? 20.0f : 4.0f;
    marginBottom = utils.iPadMode ? 20.0f : 4.0f;
    
    marginParagraph = 0.0f;
    marginLine = 0.25f;
    marginWord = 0.25f;    
    spaceWidth = 1.0f;
    paragraphIndent = 0.0f;
}

-(void) updateTo:(id) config {
    if ([[config class] isSubclassOfClass: [PFPageConfig class]]) {
        PFPageConfig *pageConfig = (PFPageConfig *) config;
        factor = pageConfig.factor;
        marginLeft = pageConfig.marginLeft;
        marginRight = pageConfig.marginRight;
        marginTop = pageConfig.marginTop;
        marginBottom = pageConfig.marginBottom;
        marginParagraph = pageConfig.marginParagraph;
        marginLine = pageConfig.marginLine;
        marginWord = pageConfig.marginWord;
        spaceWidth = pageConfig.spaceWidth;
        paragraphIndent = pageConfig.paragraphIndent;        
    }
}

-(void) updateProperty:(NSString *)key to:(id)config {
    if ([[config class] isSubclassOfClass: [PFPageConfig class]]) {
        PFPageConfig *pageConfig = (PFPageConfig *) config;
        NSString *value = [pageConfig getProperty:key];
        [self setProperty:value forKey:key];
    }
}


@end

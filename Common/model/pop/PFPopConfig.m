//
//  PFPopConfig.m
//  PettyFunPop
//
//  Created by YJ Park on 1/6/11.
//  Copyright 2011 PettyFun.com. All rights reserved.
//

#import "PFPopConfig.h"

NSString *const PFPOPCONFIG_FACTOR = @"factor";
NSString *const PFPOPCONFIG_WIDTH = @"width";
NSString *const PFPOPCONFIG_HEIGHT = @"height";

@implementation PFPopConfig
@synthesize factor;
@synthesize width;
@synthesize height;

-(NSString *) getType {
    return @"com.pettyfun.bucket.view.pop.PFPopConfig";
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
    PFOBJECT_GET_FLOAT(PFPOPCONFIG_FACTOR, factor)
    PFOBJECT_GET_FLOAT(PFPOPCONFIG_WIDTH, width)
    PFOBJECT_GET_FLOAT(PFPOPCONFIG_HEIGHT, height)
}

-(void) onGetData:(NSMutableDictionary *)data {
    [super onGetData:data];
    PFOBJECT_SET_FLOAT(PFPOPCONFIG_FACTOR, factor)
    PFOBJECT_SET_FLOAT(PFPOPCONFIG_WIDTH, width)
    PFOBJECT_SET_FLOAT(PFPOPCONFIG_HEIGHT, height)
}

#pragma mark -
#pragma mark Specific Methods

-(void) setToDefaultValues {
    factor = 1.0f;
    width = 320.0f;
    height = 480.0f;
}

-(void) updateTo:(id) config {
    if ([[config class] isSubclassOfClass: [PFPopConfig class]]) {
        PFPopConfig *popConfig = (PFPopConfig *) config;
        factor = popConfig.factor;
        width = popConfig.width;
        height = popConfig.height;
    }
}



@end

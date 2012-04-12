//
//  PFPopState.m
//  PettyFunPop
//
//  Created by YJ Park on 1/6/11.
//  Copyright 2011 PettyFun.com. All rights reserved.
//

#import "PFPopState.h"

NSString *const PFPOP_STATE_CELL = @"cell";

@implementation PFPopState
@synthesize cell;
-(NSString *) getType {
    return @"com.pettyfun.bucket.model.pop.PFPopState";
}

-(void) dealloc{
    [super dealloc];
}

-(void) onInit {
    [super onInit];    
    cell = 0;
}

-(void) onInitWithData:(NSDictionary *)data {
    [super onInitWithData:data];
    PFOBJECT_GET_INT(PFPOP_STATE_CELL, cell)
}

-(void) onGetData:(NSMutableDictionary *)data {
    [super onGetData:data];
    PFOBJECT_SET_INT(PFPOP_STATE_CELL, cell)
}

#pragma mark -
#pragma mark Specific Methods

@end

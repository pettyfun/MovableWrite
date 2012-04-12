//
//  PFItemType.m
//  PettyFunNote
//
//  Created by YJ Park on 11/14/10.
//  Copyright 2010 PettyFun. All rights reserved.
//

#import "PFItemType.h"

NSString *const PFITEM_TYPE_IDENTITY = @"identidy";
NSString *const PFITEM_TYPE_URL_SCHEMA = @"url_schema";
NSString *const PFITEM_TYPE_FILE_EXTENSION = @"file_extension";
NSString *const PFITEM_TYPE_VERSION = @"version";

@implementation PFItemType
@synthesize identity;
@synthesize urlSchema;
@synthesize fileExtension;
@synthesize version;

-(NSString *) getType {
    return @"com.pettyfun.bucket.model.item.PFItemType";
}

-(void) dealloc{
    [identity release];
    [urlSchema release];
    [fileExtension release];
    [super dealloc];
}

-(void) onInit {
    [super onInit];    
}

-(void) onInitWithData:(NSDictionary *)data {
    [super onInitWithData:data];
    PFOBJECT_GET_STRING(PFITEM_TYPE_IDENTITY, identity)
    PFOBJECT_GET_STRING(PFITEM_TYPE_URL_SCHEMA, urlSchema)
    PFOBJECT_GET_STRING(PFITEM_TYPE_FILE_EXTENSION, fileExtension)
    PFOBJECT_GET_STRING(PFITEM_TYPE_VERSION, version)
}

-(void) onGetData:(NSMutableDictionary *)data {
    [super onGetData:data];
    PFOBJECT_SET_STRING(PFITEM_TYPE_IDENTITY, identity)
    PFOBJECT_SET_STRING(PFITEM_TYPE_URL_SCHEMA, urlSchema)
    PFOBJECT_SET_STRING(PFITEM_TYPE_FILE_EXTENSION, fileExtension)
    PFOBJECT_SET_STRING(PFITEM_TYPE_VERSION, version)
}

#pragma mark -
#pragma mark Specific Methods

-(BOOL) isFileWithType:(NSString *)path {
    BOOL result = NO;
    if (path) {
        result = [path hasSuffix:fileExtension];
    }
    return result;
}

@end

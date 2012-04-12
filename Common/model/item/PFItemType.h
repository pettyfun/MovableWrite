//
//  PFItemType.h
//  PettyFunNote
//
//  Created by YJ Park on 11/14/10.
//  Copyright 2010 PettyFun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PFObject.h"

extern NSString *const PFITEM_TYPE_IDENTITY;
extern NSString *const PFITEM_TYPE_URL_SCHEMA;
extern NSString *const PFITEM_TYPE_FILE_EXTENSION;
extern NSString *const PFITEM_TYPE_VERSION;

@interface PFItemType : PFObject {
    NSString *identity;
    NSString *urlSchema;
    NSString *fileExtension;
    NSString *version;
}

@property (nonatomic, retain) NSString *identity;
@property (nonatomic, retain) NSString *urlSchema;
@property (nonatomic, retain) NSString *fileExtension;
@property (nonatomic, retain) NSString *version;

-(BOOL) isFileWithType:(NSString *)path;

@end

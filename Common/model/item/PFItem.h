//
//  PFItem.h
//  PettyFunNote
//
//  Created by YJ Park on 11/8/10.
//  Copyright 2010 PettyFun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PFObject.h"
#import "PFItemType.h"

extern NSString *const PFITEM_NAME;
extern NSString *const PFITEM_TYPE;
extern NSString *const PFITEM_STATUS;
extern NSString *const PFITEM_BUCKET_SIZE;
extern NSString *const PFITEM_REVISION;
extern NSString *const PFITEM_AUTHOR;
extern NSString *const PFITEM_CREATE_TIME;
extern NSString *const PFITEM_UPDATE_TIME;

#define PFITEM_DATA_FOLDER @"data"
#define PFITEM_BACKUP_FOLDER @"backup"
#define PFITEM_CACHE_FOLDER @"cache"

#define PFITEM_BACKUP_PREFIX @"backup"
#define PFITEM_OLD_PREFIX @"old"

#define PFITEM_DEFAULT_BUCKET_SIZE 16

@interface PFItem : PFObject {
    NSString *name;
    PFItemType *type;
    int status;
    int bucketSize;
    int revision;
    NSString *author;
    NSDate *createTime;
    NSDate *updateTime;
    
    //Specific value
    NSString *path;
}

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *author;
@property (nonatomic, readonly) PFItemType *type;
@property (nonatomic, readonly) NSString *path;

//Not supposed to be overrided
-(id) initFromPathAsJSON:(NSString *)itemPath;
-(id) initFromURLAsJSON:(NSURL *)itemURL;
-(void) saveAsJSON;

-(id) initFromPath:(NSString *)itemPath;
-(id) initFromURL:(NSURL *)itemURL;
-(void) save;

-(void) overridePath:(NSString *)newPath;
-(void) resetPath:(NSString *)subfolder;
-(BOOL) isInSubFolder:(NSString *)subfolder;

-(NSString *) getDefaultFolder;
-(NSString *) getCachePath;

//provided by subclasses
-(PFItemType *) getItemType;

@end

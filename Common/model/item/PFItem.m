//
//  PFItem.m
//  PettyFunNote
//
//  Created by YJ Park on 11/8/10.
//  Copyright 2010 PettyFun. All rights reserved.
//

#import "PFItem.h"
#import "ASIDataCompressor.h"
#import "ASIDataDecompressor.h"

NSString *const PFITEM_NAME = @"name";
NSString *const PFITEM_TYPE = @"type";
NSString *const PFITEM_STATUS = @"status";
NSString *const PFITEM_BUCKET_SIZE = @"bucket_size";
NSString *const PFITEM_REVISION = @"revision";
NSString *const PFITEM_AUTHOR = @"author";
NSString *const PFITEM_CREATE_TIME = @"create_time";
NSString *const PFITEM_UPDATE_TIME = @"update_time";

@implementation PFItem
@synthesize name;
@synthesize type;
@synthesize author;
@synthesize path;

-(NSString *) getType {
    return @"com.pettyfun.bucket.model.item.PFItem";
}

-(void) dealloc{
    [name release];
    [author release];
    [type release];
    [createTime release];
    [updateTime release];
    [path release];
    [super dealloc];
}

-(void) onInit {
    [super onInit];
    name = nil;
    type = [[self getItemType] retain];
    [self setProperty:type.version forKey:PFITEM_TYPE_VERSION];
    
    createTime = [[NSDate date] retain];
    author = nil;
    updateTime = nil;
    status = 0;
    bucketSize = PFITEM_DEFAULT_BUCKET_SIZE;
    revision = 0;
    [self resetPath:nil];
}

-(void) overridePath:(NSString *)newPath {
    if (path) {
        [path release];
    }
    path = [newPath retain];
}

-(void) resetPath:(NSString *)subfolder {
    DECLARE_PFUTILS
    NSString *folder = [utils getPathInDocument:[self getDefaultFolder]];
    [utils createPathIfNotExist:folder];    
    if (subfolder) {
        folder = [folder stringByAppendingPathComponent:subfolder];
        [utils createPathIfNotExist:folder];    
    }
    if (path) {
        [path release];
    }
    path = [[folder stringByAppendingPathComponent:
             [NSString stringWithFormat:@"%@.%@", [self getUUID], type.fileExtension]] retain];
}

-(BOOL) isInSubFolder:(NSString *)subfolder {
    DECLARE_PFUTILS
    NSString *folder = [utils getPathInDocument:[self getDefaultFolder]];
    if (subfolder) {
        folder = [folder stringByAppendingPathComponent:subfolder];
    }
    return [path hasPrefix:folder];
}

-(void) onInitWithData:(NSDictionary *)data {
    [super onInitWithData:data];
    type = [[self getItemType] retain];
    PFOBJECT_GET_STRING(PFITEM_NAME, name)
    PFOBJECT_GET_INT(PFITEM_STATUS, status)
    PFOBJECT_GET_INT(PFITEM_BUCKET_SIZE, bucketSize)
    PFOBJECT_GET_INT(PFITEM_REVISION, revision)
    PFOBJECT_GET_STRING(PFITEM_AUTHOR, author)
    PFOBJECT_GET_DATE(PFITEM_CREATE_TIME, createTime)
    PFOBJECT_GET_DATE(PFITEM_UPDATE_TIME, updateTime)
    [self resetPath:nil];
}

-(void) onGetData:(NSMutableDictionary *)data {
    [super onGetData:data];
    PFOBJECT_SET_STRING(PFITEM_NAME, name)
    PFOBJECT_SET_INT(PFITEM_STATUS, status)
    PFOBJECT_SET_INT(PFITEM_BUCKET_SIZE, bucketSize)
    PFOBJECT_SET_INT(PFITEM_REVISION, revision)
    PFOBJECT_SET_STRING(PFITEM_AUTHOR, author)
    PFOBJECT_SET_DATE(PFITEM_CREATE_TIME, createTime)
    PFOBJECT_SET_DATE(PFITEM_UPDATE_TIME, updateTime)
}

#pragma mark -
#pragma mark Specific Methods

-(NSString *) getCachePath {
    DECLARE_PFUTILS
    NSString *cacheFileName = [NSString stringWithFormat:@"cache_%@",
                               [path lastPathComponent]];
    NSString *destFolder = [utils getPathInDocument:PFITEM_CACHE_FOLDER];    
    NSString *cachePath = [destFolder stringByAppendingPathComponent:cacheFileName];
    return cachePath;
}

-(PFItemType *) getItemType {
    return [[[PFItemType alloc] init] autorelease];
}

-(NSString *) getDefaultFolder {
    return PFITEM_DATA_FOLDER;
}

//Not supposed to be overrided
-(id) initWithDataAsJSON:(NSData *)itemData {
    NSData *uncompressData = [ASIDataDecompressor uncompressData:itemData error:NULL];
    if (uncompressData.length == 0) {
        uncompressData = itemData;
    }
    NSString *str = [[[NSString alloc] initWithData:uncompressData encoding:NSUTF8StringEncoding] autorelease];
    DECLARE_PFUTILS
    NSDictionary *data = [utils jsonDecode:str];
    if ((self = [self initWithPFData:data])) {
    }
    return self;
}

-(id) initFromPathAsJSON:(NSString *)itemPath {
    NSData *itemData = [NSData dataWithContentsOfFile:itemPath];
    if ((self = [self initWithDataAsJSON:itemData])) {
        path = [itemPath retain];
    }
    return self;
}

-(id) initFromURLAsJSON:(NSURL *)itemURL {
    NSData *itemData = [NSData dataWithContentsOfURL:itemURL];
    if ((self = [self initWithDataAsJSON:itemData])) {
        [self resetUUID];
    }
    return self;
}

-(void) saveAsJSON {
    if (path) {
        if (updateTime) {
            [updateTime release];
        }
        updateTime = [[NSDate date] retain];
        revision += 1;
        NSDictionary *data = [self getData];

        DECLARE_PFUTILS
        [utils backupFile:path toFolderInDocument:PFITEM_BACKUP_FOLDER prefix:PFITEM_OLD_PREFIX];

        NSString *str = [utils jsonEncode:data];

        NSData *uncompressData = [str dataUsingEncoding:NSUTF8StringEncoding];
        NSData *itemData = [ASIDataCompressor compressData:uncompressData error:NULL];

        [itemData writeToFile:path atomically:YES];

        [utils backupFile:path toFolderInDocument:PFITEM_BACKUP_FOLDER prefix:PFITEM_BACKUP_PREFIX];
    }
}

-(id) initFromPath:(NSString *)itemPath {
    return [self initFromPathAsJSON:itemPath];
}

-(id) initFromURL:(NSURL *)itemURL {
    return [self initFromURLAsJSON:itemURL];
}

-(void) save {
    [self saveAsJSON];
}


@end

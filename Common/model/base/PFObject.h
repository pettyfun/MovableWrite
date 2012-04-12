//
//  PFObject.h
//  PettyFunNote
//
//  Created by YJ Park on 11/8/10.
//  Copyright 2010 pettyfun.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PFUtils.h"

extern NSString *const PFOBJECT_TYPE;
extern NSString *const PFOBJECT_UUID;
extern NSString *const PFOBJECT_PROPERTIES;

extern NSString *const PFOBJECT_EMPTY_STRING;

// For JSON DATA
#define PFOBJECT_GET_STRING(key, var) \
var = [[PFObject getObjectForKey:key type:[NSString class] data:data] retain];

#define PFOBJECT_GET_DATE(key, var) \
if ([data valueForKey:key]) { \
    var = [[NSDate dateWithTimeIntervalSince1970: \
            [[PFObject getObjectForKey:key type:[NSString class] data:data] doubleValue]] retain]; \
}

#define PFOBJECT_GET_INT(key, var) \
if ([data valueForKey:key]) { \
    var = [[PFObject getObjectForKey:key type:[NSString class] data:data] intValue]; \
}

#define PFOBJECT_GET_FLOAT(key, var) \
if ([data valueForKey:key]) { \
    var = [[PFObject getObjectForKey:key type:[NSString class] data:data] floatValue]; \
}

#define PFOBJECT_GET_RECT(key, var) \
if ([data valueForKey:key]) { \
    var = CGRectFromString([PFObject getObjectForKey:key type:[NSString class] data:data]); \
}

#define PFOBJECT_GET_OBJECT(key, var, object_type) \
var = [(object_type *)[PFObject getObjectForKey:key type:[object_type class] data:data] retain];

#define PFOBJECT_GET_DICTIONARY(key, var, object_type) \
var = [[PFObject getDictionaryForKey:key type:[object_type class] data:data] retain];

#define PFOBJECT_GET_ARRAY(key, var, object_type) \
var = [[PFObject getArrayForKey:key type:[object_type class] data:data] retain];

#define PFOBJECT_SET_INT(key, var) \
[PFObject setObject:[[NSNumber numberWithInt:var] stringValue] forKey:key data:data];

#define PFOBJECT_SET_DATE(key, var) \
[PFObject setObject:[[NSNumber numberWithDouble:[var timeIntervalSince1970]] stringValue] forKey:key data:data];

#define PFOBJECT_SET_FLOAT(key, var) \
[PFObject setObject:[[NSNumber numberWithFloat:var] stringValue] forKey:key data:data];

#define PFOBJECT_SET_FLOAT_2_DIGITS(key, var) \
[PFObject setObject:[NSString stringWithFormat:@"%.2f", var] forKey:key data:data];

#define PFOBJECT_SET_RECT(key, var) \
[PFObject setObject:NSStringFromCGRect(var) forKey:key data:data];

#define PFOBJECT_SET_STRING(key, var) \
[PFObject setObject:var forKey:key data:data];

#define PFOBJECT_SET_OBJECT(key, var) \
[PFObject setObject:var forKey:key data:data];

#define PFOBJECT_SET_DICTIONARY(key, var) \
[PFObject setDictionary:var forKey:key data:data];

#define PFOBJECT_SET_ARRAY(key, var) \
[PFObject setArray:var forKey:key data:data];

//PFString
#define PFSTRING_GET_FLOAT(var) \
    if (index < [items count]) { \
        var = [[items objectAtIndex:index] floatValue]; \
        index ++; \
    }

@interface PFObject : NSObject {
    NSString *uuid; //the universal identity, for link target, could be nil.
    NSMutableDictionary *properties;
}

//utility functions
+(NSObject *) getObject:(NSObject *)_var withType:(Class)type;
+(NSString *) getObjectForKey:(NSString *)key type:(Class)type data:(NSDictionary *)data;
+(NSMutableDictionary *) getDictionaryForKey:(NSString *)key type:(Class)type data:(NSDictionary *)data;
+(NSMutableArray *) getArrayForKey:(NSString *)key type:(Class)type data:(NSDictionary *)data;

+(NSObject *) getValue:var;
+(void) setObject:(NSObject *)var forKey:(NSString *)key data:(NSDictionary *)data;
+(void) setDictionary:(NSDictionary *)var forKey:(NSString *)key data:(NSDictionary *)data;
+(void) setArray:(NSArray *)var forKey:(NSString *)key data:(NSDictionary *)data;

//not supposed to be overrided
-(id) copyWithZone:(NSZone *)zone;
-(id) init;
-(id) initWithPFData:(NSDictionary *)data;
-(NSString *) getUUID;
-(NSString *) resetUUID;
-(NSString *) getProperty:(NSString *)key;
-(void) setProperty:(NSString *)value forKey:(NSString *)key;
-(id) getData;

-(id) getValue;
-(id) initWithValue:(id)value;

//provided by subclasses
-(NSString *) getType;
-(void) onInit;
-(void) onInitWithData:(NSDictionary *)data;
-(void) onGetData:(NSMutableDictionary *)data;

//default will not support this, override in subclass for 
//small class with massive number
-(NSString *) getString;
-(id) initWithScanner:(NSScanner *)scanner;

/* Standard subclass pattern
 extern NSString *const PF;
 
 -(NSString *) getType {
     return @"com.pettyfun.bucket.model.";
 }
 
 -(void) dealloc{
     [super dealloc];
 }
 
 -(void) onInit {
     [super onInit];    
 }
 
 -(void) onInitWithData:(NSDictionary *)data {
     [super onInitWithData:data];
 }
 
 -(void) onGetData:(NSMutableDictionary *)data {
     [super onGetData:data];
 }
 
 #pragma mark -
 #pragma mark Specific Methods
  
*/ 
 
@end

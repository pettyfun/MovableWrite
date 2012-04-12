//
//  PFObject.m
//  PettyFunNote
//
//  Created by YJ Park on 11/8/10.
//  Copyright 2010 pettyfun.com. All rights reserved.
//

#import "PFObject.h"

NSString *const PFOBJECT_TYPE = @"type";
NSString *const PFOBJECT_UUID = @"uuid";
NSString *const PFOBJECT_PROPERTIES = @"properties";

@implementation PFObject

+(NSObject *) getObject:(NSObject *)_var withType:(Class)type {
    NSObject *var = _var;
    if (type && [[type class] isSubclassOfClass: [PFObject class]]) {
        var = [[[type alloc] initWithValue:_var] autorelease];
    }
    return var;
}

+(NSObject *) getObjectForKey:(NSString *)key type:(Class)type data:(NSDictionary *)data {
    NSObject *var = [PFObject getObject:[data valueForKey:key] withType:type];
    return var;
}

+(NSMutableDictionary *) getDictionaryForKey:(NSString *)key type:(Class)type data:(NSDictionary *)data {
    NSMutableDictionary *var = [[[NSMutableDictionary alloc] init] autorelease];
    NSDictionary *_var = [data valueForKey:key];
    if (_var) {
        for (NSString *oneKey in [_var allKeys]) {
            NSObject *oneValue = [PFObject getObjectForKey:oneKey type:type data:_var];
            [var setValue:oneValue forKey:oneKey];
        }
    }
    return var;
}

+(NSMutableArray *) getArrayForKey:(NSString *)key type:(Class)type data:(NSDictionary *)data {
    NSMutableArray *var = [[[NSMutableArray alloc] init] autorelease];
    id _var = [data valueForKey:key];
    if (_var && [[_var class] isSubclassOfClass: [NSArray class]]) {
        for (NSObject *_oneValue in (NSArray *)_var) {
            NSObject *oneValue = [PFObject getObject:_oneValue withType:type];
            [var addObject:oneValue];
        }
    } else if ((_var && [[_var class] isSubclassOfClass: [NSString class]]) && 
               (type && [[type class] isSubclassOfClass: [PFObject class]])) {
        NSScanner *scanner = [NSScanner scannerWithString:(NSString *)_var];
        while (![scanner isAtEnd]) {    
            NSObject *oneValue = [[[type alloc] initWithScanner:scanner] autorelease];
            [var addObject:oneValue];
        }
    }
    
    return var;
}

+(NSObject *) getValue:var {
    NSObject *data = nil;
    if ([[var class] isSubclassOfClass: [PFObject class]]) {
        data = [var getValue];
    } else {
        data = var;
    }
    return data;
}

+(void) setObject:(NSObject *)var forKey:(NSString *)key data:(NSDictionary *)data {
    if (var) {
        [data setValue:[PFObject getValue:var] forKey:key];
    }
}

+(void) setDictionary:(NSDictionary *)var forKey:(NSString *)key data:(NSDictionary *)data {
    if (var && ([var count] > 0)) {
        NSMutableDictionary *_var = [NSMutableDictionary dictionaryWithCapacity:[var count]];
        for (NSString *oneKey in [var allKeys]) {
            NSObject *oneValue = [var valueForKey:oneKey];
            [PFObject setObject:oneValue forKey:oneKey data:_var];
        }
        [data setValue:_var forKey:key];
    }    
}

+(void) setArray:(NSArray *)var forKey:(NSString *)key data:(NSDictionary *)data {
    if (var && ([var count] > 0)) {
        NSMutableArray *_var = [NSMutableArray arrayWithCapacity:[var count]];
        BOOL needToPack = YES;
        for (NSObject *oneValue in var) {
            id _oneValue = [PFObject getValue:oneValue];
            [_var addObject:_oneValue];
            if ((![[oneValue class] isSubclassOfClass: [PFObject class]]) ||
                (![[_oneValue class] isSubclassOfClass: [NSString class]])) {
                needToPack = NO;
            }
        }
        if (needToPack) {
            [data setValue:[_var componentsJoinedByString:@""] forKey:key];
        } else {
            [data setValue:_var forKey:key];
        }
    }    
}


-(void) dealloc{
    [uuid release];
    [properties release];
    [super dealloc];
}

-(NSString *)getUUID {
    if (!uuid) {
        // create a new UUID which you own
        CFUUIDRef _uuid = CFUUIDCreate(kCFAllocatorDefault);
        // create a new CFStringRef (toll-free bridged to NSString)
        // that you own
        uuid = (NSString *)CFUUIDCreateString(kCFAllocatorDefault, _uuid);
        // release the UUID
        CFRelease(_uuid);    
    }
    return uuid;
}

-(NSString *) resetUUID {
    [uuid release];
    uuid = nil;
    return [self getUUID];    
}

-(NSString *) getProperty:(NSString *)key {
    if (!properties) {
        return nil;
    }
    return (NSString *)[properties valueForKey:key];
}

-(void) setProperty:(NSString *)value forKey:(NSString *)key {
    if (!properties) {
        properties = [[NSMutableDictionary alloc] init];
    }
    [properties setValue:value forKey:key];
}

-(id) init {
    if ((self = [super init])) {
        uuid = nil;
        properties = nil;
        [self onInit];
    }
    return self;
}

-(id) initWithPFData:(NSDictionary *)data {
    if ((self = [super init])) {
        PFOBJECT_GET_STRING(PFOBJECT_UUID, uuid)
        PFOBJECT_GET_DICTIONARY(PFOBJECT_PROPERTIES, properties, NSString)
        [self onInitWithData: data];
    }
    return self;
}

-(id) getData {
    NSMutableDictionary *data = [NSMutableDictionary dictionary];
    //[data setValue:[self getType] forKey:PFOBJECT_TYPE]; 
    PFOBJECT_SET_STRING(PFOBJECT_UUID, uuid)
    PFOBJECT_SET_DICTIONARY(PFOBJECT_PROPERTIES, properties)
    [self onGetData:data];
    return data;
}

-(id)copyWithZone:(NSZone *)zone {
    id value = [self getValue];
    id result = [[[self class] alloc] initWithValue:value];
    return result;
}

-(id)getValue {
    NSString *string = [self getString];
    if (string) {
        return string;
    }
    return [self getData];
}

-(id)initWithValue:(id)value {
    if ([[value class] isSubclassOfClass: [NSString class]]) {
        NSScanner *scanner = [NSScanner scannerWithString:(NSString *)value];
        return [self initWithScanner:scanner];
    }
    return [self initWithPFData:(NSDictionary *)value];
}

-(NSString *) getType {
    return @"com.pettyfun.bucket.model.base.PFObject";
}

-(void) onInit {
}

-(void) onInitWithData:(NSDictionary *)data {
}

-(void) onGetData:(NSMutableDictionary *)data {
}

-(NSString *) getString {
    return nil;
}

-(id) initWithScanner:(NSScanner *)scanner {
    return nil;
}

@end

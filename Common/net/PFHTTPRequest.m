//
//  PFHTTPAccessor.h
//  PettyFunNote
//
//  Created by YJ Park on 11/9/10.
//  Copyright 2010 PettyFun. All rights reserved.
//


#import "PFHTTPRequest.h"
#import "PFUtils.h"

@implementation PFHTTPRequest
@synthesize url;
@synthesize isPost;
@synthesize headers;
@synthesize postData;
@synthesize tag;
@synthesize delegate;

NSString* const PFHTTPRequestErrorDomain = @"PFHTTPRequestErrorDomain";
NSString* const PFHTTPRequestErrorUserInfoData = @"data";

+ (PFHTTPRequest *)requestWithURL:(NSURL *)requestUrl {
    return [[[PFHTTPRequest alloc] initWithURL:requestUrl] autorelease];
}

- (id)initWithURL:(NSURL *)requestUrl {
    if ((self = [super init])) {
        url = [requestUrl retain];
        headers = [[NSMutableDictionary alloc] init];
        postData = nil;
        isPost = NO;
    }
    return self;
}

- (void) dealloc {
    [url release];
    [headers release];
    [postData release];
    [super dealloc];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@ %@ [%@]\nheaders = %@ ",
            [self class], url, isPost ? @"POST" : @"GET", headers];
}

- (void)addRequestHeader:(NSString *)header value:(NSString *)value {
    [headers setValue:value forKey:header];
}

- (void)appendPostData:(NSData *)data {
    if (postData == nil) {
        postData = [[NSMutableData alloc] init];
        isPost = YES;
    }
    [postData appendData:data];
}

//Deal with response or error (called by accessor)
- (void)succeedWithStatusCode:(NSInteger)code data:(NSData *)data {  
    if (delegate && ([delegate respondsToSelector:@selector(requestDidSucceed:response:)])) {
        PFHTTPResponse *response = [PFHTTPResponse responseWithStatusCode:code data:data]; 
        [delegate requestDidSucceed:self response:response];
    }
}

// alerts that the request was cancelled safely
- (void)cancel {
    if (delegate && ([delegate respondsToSelector:@selector(requestDidCancel:)])) {
        [delegate requestDidCancel:self];
    }
}

- (void)failWithError:(NSError *)error {
    PFLog(@"failWithError: %@, %@", error, self);
    if (delegate && ([delegate respondsToSelector:@selector(requestDidFail:error:)])) {
        [delegate requestDidFail:self error:error];
    }
}

- (void)failWithStatusCode:(NSInteger)code data:(NSData *)data {
    NSDictionary *userInfo = nil;
    @try {
        NSString *responseString = [[[NSString alloc] initWithData:data
                                                          encoding:NSUTF8StringEncoding]
                                    autorelease];    
        userInfo = [NSDictionary dictionaryWithObject:responseString
                                               forKey:PFHTTPRequestErrorUserInfoData];
    }
    @catch (NSException * e) {
        userInfo = [NSDictionary dictionaryWithObject:data
                                               forKey:PFHTTPRequestErrorUserInfoData];
        PFLog(@"utf8 encoding failed: %@, %@", data, e);
    }
    NSError *error = [NSError errorWithDomain:PFHTTPRequestErrorDomain
                                         code:code
                                     userInfo:userInfo];
    [self failWithError:error];
}

@end
                                    
@implementation PFHTTPResponse
@synthesize statusCode;
@synthesize responseData;
+ (PFHTTPResponse *)responseWithStatusCode:(NSInteger)code data:(NSData *)data {
    return [[[PFHTTPResponse alloc] initWithStatusCode:code data:data] autorelease];
}

- (id)initWithStatusCode:(NSInteger)code data:(NSData *)data {
    if ((self = [super init])) {
        statusCode = code;
        responseData = [data retain];
    }
    return self;
}

- (void)dealloc {
    [responseData release];
    [super dealloc];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@ statusCode = %d data's length = %d",
            [self class], statusCode, [responseData length]];
}

- (NSString *)responseString {
    @try {
        NSString *responseString = [[[NSString alloc] initWithData:responseData
                                                          encoding:NSUTF8StringEncoding]
                                    autorelease];
        return responseString;
    }
    @catch (NSException * e) {
        PFLog(@"utf8 encoding failed: %@, %@", responseData, e);
    }
    return @"Error to get responseString";
}

@end

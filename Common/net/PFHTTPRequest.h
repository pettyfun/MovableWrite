//
//  PFHTTPAccessor.h
//  PettyFunNote
//
//  Created by YJ Park on 11/9/10.
//  Copyright 2010 PettyFun. All rights reserved.
//


#import <Foundation/Foundation.h>

extern NSString* const PFHTTPRequestErrorDomain;
extern NSString* const PFHTTPRequestErrorUserInfoData;

@interface PFHTTPRequest : NSObject {
  @protected
    NSURL *url;
    BOOL isPost;
    NSMutableDictionary *headers;
    NSMutableData *postData;
    int tag;
    id delegate;
}
@property (readonly, nonatomic) NSURL *url;
@property (readonly, nonatomic) NSDictionary *headers;
@property (readonly, nonatomic) NSMutableData *postData;
@property (assign, nonatomic) BOOL isPost;
@property (assign, nonatomic) int tag;
@property (assign, nonatomic) id delegate;

+ (PFHTTPRequest *)requestWithURL:(NSURL *)requestUrl;
- (id)initWithURL:(NSURL *)requestUrl;
- (void)addRequestHeader:(NSString *)header value:(NSString *)value;
- (void)appendPostData:(NSData *)data;

//Deal with response or error (called by accessor)
- (void)succeedWithStatusCode:(NSInteger)code data:(NSData *)data;
- (void)failWithError:(NSError *)error;
- (void)cancel;

- (void)failWithStatusCode:(NSInteger)code data:(NSData *)data;
@end

@interface PFHTTPResponse : NSObject {
  @protected
    NSInteger statusCode;
    NSData *responseData;
}
@property (readonly, nonatomic) NSInteger statusCode;
@property (readonly, nonatomic) NSData *responseData;
+ (PFHTTPResponse *)responseWithStatusCode:(NSInteger)code data:(NSData *)data;
- (id)initWithStatusCode:(NSInteger)code data:(NSData *)data;
- (NSString *)responseString;
@end

@protocol PFHTTPRequestDelegate <NSObject>
@required
- (void)requestDidSucceed:(PFHTTPRequest *)request
                 response:(PFHTTPResponse *)response;
@optional
- (void)requestDidFail:(PFHTTPRequest *)request
                 error:(NSError *)error;
- (void)requestDidCancel:(PFHTTPRequest *)request;
@end


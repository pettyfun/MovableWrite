//
//  PFHTTPAccessor.h
//  PettyFunNote
//
//  Created by YJ Park on 11/9/10.
//  Copyright 2010 PettyFun. All rights reserved.
//

#import "PFHTTPAccessor.h"
#import "PFUtils.h"

NSInteger const PF_HTTP_ACCESSOR_TIMEOUT;

NSString* const PF_HTTP_ACCESSOR_REQUEST = @"request";

@implementation PFHTTPAccessor

- (id)init {
    if ((self = [super init])) {
        asiRequests = [[NSMutableSet alloc] init];
    }
    return self;
}

- (void)dealloc {
    [asiRequests release];
    [super dealloc];
}

- (void)accessAsynchronous:(PFHTTPRequest *)request {
    ASIHTTPRequest *asiRequest = [ASIHTTPRequest requestWithURL:request.url];
    [asiRequest setDelegate:self];
    asiRequest.userInfo = [NSDictionary dictionaryWithObject:request forKey:PF_HTTP_ACCESSOR_REQUEST];

    [asiRequest setTimeOutSeconds:PF_HTTP_ACCESSOR_TIMEOUT];

    /*
     If there are issues hitting their server, it redirPFts to a Comcast search 
     page (Comcast is a popular ISP in the US).  The search page will return a
     200 code, but our code won't know what to do with the response.  Maybe
     better if we just fail if we see a code for redirPFt? their webservice
     shouldn't be redirPFting (on purpose) anyway...
    */
    asiRequest.shouldRedirect = NO;
    
    [asiRequest setRequestMethod: (request.isPost ? @"POST" : @"GET")];
    for (NSString *headerKey in [request.headers allKeys]) {
        [asiRequest addRequestHeader:headerKey value:[request.headers valueForKey:headerKey]];
    }
    [asiRequest setPostBody:request.postData];
    @synchronized(asiRequests) {
        [asiRequests addObject:asiRequest];
    }
    [asiRequest startAsynchronous];
}

- (void)requestFinished:(ASIHTTPRequest *)asiRequest {
    PFHTTPRequest *request = (PFHTTPRequest *)[asiRequest.userInfo
                                               objectForKey:PF_HTTP_ACCESSOR_REQUEST];
    PFLog(@"requestFinished: %@, %@", asiRequest.responseStatusMessage, request);    
    [request succeedWithStatusCode:asiRequest.responseStatusCode
                              data:[asiRequest responseData]];
    @synchronized(asiRequests) {
        [asiRequests removeObject:asiRequest];
    }
}

- (void)requestFailed:(ASIHTTPRequest *)asiRequest {
    PFHTTPRequest *request = (PFHTTPRequest *)[asiRequest.userInfo
                                               objectForKey:PF_HTTP_ACCESSOR_REQUEST];
    PFLog(@"requestFailed: %@, %@", asiRequest.error, request);    
    [request failWithError:asiRequest.error];
    @synchronized(asiRequests) {
        [asiRequests removeObject:asiRequest];
    }
}

- (void)cancelAllRequests {
    @synchronized(asiRequests) {
        for (ASIHTTPRequest *asiRequest in asiRequests) {
            [asiRequest clearDelegatesAndCancel];
            PFHTTPRequest *request = (PFHTTPRequest *)[asiRequest.userInfo
                                                       objectForKey:PF_HTTP_ACCESSOR_REQUEST];
            PFLog(@"requestCanceled: %@, %@", asiRequest.error, request);
            [request cancel];
        }
        [asiRequests removeAllObjects];
    }
}

@end

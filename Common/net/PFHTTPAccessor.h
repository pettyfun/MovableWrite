//
//  PFHTTPAccessor.h
//  PettyFunNote
//
//  Created by YJ Park on 11/9/10.
//  Copyright 2010 PettyFun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"
#import "PFHTTPRequest.h"

extern NSInteger const PF_HTTP_ACCESSOR_TIMEOUT;

extern NSString* const PF_HTTP_ACCESSOR_REQUEST;

@interface PFHTTPAccessor : NSObject<ASIHTTPRequestDelegate> {
  @private
    NSMutableSet *asiRequests;
}

- (void)accessAsynchronous:(PFHTTPRequest *)request;

- (void)cancelAllRequests;

@end

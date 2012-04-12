//
//  PFPopConfig.h
//  PettyFunPop
//
//  Created by YJ Park on 1/6/11.
//  Copyright 2011 PettyFun.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PFObject.h"

@interface PFPopConfig : PFObject {
    float factor, width, height;
}
@property (assign, nonatomic) float factor, width, height;

-(void) updateTo:(id) config;
-(void) setToDefaultValues;

@end

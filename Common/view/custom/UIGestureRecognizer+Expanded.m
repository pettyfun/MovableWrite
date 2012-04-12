//
//  UIGestureRecognizer+Expanded.m
//  PettyFunNote
//
//  Created by YJ Park on 2/23/11.
//  Copyright 2011 PettyFun.com. All rights reserved.
//

#import "UIGestureRecognizer+Expanded.h"


@implementation UIGestureRecognizer (UIGestureRecognizer_Expanded)

- (void)pf_cancel {
    self.enabled = NO;
    self.enabled = YES;
}
@end
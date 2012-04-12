//
//  PFToolBar.m
//  PettyFunNote
//
//  Created by YJ Park on 1/27/11.
//  Copyright 2011 PettyFun.com. All rights reserved.
//

#import "PFToolBar.h"


@implementation PFToolBar
@synthesize transparent;
@synthesize backgroundImage;

- (void)dealloc {
    [backgroundImage release];
    [super dealloc];
}

- (void)drawRect:(CGRect)rect {
    if (backgroundImage) {
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSaveGState(context);
        CGContextTranslateCTM(context, 0.0f, self.frame.size.height);
        CGContextScaleCTM(context, 1.0f, -1.0f);
        CGContextDrawImage(context, rect, backgroundImage.CGImage);
        CGContextRestoreGState(context);
    } else {
        if (!transparent) {
            [super drawRect:rect];
        }
    }
}

@end

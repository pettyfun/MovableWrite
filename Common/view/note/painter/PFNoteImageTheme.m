//
//  PFNoteImageTheme.m
//  PettyFunNote
//
//  Created by YJ Park on 12/16/10.
//  Copyright 2010 PettyFun. All rights reserved.
//

#import "PFNoteImageTheme.h"


@implementation PFNoteImageTheme

-(id) initWithFile:(NSString *)imageFileName {
    if ((self = [super init])) {
        fileName = [imageFileName retain];
    }
    return self;
}

-(void) dealloc {
    [fileName release];
    [_image release];
    [super dealloc];
}

-(UIImage *) getImage {
    if (!_image) {
        _image = [[UIImage imageWithContentsOfFile:
                   [[NSBundle mainBundle] 
                    pathForResource:fileName 
                    ofType:nil]] retain];
    }
    return _image;
}

-(UIColor *) getBackgroundColor {
    UIImage *image = [self getImage];
    return [UIColor colorWithPatternImage:image];
}

-(void) paintEmptyPageOnContext:(CGContextRef)context 
                     withConfig:(PFPageConfig *)config 
                         inRect:(CGRect)rect
                       viewRect:(CGRect)viewRect {
    //CGContextClipToRect(context, rect);
    UIImage *image = [self getImage];
    float x = viewRect.origin.x;
    float y = viewRect.origin.y;
    while (y < viewRect.size.height) {
        while (x < viewRect.size.width) {
            CGRect imageRect = CGRectMake(x,
                                          y,
                                          image.size.width,
                                          image.size.height);
            if (CGRectIntersectsRect(rect, imageRect)) {
                CGContextDrawImage(context, imageRect, image.CGImage);
            }
            x += image.size.width;
        }
        y += image.size.height;
        x = viewRect.origin.x;
    }    
}

@end

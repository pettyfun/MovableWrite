//
//  PFNotePageNumberView.m
//  PettyFunNote
//
//  Created by YJ Park on 2/12/11.
//  Copyright 2011 PettyFun.com. All rights reserved.
//

#import "PFNotePageNumberView.h"


@implementation PFNotePageNumberView
@synthesize theme;
@synthesize currentPageNumber;
@synthesize totalPageNumber;

- (id)initWithFrame:(CGRect)frame {
    CGRect viewFrame = CGRectMake(
                           (int)((frame.size.width - PFNotePageNumberViewWidth) / 2.0f),
                           0.0f,
                           PFNotePageNumberViewWidth,
                           frame.size.height);
    self = [super initWithFrame:viewFrame];
    if (self) {
        // Initialization code.
        self.backgroundColor = [UIColor clearColor];
        //self.userInteractionEnabled = NO;
    }
    return self;
}

- (void)updateWithFrame:(CGRect)frame {
    CGRect viewFrame = CGRectMake(
                                  (int)((frame.size.width - PFNotePageNumberViewWidth) / 2.0f),
                                  0.0f,
                                  PFNotePageNumberViewWidth,
                                  frame.size.height);
    self.frame = viewFrame;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    if (totalPageNumber <= 0) return;
    
    CGContextRef context = UIGraphicsGetCurrentContext();

    CGContextSaveGState(context);
    CGContextTranslateCTM(context, 0.0f, self.frame.size.height);
    CGContextScaleCTM(context, 1.0f, -1.0f);
    float offset = [self drawMiddleOn:context];
    [self drawCurrentOn:context offset:(self.frame.size.width - offset) / 2.0f];
    [self drawTotalOn:context offset:(self.frame.size.width + offset) / 2.0f];
    CGContextRestoreGState(context);
}

- (float)drawMiddleOn:(CGContextRef)context {
    UIImage *image = [theme getImage:PFNoteThemeImagePageNumberMiddle];
    return [self drawImage:image on:context
                    offset:self.frame.size.width / 2.0f
                      mode:PFNotePageNumberViewModeMiddle];
}

- (float) drawImage:(UIImage *)image on:(CGContextRef)context
             offset:(float)offset mode:(PFNotePageNumberViewMode)mode {
    float result = 0.0f;
    if (image) {
        result = image.size.width;
        int x = offset;
        if (mode == PFNotePageNumberViewModeMiddle) {
            x = offset - image.size.width / 2.0f;
        } else if (mode == PFNotePageNumberViewModeRight) {
            x = offset - image.size.width;
        }
        CGRect rect = CGRectMake(
                          x,
                          (self.frame.size.height - image.size.height) / 2.0f,
                          image.size.width, image.size.height
                          );
        
        CGContextDrawImage(context, rect, image.CGImage);
    }
    return result;
}

- (UIImage *)getDigitImage:(int)digit {
    if ((digit >= 0) && (digit < 10)) {
        return [theme getImage:PFNoteThemeImagePageNumber0 + digit];
    }
    return nil;
}

- (void)drawCurrentOn:(CGContextRef)context offset:(float)offset {
    int number = currentPageNumber + 1;
    float right = offset;
    while (number > 0) {
        int digit = number % 10;
        number = number / 10;
        UIImage *image = [self getDigitImage:digit];
        right -= [self drawImage:image on:context offset:right
                            mode:PFNotePageNumberViewModeRight];
    }
    UIImage *image = [theme getImage:PFNoteThemeImagePageNumberLeft];
    [self drawImage:image on:context offset:right
               mode:PFNotePageNumberViewModeRight];
}

- (void)drawTotalOn:(CGContextRef)context offset:(float)offset {
    int number = totalPageNumber;
    float left = offset;
    NSMutableArray *digits = [[[NSMutableArray alloc] init] autorelease];
    while (number > 0) {
        int digit = number % 10;
        number = number / 10;
        [digits addObject:[NSNumber numberWithInt:digit]];
    }
    for (NSNumber *digit in [digits reverseObjectEnumerator]) {
        UIImage *image = [self getDigitImage:[digit intValue]];
        left += [self drawImage:image on:context offset:left
                           mode:PFNotePageNumberViewModeLeft];
    }
    UIImage *image = [theme getImage:PFNoteThemeImagePageNumberRight];
    [self drawImage:image on:context offset:left
               mode:PFNotePageNumberViewModeLeft];
}

- (void)dealloc {
    [super dealloc];
}


@end

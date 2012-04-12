//
//  PFNotePageNumberView.h
//  PettyFunNote
//
//  Created by YJ Park on 2/12/11.
//  Copyright 2011 PettyFun.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PFNoteTheme.h"

#define PFNotePageNumberViewWidth ([PFUtils getInstance].iPadMode ? 250.0f : 140.0f)

typedef enum {
	PFNotePageNumberViewModeLeft,
    PFNotePageNumberViewModeMiddle,
    PFNotePageNumberViewModeRight
} PFNotePageNumberViewMode;

@interface PFNotePageNumberView : UIButton {
    PFNoteTheme *theme;
    int currentPageNumber;
    int totalPageNumber;
}
@property (nonatomic, retain) PFNoteTheme *theme;
@property int currentPageNumber;
@property int totalPageNumber;

- (float)drawMiddleOn:(CGContextRef)context;
- (void)drawCurrentOn:(CGContextRef)context offset:(float)offset;
- (void)drawTotalOn:(CGContextRef)context offset:(float)offset;

- (float) drawImage:(UIImage *)image on:(CGContextRef)context
             offset:(float)offset mode:(PFNotePageNumberViewMode)mode;

- (void)updateWithFrame:(CGRect)frame;

@end

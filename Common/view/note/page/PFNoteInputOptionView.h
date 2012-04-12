//
//  PFNoteInputOptionView.h
//  PettyFunNote
//
//  Created by YJ Park on 2/24/11.
//  Copyright 2011 PettyFun.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PFNoteTheme.h"
#import "PFNoteCell.h"
#import "PFNoteConfig.h"
#import "PFNoteCellPainter.h"

#define PFNoteInputOptionViewHistorySize 4

@interface PFNoteInputOptionView : UIButton {
    PFNoteTheme *theme;
    int colorIndex;
    int lineWidthIndex;    
    //Internal objects
    PFNoteCell *cell;
    PFNoteConfig *config;
    PFNoteCellPainter *painter;
    NSMutableArray *history;
}
@property (nonatomic, retain) PFNoteTheme *theme;
@property (nonatomic, retain) PFNoteConfig *config;
@property (nonatomic, retain) PFNoteCellPainter *painter;
@property int colorIndex;
@property int lineWidthIndex;

- (void) refreshConfig;

- (void)pushCurrentValues;
- (BOOL)circleCurrentValues;

//internal methods
- (void)createStrokes;
- (void)updateStrokes;

- (NSString *)encodeValues;
- (void)decodeValues:(NSString *)values;

@end

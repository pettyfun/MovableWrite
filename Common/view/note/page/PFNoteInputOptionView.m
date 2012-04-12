//
//  PFNoteInputOptionView.m
//  PettyFunNote
//
//  Created by YJ Park on 2/24/11.
//  Copyright 2011 PettyFun.com. All rights reserved.
//

#import "PFNoteInputOptionView.h"
#import "PFNotePainterFactory.h"
#import "PFNoteStroke.h"

@implementation PFNoteInputOptionView
@synthesize theme;
@synthesize config;
@synthesize painter;
@synthesize colorIndex;
@synthesize lineWidthIndex;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code.
        self.backgroundColor = [UIColor clearColor];
        //self.userInteractionEnabled = NO;
        
        // Create cell for painting;
        cell = [[PFNoteCell alloc] initWithType:PFNOTE_CELL_TYPE_WORD];
        cell.width = frame.size.width / frame.size.height;
        [cell setRect:CGRectMake(0.0f, 0.0f, frame.size.width, frame.size.height)];
        [self createStrokes];
        config = [[PFNoteConfig alloc] init];
        config.factor = frame.size.height;
        config.marginWord = 0.0f;
        painter = [[PFNoteCellPainter alloc] init];
        DECLARE_PFNOTE_PAINTER_FACTORY
        painter.strokePainter = [painterFactory getStrokePainter:config];
        
        history = [[NSMutableArray alloc] initWithCapacity:PFNoteInputOptionViewHistorySize + 1];
        colorIndex = 1;
        lineWidthIndex = 1;
        [self pushCurrentValues];
        colorIndex = 0;
        lineWidthIndex = 0;
        [self pushCurrentValues];        
    }
    return self;
}

- (void)dealloc {
    [theme release];
    [config release];
    [cell release];
    [config release];
    [painter release];
    [history release];
    [super dealloc];
}

-(void) refreshConfig {
    DECLARE_PFNOTE_PAINTER_FACTORY
    painter.strokePainter = [painterFactory getStrokePainter:config];
}

- (void)createStrokes {
    PFNoteStroke *stroke = [[[PFNoteStroke alloc] init] autorelease];
    [stroke setColorIndex:colorIndex];
    [stroke setLineWidthIndex:lineWidthIndex];
    [cell addStroke:stroke];
    CGPoint start = CGPointMake(0.1f, 0.5f);
    [stroke startStroke:start withPressure:PFNOTE_POINT_PRESSURE_DEFAULT];
    CGPoint pos = CGPointMake(cell.width * 0.3f, 0.3f);
    [stroke addPoint:pos withPressure:PFNOTE_POINT_PRESSURE_DEFAULT];
    pos = CGPointMake(cell.width * 0.5f, 0.7f);
    [stroke addPoint:pos withPressure:PFNOTE_POINT_PRESSURE_DEFAULT];
    pos = CGPointMake(cell.width * 0.9f, 0.4f);
    [stroke addPoint:pos withPressure:PFNOTE_POINT_PRESSURE_DEFAULT];
}

- (void)updateStrokes {
    for (PFNoteStroke *stroke in cell.strokes) {
        [stroke setColorIndex:colorIndex];
        [stroke setLineWidthIndex:lineWidthIndex];
    }
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    [self updateStrokes];
    CGContextRef context = UIGraphicsGetCurrentContext();
    [painter paintCell:cell
             onContext:context
            withConfig:config 
        andCurrentCell:nil
              andTheme:theme
            usingCache:NO];
}

//for the quick switch between current values
- (NSString *)encodeValues {
    return NSFormat(@"%d %d", colorIndex, lineWidthIndex);
}

- (void)decodeValues:(NSString *)values {
    NSScanner *scanner = [NSScanner scannerWithString:values];
    [scanner scanInt:&colorIndex];
    [scanner scanInt:&lineWidthIndex];
}

- (void)pushCurrentValues {
    NSString *values = [self encodeValues];
    if ([history containsObject:values]) {
        if ([history indexOfObject:values] == 0) {
            return;
        }
        [history removeObject:values];
    }
    [history insertObject:values atIndex:0];
    if ([history count] > PFNoteInputOptionViewHistorySize) {
        [history removeLastObject];
    }    
}

- (BOOL)circleCurrentValues {
    if ([history count] <= 1) return NO;
    NSString *currentValues = [[[history objectAtIndex:0] retain] autorelease];
    NSString *nextValues = [[[history objectAtIndex:1] retain] autorelease];
    [history removeObjectAtIndex:0];
    [history addObject:currentValues];
    [self decodeValues:nextValues];
    return YES;
}

@end

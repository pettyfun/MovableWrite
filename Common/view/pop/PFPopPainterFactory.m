//
//  PFPopPainterFactory.m
//  PettyFunPop
//
//  Created by YJ Park on 1/6/11.
//  Copyright 2011 PettyFun.com. All rights reserved.
//

#import "PFPopPainterFactory.h"
#import "PFBasicPopPainter.h"
#import "UIColor-Expanded.h"
#import "PFBasicPopPainter.h"
#import "PFPopPopStrokePainter.h"
#import "PFPopSolidStrokePainter.h"

static PFPopPainterFactory *_painterFactoryInstance = nil;

@implementation PFPopPainterFactory

+ (PFPopPainterFactory *) getInstance {
	@synchronized(self) {
		if (_painterFactoryInstance == nil) {
			_painterFactoryInstance = [[PFPopPainterFactory alloc] init];
		}
	}
	return _painterFactoryInstance;
}

-(void) _initCellPainters {
    strokePainters = [[NSMutableArray alloc] init];
    //The order here must follow PFPopCellTypes
    [strokePainters addObject:[[PFPopPopStrokePainter alloc] init]];
    [strokePainters addObject:[[PFPopSolidStrokePainter alloc] init]];
}

-(id) init {
    if ((self = [super init])) {
        [self _initCellPainters];
    }
    return self;
}

-(void) dealloc {
    [strokePainters release];
    [super dealloc];
}

-(id<PFPopPainter>) factoryPopPainter {
    return [[[PFBasicPopPainter alloc] init] autorelease];
}

-(UIColor *) decodeStrokeColor:(NSString *)color {
    UIColor *result = [UIColor colorWithString:color];
    if (!result) {
        result = [UIColor blackColor];
    }
    return result;
}

-(NSString *) encodeStrokeColor:(UIColor *)color {
    return [color stringFromColor];
}

-(id<PFPopStrokePainter>) getStrokePainter:(PFPopStroke *)stroke {
    NSInteger index = 0;
    if (stroke) {
        NSInteger type = stroke.type;
        if ((type >= 0)&&(type <= [strokePainters count])) {
            index = type;
        }
    }
    return [strokePainters objectAtIndex:index];
}

-(UIColor *) getBackgroundColor:(PFPopCell *)cell {
    return [UIColor whiteColor];
}

@end

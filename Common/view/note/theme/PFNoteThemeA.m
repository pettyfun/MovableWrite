//
//  PFNoteBlackBoardTheme.m
//  PettyFunNote
//
//  Created by YJ Park on 12/16/10.
//  Copyright 2010 PettyFun. All rights reserved.
//

#import "PFNoteThemeA.h"


@implementation PFNoteThemeA

-(UIColor *) _getDefaultColor {
    return [UIColor colorWithHexString:@"565451"];
}

-(UIColor *)_getBackgroundColor {
    return [UIColor blackColor];
}

-(void) _initColors {
    colors = [[NSArray arrayWithObjects: 
               [self _getDefaultColor],
               [UIColor colorWithHexString:@"7d0101"],
               [UIColor colorWithHexString:@"5f707d"],
               [UIColor colorWithHexString:@"8e8701"],
               [UIColor colorWithHexString:@"2e501f"],
               [UIColor colorWithHexString:@"2e8192"],
               [UIColor colorWithHexString:@"352786"],
               [UIColor colorWithHexString:@"676897"],
               nil] retain];
}

-(void) _initGridColors {
    gridColors = [[NSArray arrayWithObjects: 
                   [UIColor colorWithHexString:@"333230"],
                   [UIColor colorWithHexString:@"590000"],
                   [UIColor colorWithHexString:@"5e2323"],
                   [UIColor colorWithHexString:@"595d76"],
                   [UIColor colorWithHexString:@"313961"],
                   nil] retain];
}

-(CGPoint) getDisplayHandOffset {
    return CGPointMake(-24.0f, -124.0f);
}

@end

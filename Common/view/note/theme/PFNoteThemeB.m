//
//  PFNoteWhiteBoardTheme.m
//  PettyFunNote
//
//  Created by YJ Park on 12/16/10.
//  Copyright 2010 PettyFun. All rights reserved.
//

#import "PFNoteThemeB.h"
#import "PFNotePainterFactory.h"

@implementation PFNoteThemeB

-(void) _initExtraConfig {
    [super _initExtraConfig];
}

-(UIColor *) _getDefaultColor {
    return [UIColor colorWithHexString:@"231401"];
}

-(UIColor *) _getCurrentColor {
    return [UIColor colorWithHexString:@"eeeeee"];
}

-(UIColor *)_getBackgroundColor {
    return [UIColor colorWithHexString:@"B18B5C"];
}

/*
-(NSString *) _getParentThemeID {
    return PFNOTE_THEME_A;
}
*/

-(CGPoint) getDisplayHandOffset {
    return CGPointMake(-32.0f, -126.0f);
}

-(void) _initColors {
    colors = [[NSArray arrayWithObjects: 
               [self _getDefaultColor],
               [UIColor colorWithHexString:@"9e0b0f"],
               [UIColor colorWithHexString:@"ad3a03"],
               [UIColor colorWithHexString:@"bcc300"],
               [UIColor colorWithHexString:@"073d07"],
               [UIColor colorWithHexString:@"8560a8"],
               [UIColor colorWithHexString:@"014774"],
               [UIColor colorWithHexString:@"402502"],
               nil] retain];
}

-(void) _initGridColors {
    gridColors = [[NSArray arrayWithObjects: 
                   [UIColor colorWithHexString:@"402502"],
                   [UIColor colorWithHexString:@"3043af"],
                   [UIColor colorWithHexString:@"4f3f30"],
                   [UIColor colorWithHexString:@"693e30"],
                   [UIColor colorWithHexString:@"485f30"],
                   nil] retain];
}

@end

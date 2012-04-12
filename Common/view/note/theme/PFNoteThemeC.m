//
//  PFNoteGreenTestTheme.m
//  PettyFunNote
//
//  Created by YJ Park on 12/16/10.
//  Copyright 2010 PettyFun. All rights reserved.
//

#import "PFNoteThemeC.h"
#import "PFNotePainterFactory.h"

@implementation PFNoteThemeC

-(UIColor *) _getDefaultColor {
    return [UIColor colorWithHexString:@"F5F6F1"];
}

-(UIColor *)_getBackgroundColor {
    return [UIColor blackColor];
}

-(NSString *) _getParentThemeID {
    return PFNOTE_THEME_A;
}

-(void) _initColors {
    colors = [[NSArray arrayWithObjects: 
               [self _getDefaultColor],
               [UIColor redColor],
               [UIColor orangeColor],
               [UIColor yellowColor],
               [UIColor greenColor],
               [UIColor cyanColor],
               [UIColor blueColor],
               [UIColor purpleColor],
               nil] retain];
}
               
-(CGPoint) getDisplayHandOffset {
    return CGPointMake(-27.0f, -60.0f);
}

@end

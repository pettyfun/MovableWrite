//
//  PFNoteWhiteBoardTheme.m
//  PettyFunNote
//
//  Created by YJ Park on 12/16/10.
//  Copyright 2010 PettyFun. All rights reserved.
//

#import "PFNoteDefaultTheme.h"

@implementation PFNoteDefaultTheme

-(UIColor *) _getCurrentColor {
    return [UIColor colorWithHexString:@"000000"];
}

-(UIColor *)_getBackgroundColor {
    return [UIColor colorWithHexString:@"E5E4E3"];
}

-(void) _initExtraConfig {
    [super _initExtraConfig];

    DECLARE_PFUTILS
    if (utils.iPadMode) {
        extraConfig.marginLeft = 72.0f;
        extraConfig.marginTop = 2.0f;
    } else {
        extraConfig.marginLeft = 12.0f;
    }
}

@end

//
//  PFToolBar.h
//  PettyFunNote
//
//  Created by YJ Park on 1/27/11.
//  Copyright 2011 PettyFun.com. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface PFToolBar : UIToolbar {
    BOOL transparent;
    UIImage *backgroundImage;
}
@property (assign, nonatomic) BOOL transparent;
@property (retain, nonatomic) UIImage *backgroundImage;

@end

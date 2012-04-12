//
//  PFPopPainterFactory.h
//  PettyFunPop
//
//  Created by YJ Park on 1/6/11.
//  Copyright 2011 PettyFun.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PFPopView.h"
#import "PFPopCell.h"

#define DECLARE_PFPOP_PAINTER_FACTORY PFPopPainterFactory *painterFactory = [PFPopPainterFactory getInstance];

@protocol PFPopStrokePainter;
@interface PFPopPainterFactory : NSObject {
    NSMutableArray *strokePainters;
}
+(PFPopPainterFactory *) getInstance;

-(UIColor *) decodeStrokeColor:(NSString *)color;
-(NSString *) encodeStrokeColor:(UIColor *)color;

-(id<PFPopPainter>) factoryPopPainter;

-(id<PFPopStrokePainter>) getStrokePainter:(PFPopStroke *)stroke;
-(UIColor *) getBackgroundColor:(PFPopCell *)cell;

@end

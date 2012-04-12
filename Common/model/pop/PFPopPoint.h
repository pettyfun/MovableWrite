//
//  PFPopPoint.h
//  PettyFunPop
//
//  Created by YJ Park on 11/18/10.
//  Copyright 2010 PettyFun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PFPoint.h"
#import "Pfpop.pb.h";

extern NSString *const PFPOP_POINT_PRESSURE;
extern NSString *const PFPOP_POINT_CREATE_TIME;

@interface PFPopPoint : PFPoint{
    float pressure;
    NSDate *createTime; //Since 1970
}
@property float pressure;
@property (retain, nonatomic) NSDate *createTime;

+(PFPopPoint *) popPointFromCGPoint:(CGPoint)point
                         withPressure:(float)pointPressure;

+(PFPopPoint *) popPointFromPB:(PFPBPopPoint *)pbPopPoint;

-(PFPBPopPoint *) getPB;

@end

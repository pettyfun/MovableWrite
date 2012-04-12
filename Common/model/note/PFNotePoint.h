//
//  PFNotePoint.h
//  PettyFunNote
//
//  Created by YJ Park on 11/18/10.
//  Copyright 2010 PettyFun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PFPoint.h"

extern NSString *const PFNOTE_POINT_PRESSURE;
extern NSString *const PFNOTE_POINT_CREATE_TIME;

#define PFNOTE_POINT_PRESSURE_DEFAULT 1.0f
#define PFNOTE_POINT_BASE_FACTOR 32.0f
#define PFNOTE_POINT_MIN_FACTOR ([PFUtils getInstance].iPadMode ? 16.0f : 12.0f)
#define PFNOTE_POINT_MAX_FACTOR ([PFUtils getInstance].iPadMode ? 128.0f : 78.0f)
#define PFNOTE_POINT_DEFAULT_FACTOR ([PFUtils getInstance].iPadMode ? 48.0f : 24.0f)

#define PFNOTE_POINT_CHANGE_THRESHOLD 0.005f

@interface PFNotePoint : PFPoint {
    float pressure;
    float createTime; //Since Offset
}
@property float pressure;
@property float createTime;

+(PFNotePoint *) notePointFromCGPoint:(CGPoint)point
                         withPressure:(float)pointPressure
                          andTimeMark:(double)timeMark;

+(CGFloat) getFactor:(CGFloat)factor scale:(CGFloat)scale;
+(CGFloat) verifyFactor:(CGFloat)factor;

@end

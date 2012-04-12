//
//  PFPopCell.h
//  PettyFunPop
//
//  Created by YJ Park on 1/6/11.
//  Copyright 2011 PettyFun.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PFObject.h"
#import "PFPopStroke.h"

@interface PFPopCell : PFObject {
    NSString *type;
    NSMutableArray *strokes;
}
@property (nonatomic, retain) NSString *type;
@property (readonly) NSMutableArray *strokes;

-(id) initWithType:(NSString *)cellType;

-(PFPopStroke *) getLastStroke;
-(void) addStroke:(PFPopStroke *)stroke;
-(void) clearStrokes;
-(void) copyStrokesFrom:(PFPopCell *)cell;

-(BOOL) isEmptyCell;

@end

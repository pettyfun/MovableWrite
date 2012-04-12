//
//  PFNoteBezierCellPainter.h
//  PettyFunNote
//
//  Created by YJ Park on 11/18/10.
//  Copyright 2010 PettyFun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PFPageView.h"
#import "PFNoteTheme.h"
#import "PFNoteStroke.h"
#import "PFBaseBezierPainter.h"
#import "PFNoteCellPainter.h"

@interface PFNoteBezierStrokePainter : PFBaseBezierPainter <PFNoteStrokePainter> {
}
@end

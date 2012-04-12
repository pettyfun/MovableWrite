//
//  NotePagesDialog.h
//  PettyFunNote
//
//  Created by YJ Park on 12/9/10.
//  Copyright 2010 PettyFun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AQGridViewController.h"

#import "NoteDisplayPanel.h"
#import "PFPageView.h"

#define NOTE_PAGE_THUMBNAIL_NUM 3.0f
#define NOTE_PAGE_THUMBNAIL_SCALE 0.28f
#define NOTE_PAGE_CONTENT_SCALE_IPAD 0.8f
#define NOTE_PAGE_CONTENT_SCALE_IPHONE 1.0f

#define NOTE_PAGE_THUMBNAIL_TAG 84726

#define PFNOTE_PAGES_SELECT_PAGE_DELAY 0.0f

@protocol NotePagesDialogDelegate<NSObject>
@required
-(void) onPageSelected:(int)pageIndex;
@end

@interface NotePagesDialog : AQGridViewController<PFPageViewDelegate> {
    NoteDisplayPanel *displayPanel;
    
    PFPageView *thumbnailView;
    UIFont *thumbnailFont;
    CGSize contentSize, cellSize, thumbnailSize;
    
    BOOL loaded;
    id<NotePagesDialogDelegate> delegate;
}
@property (nonatomic, assign) id<NotePagesDialogDelegate> delegate;

-(NotePagesDialog *) initWithDisplayPanel:(NoteDisplayPanel *)noteDisplayPanel;

-(CGSize) getContentSize;

-(void) selectCurrentPage:(NSTimer *)timer;
-(void) onPageSelected: (NSTimer *)timer;
-(void) reloadThumbnails:(NSTimer *)timer;

-(void)_initThumbnailView;
-(void)_updateThumbnailView;
-(UIImage *)_getThumbnailImage:(NSInteger)index;
-(UIImage *)_getThumbnailImageNoCache:(NSInteger)index;

@end

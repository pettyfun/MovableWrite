//
//  NoteHelpController.h
//  PettyFunNote
//
//  Created by YJ Park on 3/15/11.
//  Copyright 2011 PettyFun.com. All rights reserved.
//

#import <UIKit/UIKit.h>

#define PFNOTE_HELP_IMAGE_PATH @"Help"

#define PFNOTE_HELP_IMAGE_WIDTH_IPAD 728
#define PFNOTE_HELP_IMAGE_HEIGHT_IPAD 920

#define PFNOTE_HELP_IMAGE_WIDTH_IPHONE 470
#define PFNOTE_HELP_IMAGE_HEIGHT_IPHONE 270

@protocol NoteHelpDelegate<NSObject>
@required
-(void) onHelpClosed;
@end

@interface NoteHelpController : PFViewController <UIScrollViewDelegate> {
    id<NoteHelpDelegate> delegate;
    
    IBOutlet UIScrollView *scrollView;
    IBOutlet UIPageControl *pageControl;
    
    NSMutableArray *helpImageViews;
}
@property (nonatomic, assign) IBOutlet id<NoteHelpDelegate> delegate;

-(IBAction) onClose:(id)sender;

-(void) loadHelpImageViews;
@end

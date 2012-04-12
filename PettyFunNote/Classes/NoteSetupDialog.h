//
//  NoteSetupPanel.h
//  PettyFunNote
//
//  Created by YJ Park on 12/2/10.
//  Copyright 2010 PettyFun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PFNoteConfig.h"

#define PFNOTE_SETUP_SELECT_BACKGROUND_DELAY 0.25f

#define PFNOTE_SETUP_GRID_COLOR_TAG_START 301
#define PFNOTE_SETUP_GRID_COLOR_TAG_NUM 5

@protocol NoteSetupDialogDelegate<NSObject>
@required
-(void) onSetupDialogUpdate:(BOOL)needLayout;
-(void) onSetupDialogSave:(BOOL)saveAsDefault;
-(void) onSetupDialogFinished;
@end


@interface NoteSetupDialog : PFViewController <UITableViewDataSource, UITableViewDelegate>{
    PFNoteConfig *savedConfig;

    IBOutlet UISegmentedControl *strokeTypeControl;

    IBOutlet UISegmentedControl *gridTypeControl;
    IBOutlet UITableView *themesTable;
    IBOutlet UIView *gridColorsView;
    IBOutlet UIImageView *gridColorSelectedIcon;
    IBOutlet UIImageView *themeSelectedIcon;    

    IBOutlet UISlider *leftRightSlider;    
    IBOutlet UISlider *topBottomSlider;    
    IBOutlet UISlider *lineSlider;    
    IBOutlet UISlider *wordSlider;    
    IBOutlet UISlider *indentSlider;    
    IBOutlet UISlider *spaceSlider;    

    id<NoteSetupDialogDelegate> delegate;
}
@property (nonatomic, assign) id<NoteSetupDialogDelegate> delegate;

-(IBAction) onStrokeTypeChanged:(id)sender;
-(void) updateSpecialEffectsTitle;

-(IBAction) onGridTypeChanged:(id)sender;
-(IBAction) onGridColorChanged:(id)sender;

-(IBAction) onSave:(id)sender;
-(IBAction) onSaveAsDefault:(id)sender;
-(IBAction) onCancel:(id)sender;

-(void) onLeftRightChanged:(id)sender;
-(void) onTopBottomChanged:(id)sender;
-(void) onLineChanged:(id)sender;
-(void) onWordChanged:(id)sender;
-(void) onIndentChanged:(id)sender;
-(void) onSpaceChanged:(id)sender;

-(void) updateGridColors;
-(void) updateGridColorSelectedIcon;
-(void) updateSliders;
-(void) resetSliders;
-(void) initSliders;

-(void) updateConfig:(BOOL)needLayout;
@end

//
//  NoteAppDelegate.h
//  PettyFunNote
//
//  Created by YJ Park on 11/7/10.
//  Copyright 2010 pettyfun.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "AdWhirlDelegateProtocol.h"
#import "AdWhirlView.h"
#import "PFNoteModel.h"
#import "PFPageView.h"
#import "NoteInputPanel.h"
#import "NoteDisplayPanel.h"
#import "NotePrinterPanel.h"
#import "NoteBrowseDialog.h"
#import "NoteSetupDialog.h"
#import "NotePagesDialog.h"
#import "NoteStoreController.h"
#import "PFNotePageNumberView.h"
#import "NoteHelpController.h"

#define PFNOTE_OPERATION_DELAY 0.0f
#define PFNOTE_APP_TOGGLE_DURATION 0.3f

#define PFNOTE_AD_IMAGE_NUM 1

#define PFNOTE_AD_DELAY 0.5f

#define PFNOTE_APP_ID @"416413981"
#define PFNOTE_APP_URL @"http://phobos.apple.com/WebObjects/MZStore.woa/wa/viewSoftware?id=416413981&mt=8"

#define PFNOTE_APP_CHECK_POPOVER_AND_MODAL \
    if ((popoverController && popoverController.popoverVisible) || self.modalViewController) return;    

extern NSString *const NoteAppDelegateOperationKey;
extern NSString *const NoteAppDelegateSenderKey;

extern NSString *const NoteAppDelegateOperationStore;

#define PFNOTE_CHECK_NEEDSAVE(senderValue, nextOperation) \
if (model.note.needSave) { \
    [utils showProgressHUD:self.view withText:PF_L10N(@"app_saving")]; \
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys: \
        nextOperation, NoteAppDelegateOperationKey, \
        senderValue, NoteAppDelegateSenderKey, nil]; \
    PFUTILS_delayWithInterval(PFNOTE_OPERATION_DELAY, userInfo, saveNote:); \
    return; \
}

@interface NoteAppDelegate : PFViewController 
<UIApplicationDelegate, 
 NotePrinterPanelDelegate, MFMailComposeViewControllerDelegate,
 NoteBrowseDialogDelegate, NoteSetupDialogDelegate, PFNoteModelDelegate,
 AdWhirlDelegate, NotePagesDialogDelegate, NoteStoreDelegate,
 NoteHelpDelegate> {
    //Application xib
    IBOutlet UIWindow *window;

    IBOutlet NoteDisplayPanel *displayPanel;
    IBOutlet NoteInputPanel *inputPanel;

    IBOutlet NoteBrowseDialog *noteBrowseDialog;
    IBOutlet NoteStoreController *noteStoreController;
    IBOutlet UINavigationController *noteStoreNavController;
    IBOutlet NoteHelpController *noteHelpController;
     
    IBOutlet NoteSetupDialog *noteSetupDialog;
    IBOutlet NotePrinterPanel *printerPanel;
    UIPopoverController *popoverController;     
     
    //Main View xib
    AdWhirlView *adWhirlView;
     
    IBOutlet UIView *displayView;
    IBOutlet UIView *inputView;

    IBOutlet UIToolbar *toolbar;
    IBOutlet UIBarButtonItem *toggleInputButton;          
    IBOutlet UIBarButtonItem *setupButton;          
    IBOutlet UIBarButtonItem *storeButton;          
    IBOutlet UIBarButtonItem *browseButton;          

    //Created programatically;
    NotePagesDialog *notePagesDialog;
    
    PFNotePageNumberView *pageNumberView;
     
    BOOL writing;
}

-(IBAction) onDone:(id)sender;
-(IBAction) onToggleInput:(id)sender;
-(IBAction) onSetup:(id)sender;
-(IBAction) onPages:(id)sender;
-(IBAction) onBrowse:(id)sender;
-(IBAction) onPreview:(id)sender;
-(IBAction) onStore:(id)sender;

-(void) hideInput;
-(void) showInput;

-(void) loadNote:(NSTimer *)timer;
-(void) saveNote:(NSTimer *)timer;

-(BOOL) deleteFile:(NSString *)path backup:(BOOL)backup;

-(void) onAdClick:(id)sender;

-(void) updateWithTheme:(PFNoteTheme *)theme;

-(void) checkUnpurchasedProducts:(BOOL)showAlert;

-(void) _initAnalytic;
-(void) _initAppirater;
-(void) _initAdWhirl:(NSTimer *)timer;

-(void) _resizeAdWhirlView:(NSTimer *) timer;
-(UIView *) _getAdView;

-(void) _onLaunchingWithOptions:(NSDictionary *)launchOptions;
-(BOOL) _hasCopiedFiles;
-(void) _importCopiedFiles:(NSTimer *) timer;
-(PFNote *) _importCopiedFile:(NSString *)path;

//Universal tricks
-(void) showSubView:(UIViewController *)contentViewControllor sender:(id)sender;
-(void) showSubView:(UIViewController *)contentViewControllor size:(CGSize)contentSize sender:(id)sender;
-(void) hideSubView:(BOOL)iPhoneAnimated;

@end

void uncaughtExceptionHandler(NSException *exception);

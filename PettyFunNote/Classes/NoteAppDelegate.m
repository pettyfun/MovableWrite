//
//  NoteAppDelegate.m
//  PettyFunNote
//
//  Created by YJ Park on 11/7/10.
//  Copyright 2010 pettyfun.com. All rights reserved.
//

#import "FlurryAPI.h"
#import "FlurryAPI+AppCircle.h"
#import "Appirater.h"
#import "PFToolBar.h"

#import "NoteAppDelegate.h"
#import "PFFileNavController.h"

NSString *const NoteAppDelegateOperationKey = @"operation";
NSString *const NoteAppDelegateSenderKey = @"sender";

NSString *const NoteAppDelegateOperationStore = @"store";

@implementation NoteAppDelegate

#pragma mark -
#pragma mark Application lifecycle

void uncaughtExceptionHandler(NSException *exception) {
    PFCritical(@"Uncaught Exception: %@", exception);
    [FlurryAPI logError:@"Uncaught" message:@"Crash!" exception:exception];
}

- (void)_initPageNumberView {
    //This is really hacky, though don't know why toolbar is nil in viewDidLoad
    if (pageNumberView != nil) return;
    if (toolbar == nil) return;
    
    DECLARE_PFNOTE_MODEL
    CGFloat windowWidth = [model getWindowSize].width;
    
    CGRect numberFrame = CGRectMake(0.0f, 0.0f,
                                    windowWidth,
                                    44);
    pageNumberView = [[PFNotePageNumberView alloc] initWithFrame:numberFrame];
    [toolbar addSubview:pageNumberView];
    [toolbar sendSubviewToBack:pageNumberView];
    [pageNumberView addTarget:self
                       action:@selector(onPages:)
             forControlEvents:UIControlEventTouchUpInside];    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    displayView.backgroundColor = [UIColor blackColor];
    inputView.backgroundColor = [UIColor blackColor];
    
    [displayView addSubview:displayPanel.view];
    inputPanel.displayPanel = displayPanel;
    displayPanel.inputPanel = inputPanel;
    [inputView addSubview:inputPanel.view];
    [self.view bringSubviewToFront:displayView];
    [self.view sendSubviewToBack:inputView];
    
    [self _initPageNumberView];
    //showing background during loading
    [self onConfigUpdate];
    
    notePagesDialog = [[NotePagesDialog alloc] initWithDisplayPanel:displayPanel];
    notePagesDialog.delegate = self;
    
    PFUTILS_delayWithInterval(PFNOTE_AD_DELAY, nil, _initAdWhirl:);
}

- (void)releaseViewElements {
    [super releaseViewElements];
    inputPanel.displayPanel = nil;
    displayPanel.inputPanel = nil;
    [displayPanel.view removeFromSuperview];
    [inputPanel.view removeFromSuperview];
    [pageNumberView removeFromSuperview];

    PF_Release_And_Nil(pageNumberView);    
    PF_Release_And_Nil(notePagesDialog);
    PF_Release_And_Nil(adWhirlView);

    PF_Release_IBOutlet(displayView)
    PF_Release_IBOutlet(inputView)
    PF_Release_IBOutlet(toolbar)
    PF_Release_IBOutlet(toggleInputButton)
    PF_Release_IBOutlet(setupButton)
    PF_Release_IBOutlet(storeButton)
    PF_Release_IBOutlet(browseButton)
}

-(BOOL) application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    if (url != nil && [url isFileURL]) {
        return YES;
    }     
    return NO;
}

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    DECLARE_PFNOTE_MODEL;
    if (!model.iPadMode) {
        [UIApplication sharedApplication].statusBarHidden = YES;
        self.view.frame = CGRectMake(0, 0, 320, 480); //VERY HACKY HERE!
#if TARGET_IPHONE_SIMULATOR
        CGAffineTransform transform = CGAffineTransformMakeRotation(0.5 * 3.1415926);
        transform = CGAffineTransformTranslate(transform, -80, +80);
        self.view.transform = transform;
#endif
    }

    NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
    [self _initAnalytic];
    
    [PFNoteModel getInstance].delegate = self;
    [window makeKeyAndVisible];   
        
    [self _onLaunchingWithOptions:launchOptions];
    
    [[SKPaymentQueue defaultQueue] addTransactionObserver:noteStoreController];
    [self _initAppirater];
    
    return YES;
}

-(void) _onLaunchingWithOptions:(NSDictionary *)launchOptions {
    DECLARE_PFNOTE_MODEL
    NSString *adFreeKey = [model getProductKey:NOTE_PRODUCT_ADFREE withType:PFNoteProductTypeGeneral];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onNoAdPurchased:)
                                                 name:adFreeKey
                                               object:nil];
    DECLARE_PFUTILS
    NSURL *url = [launchOptions valueForKey:UIApplicationLaunchOptionsURLKey];
    if (url) {
        //will handle the URL in openURL method
    } else if ([self _hasCopiedFiles]) {
        [utils showProgressHUD:self.view withText:PF_L10N(@"app_importing_files")];
        PFUTILS_delayWithInterval(PFNOTE_OPERATION_DELAY, nil, _importCopiedFiles:);
    } else {
        NSString *lastPath = [utils getDefault:NOTE_DEFAULT_LAST_NOTE_PATH];
        NSString *notePath = nil;
        if (lastPath) {
            NSFileManager *fileManager = [NSFileManager defaultManager];
            BOOL isDir;
            if ([fileManager fileExistsAtPath:lastPath isDirectory:&isDir]) {
                if (!isDir) {
                    notePath = lastPath;
                }
            }
        }
        if (notePath) {        
            //clear the last path, in case the file can not be loaded,
            //if it worked, then the load logic will set it back
            [utils setDefault:nil forKey:NOTE_DEFAULT_LAST_NOTE_PATH];
            
            [utils showProgressHUD:self.view withText:PF_L10N(@"app_loading")];
            PFUTILS_delayWithInterval(PFNOTE_OPERATION_DELAY, notePath, loadNote:);
        } else {
            [self onBrowseDialogNew];
            //Showing help when run the first time.
            if (!lastPath) [self onBrowseDialogHelp];
        }
    }
} 

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    DECLARE_PFUTILS
    [utils showProgressHUD:self.view withText:PF_L10N(@"app_importing_url")];
    PFUTILS_delayWithInterval(PFNOTE_OPERATION_DELAY, url, _openFromURL:);
    return YES;
}


-(void) _openFromURL:(NSTimer *) timer {
    NSURL *url = timer.userInfo;
    DECLARE_PFUTILS
    PFNote *newNote = nil;
    @try {
        newNote = [[[PFNote alloc] initFromURL:url] autorelease];
    }
    @catch (NSException * e) {
        newNote = nil;
    }
    [utils hideProgressHUD];
    if (newNote) {
        [newNote resetPath:NOTE_FOLDER_INBOX];        
        [newNote save];
        
        if ([url isFileURL]) {
            [[NSFileManager defaultManager] removeItemAtPath:[url path] error:NULL];
        }

        DECLARE_PFNOTE_MODEL
        [model updateNoteIndex:newNote save:YES];
        [utils showProgressHUD:self.view withText:PF_L10N(@"app_loading")];
        PFUTILS_delayWithInterval(PFNOTE_OPERATION_DELAY, newNote.path, loadNote:);
    } else {
        PFUTILS_showAlertMsg(@"Message", NSFormat(@"URL import failed: %@", url),
                             @"OK", nil);
    }


}

-(BOOL) _hasCopiedFiles {
    DECLARE_PFUTILS
    DECLARE_PFNOTE_MODEL
    NSString *path = [utils getDocumentPath];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *items = [fileManager contentsOfDirectoryAtPath:path error:NULL];
    for (NSString *item in items) {
        BOOL isDir;
        NSString *itemPath = [path stringByAppendingPathComponent:item];
        if ([fileManager fileExistsAtPath:itemPath isDirectory:&isDir]) {
            if (!isDir) {
                PFItemType *noteType = [model.note getItemType];
                if ([noteType isFileWithType:item]) {
                    return YES;
                }
            }
        }
    }
    return NO;
}

-(void) _importCopiedFiles:(NSTimer *) timer {
    DECLARE_PFNOTE_MODEL
    DECLARE_PFUTILS
    NSString *path = [utils getDocumentPath];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *items = [fileManager contentsOfDirectoryAtPath:path error:NULL];
    PFNote *lastNote = nil;
    for (NSString *item in items) {
        BOOL isDir;
        NSString *itemPath = [path stringByAppendingPathComponent:item];
        if ([fileManager fileExistsAtPath:itemPath isDirectory:&isDir]) {
            if (!isDir) {
                PFItemType *noteType = [model.note getItemType];
                if ([noteType isFileWithType:item]) {
                    PFNote *newNote = [self _importCopiedFile:itemPath];
                    if (newNote) {
                        [fileManager removeItemAtPath:itemPath error:NULL];
                        if (lastNote) {
                            [lastNote release];
                        }
                        lastNote = [newNote retain];
                    }
                }
            }
        }
    }
    [model updateNoteIndex:nil save:YES];
    [utils hideProgressHUD];
    if (lastNote) {
        [utils showProgressHUD:self.view withText:PF_L10N(@"app_loading")];
        PFUTILS_delayWithInterval(PFNOTE_OPERATION_DELAY, lastNote.path, loadNote:);
        [lastNote release];
        lastNote = nil;
    }
}

-(PFNote *) _importCopiedFile:(NSString *)path {
    DECLARE_PFNOTE_MODEL
    PFNote *newNote = nil;
    @try {
        newNote = [[[PFNote alloc] initFromPath:path] autorelease];
    }
    @catch (NSException * e) {
        newNote = nil;
    }
    if (newNote) {
        [newNote resetPath:nil];        
        [newNote save];
        [model updateNoteIndex:newNote save:YES];
    } else {
        PFUTILS_showAlertMsg(@"Message", NSFormat(@"File import failed: %@", path),
                             @"OK", nil);
    }

    return newNote;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)onQuit {
    [self saveNote:nil];
    DECLARE_PFUTILS
    [utils synchronizeDefaults];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
    [self onQuit];
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
    [Appirater appEnteredForeground:YES];
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}


- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     See also applicationDidEnterBackground:.
     */
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:noteStoreController];
    [self onQuit];
}


#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
    [FlurryAPI logEvent:@"memory"];
    DECLARE_PFUTILS
    [utils clearCache];

     DECLARE_PFNOTE_MODEL;
    if (model.note.needSave) {
        [utils showProgressHUD:self.view withText:PF_L10N(@"app_auto_saving")];
        PFUTILS_delayWithInterval(PFNOTE_OPERATION_DELAY, nil, saveNote:);
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

#pragma mark -
#pragma mark internal methods
-(void) _initAnalytic {
    NSString *flurryKey = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"FlurryKey"];
    [FlurryAPI setAppCircleEnabled:YES];
    [FlurryAPI setAppCircleDelegate:noteStoreController];
    [FlurryAPI startSession:flurryKey];
    [FlurryAPI setSessionReportsOnCloseEnabled:NO];
}

-(void) _initAppirater {
    NSDictionary *config = [NSDictionary dictionaryWithObjectsAndKeys:
                            PFNOTE_APP_ID, kAppiraterConfigAppID,
                            PF_L10N(@"app_rate_title"), kAppiraterConfigTitle,
                            PF_L10N(@"app_rate_message"), kAppiraterConfigMessage,
                            PF_L10N(@"app_rate_cancel"), kAppiraterConfigCancel,
                            PF_L10N(@"app_rate_rate"), kAppiraterConfigRate,
                            PF_L10N(@"app_rate_later"), kAppiraterConfigLater,
                            nil];
    [Appirater appConfigure:config];
    [Appirater appLaunched:YES];
}

#pragma mark -
#pragma mark Event handler

-(IBAction) onDone:(id)sender {
    //TODO: For debug only, remove before submit.
    PFDebug(@"onDone");
    exit(0);
}

-(void) hideInput {
    DECLARE_PFNOTE_MODEL
    CGFloat windowHeight = [model getWindowSize].height;
    
    float inputViewHeight = inputView.frame.size.height;
    float toolbarHeight = toolbar.frame.size.height;
    CGRect frame = displayView.frame;

    if (model.iPadMode) {
        displayView.frame = CGRectMake(frame.origin.x, frame.origin.y,
                                       frame.size.width,
                                       frame.size.height + inputViewHeight - toolbarHeight);
    } else {
        CGFloat adViewHeight = 0;
        if (adWhirlView && adWhirlView.hidden) {
            adViewHeight = adWhirlView.frame.size.height;
            adWhirlView.hidden = NO;
            [adWhirlView doNotIgnoreAutoRefreshTimer];
        }
        displayView.frame = CGRectMake(frame.origin.x, frame.origin.y + adViewHeight,
                                       frame.size.width,
                                       frame.size.height + inputViewHeight
                                       - toolbarHeight - adViewHeight);
    }

    displayPanel.penView.hidden = YES;
    inputView.frame = CGRectMake(0.0f, 
                                 windowHeight - toolbarHeight,
                                 inputView.frame.size.width,
                                 inputViewHeight);
    [inputPanel normalizeCurrentInputCell];
    toolbar.frame = CGRectMake(0.0f,
                               windowHeight - toolbarHeight,
                               toolbar.frame.size.width,
                               toolbarHeight);
    inputPanel.inputEnabled = NO;

    if (model.note.needSave) {
        DECLARE_PFUTILS
        [utils showProgressHUD:self.view withText:PF_L10N(@"app_saving")];
        PFUTILS_delayWithInterval(0.0f, nil, saveNote:);
    }
}

-(void) showInput {
    DECLARE_PFNOTE_MODEL
    CGFloat windowHeight = [model getWindowSize].height;
    
    float inputViewHeight = inputView.frame.size.height;
    float toolbarHeight = toolbar.frame.size.height;
    
    CGRect frame = displayView.frame;
    
    if (model.iPadMode) {
        displayView.frame = CGRectMake(frame.origin.x, frame.origin.y,
                                       frame.size.width,
                                       frame.size.height - inputViewHeight + toolbarHeight);
    } else {
        CGFloat adViewHeight = 0;
        if (adWhirlView && !adWhirlView.hidden) {
            adViewHeight = adWhirlView.frame.size.height;
            adWhirlView.hidden = YES;
            [adWhirlView ignoreAutoRefreshTimer];
        }
        displayView.frame = CGRectMake(frame.origin.x, frame.origin.y - adViewHeight,
                                       frame.size.width,
                                       frame.size.height - inputViewHeight
                                       + toolbarHeight + adViewHeight);
    }
    
    inputView.frame = CGRectMake(0.0f,
                                 windowHeight - inputViewHeight,
                                 inputView.frame.size.width,
                                 inputViewHeight);
    toolbar.frame = CGRectMake(0.0f,
                               windowHeight,
                               toolbar.frame.size.width,
                               toolbarHeight);
    
    inputPanel.inputEnabled = YES;    
}

-(IBAction) onToggleInput:(id)sender {
    DECLARE_PFNOTE_MODEL
    PFNOTE_CHECK_WRITING
    PFNOTE_APP_CHECK_POPOVER_AND_MODAL
    [model clearPageCache];
    model.writing = YES;
    [UIView transitionWithView:self.view
                      duration:PFNOTE_APP_TOGGLE_DURATION
                       options:UIViewAnimationOptionTransitionNone
                    animations:^{
                        if (inputPanel.inputEnabled) {
                            [self hideInput];
                        } else {
                            [self showInput];
                        }
                        [displayPanel resetDisplayPanel];
                    }
                    completion:^(BOOL finished){
                        DECLARE_PFNOTE_MODEL
                        model.writing = NO;
                        [inputPanel resetInputPanel];
                    }];
}

-(IBAction) onBrowse:(id)sender {
    DECLARE_PFNOTE_MODEL
    PFNOTE_CHECK_WRITING
    PFNOTE_APP_CHECK_POPOVER_AND_MODAL

    DECLARE_PFUTILS
    if ([self _hasCopiedFiles]) {
        [utils showProgressHUD:self.view withText:PF_L10N(@"app_importing_files")];
        PFUTILS_delayWithInterval(PFNOTE_OPERATION_DELAY, nil, _importCopiedFiles:);
    } else {
        [self showSubView:noteBrowseDialog size:CGSizeMake(640, 580) sender:sender];
    }
}

-(void) onBrowseDialogHelp {
    [self hideSubView:NO];
    [self presentModalViewController:noteHelpController animated:YES];
    [FlurryAPI logEvent:@"help"];
}

-(void) onBrowseDialogFinished {
    [self hideSubView:YES];
}

-(void) onBrowseDialogSave {
    [self hideSubView:YES];
    DECLARE_PFNOTE_MODEL
    if (model.note.needSave) {
        DECLARE_PFUTILS
        [utils showProgressHUD:self.view withText:PF_L10N(@"app_saving")];
        PFUTILS_delayWithInterval(PFNOTE_OPERATION_DELAY, nil, saveNote:);
    }
}

-(void) onBrowseDialogDelete {
    [self hideSubView:YES];
    DECLARE_PFUTILS
    [utils showProgressHUD:self.view withText:PF_L10N(@"app_deleting")];
    PFUTILS_delayWithInterval(PFNOTE_OPERATION_DELAY, nil, deleteNote:);
}
 
-(void) deleteNote:(NSTimer *)timer {
    DECLARE_PFNOTE_MODEL
    NSString *path = [[model.note.path retain] autorelease];
    [self saveNote:nil];
    [FlurryAPI logEvent:@"delete" withParameters:[model.note getAnalyticData]];
    [model newNote];
    [self deleteFile:path backup:YES];
    [displayPanel refreshDisplayPanel];
    //not toggle input, since the user just means to delete it, not create a new one.
    DECLARE_PFUTILS
    [utils hideProgressHUD];
}

-(void) onBrowseDialogArchive {
    [self hideSubView:YES];
    DECLARE_PFUTILS
    DECLARE_PFNOTE_MODEL
    if ([model.note isInSubFolder:NOTE_FOLDER_ARCHIVE]) {
        [utils showProgressHUD:self.view withText:PF_L10N(@"app_homing")];
        PFUTILS_delayWithInterval(PFNOTE_OPERATION_DELAY, nil, moveNote:);
    } else {
        [utils showProgressHUD:self.view withText:PF_L10N(@"app_archiving")];
        PFUTILS_delayWithInterval(PFNOTE_OPERATION_DELAY, NOTE_FOLDER_ARCHIVE, moveNote:);
    }
}

-(void) moveNote:(NSTimer *)timer {
    DECLARE_PFNOTE_MODEL
    DECLARE_PFUTILS
    NSString *path = [[model.note.path retain] autorelease];
    [model.note resetPath:(NSString *)timer.userInfo];
    if (![path isEqualToString:model.note.path]) {
        model.note.needSave = YES;
        [self saveNote:nil];
        NSString *event = @"move_home";
        if (timer.userInfo) {
            event = NSFormat(@"move_%@", timer.userInfo);
        }
        [FlurryAPI logEvent:event withParameters:[model.note getAnalyticData]];
        if ([utils isPathExist:model.note.path]) {
            [self deleteFile:path backup:YES];
        }
        [displayPanel refreshDisplayPanel];
    }
    [utils hideProgressHUD];
}

-(void) onBrowseDialogNew {
    [self hideSubView:YES];
    DECLARE_PFUTILS
    [utils showProgressHUD:self.view withText:PF_L10N(@"app_newing")];
    PFUTILS_delayWithInterval(PFNOTE_OPERATION_DELAY, nil, newNote:);
}

-(void) newNote:(NSTimer *)timer {
    DECLARE_PFNOTE_MODEL
    [self saveNote:nil];
    [model newNote];
    [FlurryAPI logEvent:@"new"];
    if (!inputPanel.inputEnabled) {
        [self onToggleInput:nil];
    } else {
        [inputPanel resetInputPanel];
        [displayPanel refreshDisplayPanel];
        [inputPanel onNextWord:nil];
    }
    DECLARE_PFUTILS
    [utils hideProgressHUD];
    [self checkUnpurchasedProducts:NO];    
}

-(void) onBrowseDialogSend {
    [self hideSubView:NO];
    if (![MFMailComposeViewController canSendMail]) {
        PFUTILS_showAlertMsg(PF_L10N(@"error"),
                             PF_L10N(@"app_can_not_send"),
                             PF_L10N(@"ok"), nil);
        return;
    }
    [self saveNote:nil];
    DECLARE_PFNOTE_MODEL
    if (model.iPadMode) {
        //have to hide the statusbar here before showing the dialog
        [UIApplication sharedApplication].statusBarHidden = YES;
    }
    [FlurryAPI logEvent:@"print" timed:YES];
    printerPanel.mode = NotePrinterPanelModePrint;
    [self presentModalViewController:printerPanel animated:NO];
}

-(void) checkUnpurchasedProducts:(BOOL)showAlert {
    DECLARE_PFNOTE_MODEL
    NSArray *unpurchasedProducts = [model getUnpurchasedProductsInConfig:model.config];
    if (unpurchasedProducts && ([unpurchasedProducts count] > 0)) {
        if (!PFNOTE_DISABLE_WATERMARK) {
            model.config.showingWatermark = YES;
            if (showAlert) {
                PFUTILS_showAlertMsg(
                                     PF_L10N(@"app_unpurchased_title"),
                                     NSFormat(PF_L10N(@"app_unpurchased_description_%@"), [model getProductTitles:unpurchasedProducts]),
                                     PF_L10N(@"ok"),
                                     nil)
            }
        } else {
            model.config.showingWatermark = NO;            
        }
    } else {
        model.config.showingWatermark = NO;
    }
}

-(IBAction) onSetup:(id)sender {
    DECLARE_PFNOTE_MODEL
    model.config.showingWatermark = NO;
    [displayPanel refreshDisplayPanel];
    [self showSubView:noteSetupDialog size:CGSizeMake(640, 580) sender:sender];
}

-(void) onSetupDialogSave:(BOOL)saveAsDefault {
    DECLARE_PFNOTE_MODEL
    if (saveAsDefault) {
        [model saveConfigAsDefault];
        PFUTILS_showAlertMsg(PF_L10N(@"app_message"),
                             PF_L10N(@"app_save_default"),
                             PF_L10N(@"ok"), nil);
    } else {
        [self hideSubView:YES];
        DECLARE_PFUTILS
        [utils showProgressHUD:self.view withText:PF_L10N(@"app_saving")];
        [model.note.config updateTo:model.config];
        model.note.needSave = YES;
        
        [model refreshConfig];
        PFUTILS_delayWithInterval(PFNOTE_OPERATION_DELAY, nil, saveNote:);
    }
}

-(void) onSetupDialogFinished {
    [self checkUnpurchasedProducts:YES];
    [displayPanel refreshDisplayPanel];
}

-(void) onSetupDialogUpdate:(BOOL)needLayout {
    if (needLayout) {
        DECLARE_PFNOTE_MODEL
        [model resetPages];
        [model clearPageCache];
    }
    [displayPanel refreshConfig];
    [displayPanel refreshDisplayPanel];
}

-(IBAction) onPages:(id)sender {
    [self showSubView:notePagesDialog size:[notePagesDialog getContentSize] sender:sender];   
}

-(void) onPageSelected:(int)pageIndex {
    DECLARE_PFNOTE_MODEL
    if ([model setCurrentPageIndex:pageIndex]) {
        [inputPanel resetInputPanel];
        [displayPanel refreshDisplayPanel];
        [self hideSubView:YES];
    } else {
        [self hideSubView:YES];
    }
}

-(IBAction) onStore:(id)sender {
    DECLARE_PFNOTE_MODEL
    PFNOTE_CHECK_WRITING
    PFNOTE_APP_CHECK_POPOVER_AND_MODAL
    DECLARE_PFUTILS
    PFNOTE_CHECK_NEEDSAVE(sender, NoteAppDelegateOperationStore)
    [noteStoreController resetProducts];
    [self presentModalViewController:noteStoreNavController animated:YES];
    [FlurryAPI logEvent:@"store"];
}

-(void) onStoreClosed {
    [self checkUnpurchasedProducts:NO];
    [displayPanel refreshDisplayPanel];
}

-(void) onHelpClosed {
}

-(void) saveNote:(NSTimer *)timer {
    DECLARE_PFNOTE_MODEL
    if (inputPanel.inputEnabled) {
        BOOL resetPage = [inputPanel normalizeCurrentInputCell];
        if (resetPage) {
            [model resetPages];
        }
        [displayPanel refreshDisplayPanel];
        [inputPanel resetInputPanel];
    }
    [model saveNote];
    if (timer != nil) {
        DECLARE_PFUTILS
        [utils hideProgressHUD];
    }
    NSDictionary *analyticData = [model.note getAnalyticData];
    [FlurryAPI logEvent:@"save" withParameters:analyticData];
    model.note.needSave = NO;
    if (timer.userInfo) {
        NSDictionary *userInfo = (NSDictionary *)timer.userInfo;
        NSString *operation = [userInfo valueForKey:NoteAppDelegateOperationKey];
        id sender = [userInfo valueForKey:NoteAppDelegateSenderKey];
        if (operation == NoteAppDelegateOperationStore) {
            [self onStore:sender];
        }
    } else {
        int wordNum = [(NSNumber *)[analyticData valueForKey:@"word_num"] intValue];
        if (wordNum > PFNOTE_LARGE_FILE_WARNING_WORDNUM) {
            PFUTILS_showAlertMsg(
                                 PF_L10N(@"app_large_file_title"),
                                 PF_L10N(@"app_large_file_desciption"),
                                 PF_L10N(@"ok"),
                                 nil)    
            [FlurryAPI logEvent:@"large_file"];
        }
    }
}

-(IBAction) onPreview:(id)sender {
    DECLARE_PFNOTE_MODEL
    PFNOTE_CHECK_WRITING
    PFNOTE_APP_CHECK_POPOVER_AND_MODAL
    if (model.iPadMode) {
        //have to hide the statusbar here before showing the dialog
        [UIApplication sharedApplication].statusBarHidden = YES;
    }
    [FlurryAPI logEvent:@"preview" withParameters:[model.note getAnalyticData]];
    printerPanel.mode = NotePrinterPanelModePreview;
    [self presentModalViewController:printerPanel animated:NO];
}

-(void) onPreviewFinished {
    [displayPanel resetDisplayPanel];
}

-(void) onPrintFinished {
    [self checkUnpurchasedProducts:NO];
    
    [displayPanel resetDisplayPanel];
    DECLARE_PFNOTE_MODEL
    PFNote *note = model.note;
    [FlurryAPI endTimedEvent:@"print" withParameters:[note getAnalyticData]];

    MFMailComposeViewController *sender = [[MFMailComposeViewController alloc] init];
    sender.title = PF_L10N(@"app_sender_title");
    [sender setSubject:note.name];
    
    // Attach NOTE to the email
    NSData *noteData = [NSData dataWithContentsOfFile:note.path];
    [sender addAttachmentData:noteData mimeType:@"application/pettyfun-note" fileName:[note getFileName]];
    
    // Attach PDF to the email
    NSString *pdfPath = [note getPDFPath];
    NSData *pdfData = [NSData dataWithContentsOfFile:pdfPath];
    [sender addAttachmentData:pdfData mimeType:@"application/pdf" fileName:[note getPDFName]];
    
    // Fill out the email body text
    NSString *emailBody = NSFormat(PF_L10N(@"app_sender_body_%@"), PFNOTE_APP_URL);
    [sender setMessageBody:emailBody isHTML:YES];
    
    sender.mailComposeDelegate = self;
    [self presentModalViewController:sender animated:YES];    
    [sender release];
    [FlurryAPI logEvent:@"email" timed:YES];
}

-(void) mailComposeController:(MFMailComposeViewController*)controller 
          didFinishWithResult:(MFMailComposeResult)result 
                        error:(NSError *)error {
    NSLog(@"mailComposeController: result = %d, error = %@", result, error);
    [self dismissModalViewControllerAnimated:YES];
    [FlurryAPI endTimedEvent:@"email"
              withParameters:[NSDictionary dictionaryWithObjectsAndKeys:
                              [NSNumber numberWithInt:result], @"result",
                              error, @"error",
                              nil]];
    if (result == MFMailComposeResultSent) {
        [Appirater userDidSignificantEvent:YES];
    }
}

-(void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    DECLARE_PFNOTE_MODEL
    if (model.iPadMode && IPAD_SUPPORT_LANDSCAPE) {
        CGRect displayFrame, inputFrame, toolbarFrame;
        if (UIInterfaceOrientationIsPortrait(toInterfaceOrientation)) {
            if (!inputPanel.inputEnabled) {
                displayFrame = CGRectMake(0, 0, 768, 960);
                inputFrame = CGRectMake(0, 1004, 768, 300);
                toolbarFrame = CGRectMake(0, 960, 768, 44);
            } else {
                displayFrame = CGRectMake(0, 0, 768, 704);
                inputFrame = CGRectMake(0, 704, 768, 300);
                toolbarFrame = CGRectMake(0, 1004, 768, 44);
            }            
        } else {
            if (!inputPanel.inputEnabled) {
                displayFrame = CGRectMake(0, 0, 1024, 704);
                inputFrame = CGRectMake(0, 748, 1024, 300);
                toolbarFrame = CGRectMake(0, 704, 1024, 44);
            } else {
                displayFrame = CGRectMake(0, 0, 1024, 448);
                inputFrame = CGRectMake(0, 448, 1024, 300);
                toolbarFrame = CGRectMake(0, 748, 1024, 44);
            }            
        }
        if (adWhirlView) {
            displayFrame = CGRectMake(displayFrame.origin.x,
                                      displayFrame.origin.y + adWhirlView.frame.size.height,
                                      displayFrame.size.width,
                                      displayFrame.size.height - adWhirlView.frame.size.height);
        }
        displayView.frame = displayFrame;
        inputView.frame = inputFrame;
        toolbar.frame = toolbarFrame;
        displayPanel.view.frame = CGRectMake(0, 0, displayFrame.size.width, displayFrame.size.height);
        inputPanel.view.frame = CGRectMake(0, 0, inputFrame.size.width, inputFrame.size.height);
        [inputPanel resizeInputPanel:inputFrame.size];
        
        CGRect numberFrame = CGRectMake(0.0f, 0.0f,
                                        inputFrame.size.width,
                                        toolbarFrame.size.height);
        [pageNumberView updateWithFrame:numberFrame];

    }
    [displayPanel resetDisplayPanel];
    [inputPanel resetInputPanel];
}

-(void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    if (adWhirlView) {
        [adWhirlView rotateToOrientation:self.interfaceOrientation];
    }
    DECLARE_PFNOTE_MODEL
    if (model.iPadMode && IPAD_SUPPORT_LANDSCAPE) {
        [self _resizeAdWhirlView:nil];
        [self onConfigUpdate];
    }
}

-(BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    DECLARE_PFNOTE_MODEL
    return [model shouldAutorotateToInterfaceOrientation:interfaceOrientation
                                        supportLandscape:YES];
}

#pragma mark -
#pragma mark Specific Methods

-(BOOL) deleteFile:(NSString *)path backup:(BOOL)backup {
    DECLARE_PFNOTE_MODEL
    if ([model.note.path isEqualToString:path]) {
        PFUTILS_showAlertMsg(PF_L10N(@"app_message"),
                             PF_L10N(@"app_select_same_file"),
                             PF_L10N(@"ok"), nil);
        return NO;
    } else{
        if (backup) {
            DECLARE_PFUTILS
            [utils backupFile:path toFolderInDocument:PFITEM_BACKUP_FOLDER prefix:PFITEM_BACKUP_PREFIX];
        }
        NSFileManager *fileManager = [NSFileManager defaultManager];
        [fileManager removeItemAtPath:path error:NULL];
        return YES;
    }
}
 
-(void) onBrowseDialogLoad:(NSString *)path {
    [self hideSubView:YES];
    DECLARE_PFUTILS
    [utils showProgressHUD:self.view withText:PF_L10N(@"app_loading")];
    PFUTILS_delayWithInterval(PFNOTE_OPERATION_DELAY, path, loadNote:);        
}

-(void) loadNote:(NSTimer *)timer {
    DECLARE_PFUTILS
    DECLARE_PFNOTE_MODEL
    NSString *path = (NSString *)(timer.userInfo);
    if ([model.note.path isEqualToString:path]) {
        PFUTILS_showAlertMsg(PF_L10N(@"app_message"),
                             PF_L10N(@"app_select_same_file"),
                             PF_L10N(@"ok"), nil);
    }else {
        [model loadNote:path];
        [FlurryAPI logEvent:@"load" withParameters:[model.note getAnalyticData]];
        [inputPanel resetInputPanel];
        [displayPanel refreshDisplayPanel];
    }
    [utils hideProgressHUD];
    [self checkUnpurchasedProducts:NO];
}

-(void) onPageUpdate:(int)currentPageIndex pageNum:(int)pageNum {
    if (inputPanel.inputEnabled) {
        [inputPanel onPageUpdate:currentPageIndex pageNum:pageNum];
    } else {
        pageNumberView.currentPageNumber = currentPageIndex;
        pageNumberView.totalPageNumber = pageNum;
        [pageNumberView setNeedsDisplay];
    }
}

-(void) onConfigUpdate {
    DECLARE_PFNOTE_MODEL
    DECLARE_PFNOTE_PAINTER_FACTORY
    PFNoteTheme *theme = [painterFactory getThemeByType:model.config.themeType];
    [self updateWithTheme:theme];
    [inputPanel updateWithTheme:theme];
    [displayPanel updateWithTheme:theme];
    pageNumberView.theme = theme;
    [pageNumberView setNeedsDisplay];
}

-(void) updateWithTheme:(PFNoteTheme *)theme {
    [self _initPageNumberView];    

    DECLARE_PFNOTE_MODEL
    PFNoteThemeImage toolbarImage = [model iPadLandScape] ? PFNoteThemeImageToolBarIPadLandscape
                                                          : PFNoteThemeImageToolBar;
    ((PFToolBar *)toolbar).backgroundImage = [theme getImage:toolbarImage];
    [theme updateButtonImage:PFNoteThemeImageToggelInput button:toggleInputButton];
    [theme updateButtonImage:PFNoteThemeImageSetup button:setupButton];
    [theme updateButtonImage:PFNoteThemeImageStore button:storeButton];
    [theme updateButtonImage:PFNoteThemeImageBrowse button:browseButton];
    [toolbar setNeedsLayout];
    [toolbar setNeedsDisplay];
    
    pageNumberView.theme = theme;
    [pageNumberView setNeedsDisplay];
}
     
-(UIView *) _getAdView {
    DECLARE_PFUTILS
    int imageIndex = [utils getRandomInt:PFNOTE_AD_IMAGE_NUM];
    NSString *adImageName = [NSString stringWithFormat:@"ad_%d", imageIndex];
    UIImage *adImage = [UIImage imageWithContentsOfFile:
                              [[NSBundle mainBundle] 
                               pathForResource:adImageName
                               ofType:@"png"]];
    UIButton *result = [UIButton buttonWithType:UIButtonTypeCustom];
    [result setImage:adImage forState:UIControlStateNormal];
    result.frame = CGRectMake(0, 0, adImage.size.width, adImage.size.height);
    [result addTarget:self action:@selector(onAdClick:) forControlEvents:UIControlEventTouchUpInside];
    return result;
}

-(void) onAdClick:(id)sender {
    [self onStore:sender];
}

#pragma mark -
#pragma mark adWhirl delegate
-(void) _initAdWhirl:(NSTimer *)timer {
    DECLARE_PFNOTE_MODEL
    if ([model hadPurchased:NOTE_PRODUCT_ADFREE withType:PFNoteProductTypeGeneral]) {
        return;
    }
    if (adWhirlView) return;
    adWhirlView = [[AdWhirlView requestAdWhirlViewWithDelegate:self] retain];
    [adWhirlView replaceBannerViewWith:[self _getAdView]];
    [self.view addSubview:adWhirlView];
    [self _resizeAdWhirlView:nil];
}

- (NSString *)adWhirlApplicationKey {
    NSString *adWhirlKey = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"AdWhirlKey"];
    return adWhirlKey;
}

- (UIViewController *)viewControllerForPresentingModalView {
    return self;
}

-(void)adWhirlDidReceiveAd:(AdWhirlView *)adView {
    PFUTILS_delayWithInterval(PFNOTE_AD_DELAY, nil, _resizeAdWhirlView:);
}

-(void) onNoAdPurchased: (NSNotification *)notification {
    if (adWhirlView) {
        PFUTILS_delayWithInterval(0.0f, nil, _resizeAdWhirlView:);
    }
}

-(void) _resizeAdWhirlView:(NSTimer *) timer {
    if (!adWhirlView) {
        return;
    }
    DECLARE_PFNOTE_MODEL
    if (model.writing || self.modalViewController) {
        //(popoverController && popoverController.popoverVisible)||
        PFUTILS_delayWithInterval(PFNOTE_AD_DELAY, nil, _resizeAdWhirlView:);
        return;
    }
    CGRect newAdFrame = CGRectZero;
    float displayViewOriginY = displayView.frame.origin.y;
    if ([model hadPurchased:NOTE_PRODUCT_ADFREE withType:PFNoteProductTypeGeneral]) {
        displayViewOriginY = newAdFrame.origin.y;
        [adWhirlView removeFromSuperview];
        [adWhirlView release];
        adWhirlView = nil;
    } else {
        CGSize adSize = [adWhirlView actualAdSize];
        CGFloat windowWidth = [model getWindowSize].width;
        CGFloat adOriginY = model.iPadMode ? 20 : 0;
        adOriginY = 0; //Since iOS 5.0, seems the original y is changed
        newAdFrame = CGRectMake((windowWidth - adSize.width) / 2.0f,
                                adOriginY,
                                adSize.width,
                                adSize.height);
    }
    if (adWhirlView && !adWhirlView.hidden) {
        displayViewOriginY = newAdFrame.origin.y + newAdFrame.size.height;
    }
    CGFloat displayViewHeight = displayView.frame.size.height 
                                + displayView.frame.origin.y
                                - displayViewOriginY;
    CGRect newDisplayViewFrame = CGRectMake(displayView.frame.origin.x,
                                            displayViewOriginY,
                                            displayView.frame.size.width,
                                            displayViewHeight);
    if (adWhirlView) {
        adWhirlView.frame = newAdFrame;
        self.view.backgroundColor = [UIColor blackColor]; //iOS5, reason unknown
    }
    displayView.frame = newDisplayViewFrame;
    [displayPanel resetDisplayPanel];
}

#pragma mark - Universal related
-(void) showSubView:(UIViewController *)contentViewControllor sender:(id)sender {
    DECLARE_PFNOTE_MODEL
    if (model.iPadMode) {
        if (popoverController && popoverController.popoverVisible) return;
        popoverController = [[UIPopoverController alloc]
                             initWithContentViewController:contentViewControllor];
        if ([[sender class] isSubclassOfClass:[UIBarButtonItem class]]) {
            [popoverController presentPopoverFromBarButtonItem:(UIBarButtonItem *)sender
                                      permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        } else if ([[sender class] isSubclassOfClass:[UIButton class]]) {
            [popoverController presentPopoverFromRect:((UIButton *)sender).frame
                                               inView:[(UIButton *)sender superview]
                             permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        }
    } else {
        [self presentModalViewController:contentViewControllor animated:YES];
    }
}

-(void) showSubView:(UIViewController *)contentViewControllor size:(CGSize)contentSize sender:(id)sender {
    DECLARE_PFNOTE_MODEL
    if (model.iPadMode) {
        if (popoverController && popoverController.popoverVisible) return;
        popoverController = [[UIPopoverController alloc]
                             initWithContentViewController:contentViewControllor];
        popoverController.popoverContentSize = contentSize;
        if ([[sender class] isSubclassOfClass:[UIBarButtonItem class]]) {
            [popoverController presentPopoverFromBarButtonItem:(UIBarButtonItem *)sender
                                      permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        } else if ([[sender class] isSubclassOfClass:[UIButton class]]) {
            [popoverController presentPopoverFromRect:((UIButton *)sender).frame
                                               inView:[(UIButton *)sender superview]
                             permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        }
    } else {
        [self presentModalViewController:contentViewControllor animated:YES];
    }
}

-(void) hideSubView:(BOOL)iPhoneAnimated {
    DECLARE_PFNOTE_MODEL
    if (model.iPadMode) {
        [popoverController dismissPopoverAnimated:YES]; \
        [popoverController release]; \
        popoverController = nil;
    } else {
        [self dismissModalViewControllerAnimated:iPhoneAnimated];
    }
}

@end

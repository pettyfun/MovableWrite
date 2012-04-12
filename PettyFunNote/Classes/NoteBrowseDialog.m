    //
//  NoteSaveDialog.m
//  PettyFunNote
//
//  Created by YJ Park on 11/20/10.
//  Copyright 2010 PettyFun. All rights reserved.
//

#import "NoteBrowseDialog.h"
#import "PFNoteModel.h"
#import "PFUtils.h"

NSString *const NoteSaveDialogOperationNew = @"new";
NSString *const NoteSaveDialogOperationLoad = @"load";
NSString *const NoteSaveDialogOperationSend = @"send";
NSString *const NoteSaveDialogOperationStore = @"store";

@implementation NoteBrowseDialog
@synthesize delegate;

-(void) removeTestButton {
    NSMutableArray *items = [toolbar.items mutableCopyWithZone:nil];
    [items removeObject:testButton];
    toolbar.items = items;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initLoadView];

    //PF_L10N_VIEW(1001, @"browse_help");
    [helpButton setTitle:PF_L10N(@"browse_help")];

    PF_L10N_VIEW(101, @"save_note_name");
    PF_L10N_VIEW(201, @"save_your_name");
    
#ifdef DEBUG
    if (!PFNOTE_ENABLE_DEBUG_UI) {
        [self removeTestButton];
    }
#else
    [self removeTestButton];
#endif
    
    UIColor *backgroundColor = PFNOTE_POPUP_BACKGROUDCOLOR;
    self.view.backgroundColor = backgroundColor;
    
    UIColor *textColor = PFNOTE_POPUP_TEXTCOLOR;
    PF_SET_LABEL_TEXTCOLOR(101, textColor)
    PF_SET_LABEL_TEXTCOLOR(201, textColor)
    
    nameField.delegate = self;
    authorField.delegate = self;
}

- (void) initLoadView {
    DECLARE_PFUTILS
    NSString *rootPath = [utils getPathInDocument:PFITEM_DATA_FOLDER];
    fileNavController = [[PFFileNavController alloc]
                         initWithStyle:UITableViewStyleGrouped
                              rootPath:rootPath];
    DECLARE_PFNOTE_MODEL
    [model refreshNoteIndexForFolders];
    fileNavController.nameMap = model.noteIndex;
    fileNavController.operation = PFFileNavController_LOAD;
    fileNavController.validType = [model.note getItemType];
    fileNavController.doubleSelectToOperate = YES;
    fileNavController.innerViewMode = YES;
    fileNavController.delegate = self;
    fileNavController.view.frame = CGRectMake(0.0f, 0.0f,
                loadView.frame.size.width,
                loadView.frame.size.height);
    [loadView addSubview:fileNavController.view];
    fileNavController.navigationBar.barStyle = UIBarStyleBlackOpaque;
}

- (void)viewDidUnload {
    [fileNavController.view removeFromSuperview];
    
    [super viewDidUnload];
}

- (void)releaseViewElements {
    [super releaseViewElements];
    PF_Release_And_Nil(fileNavController)
    PF_Release_IBOutlet(nameField)
    PF_Release_IBOutlet(authorField)

    PF_Release_IBOutlet(testButton)
    PF_Release_IBOutlet(toolbar)
    
    PF_Release_IBOutlet(helpButton)
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    DECLARE_PFNOTE_MODEL
    nameField.text = model.note.name;
    if (model.note.author) {
        authorField.text = model.note.author;
    } else {
        DECLARE_PFUTILS
        authorField.text = [utils getDefault:NOTE_DEFAULT_AUTHOR];
    }
    if (fileNavController.innerViewMode) {
        [fileNavController.visibleViewController viewDidAppear:animated];
    }
}

-(BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    DECLARE_PFNOTE_MODEL
    return [model shouldAutorotateToInterfaceOrientation:interfaceOrientation];
}

#pragma mark -
#pragma mark Specific Methods

-(IBAction) onSave:(id)sender {
    DECLARE_PFNOTE_MODEL
    NSString *name = [nameField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if ([name length] <= 0) {
        PFUTILS_showAlertMsg(PF_L10N(@"app_error"),
                             PF_L10N(@"save_non_empty_name"),
                             PF_L10N(@"ok"), nil);
        return;
    }
    DECLARE_PFUTILS
    NSString *author = [authorField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    BOOL needSave = NO;
    if (![name isEqual:model.note.name]) {
        model.note.name = name;
        needSave = YES;
    }
    if (![author isEqual:model.note.author]) {
        model.note.author = author;
        needSave = YES;
    }
    if (needSave) {
        model.note.needSave = YES;
    }
    [utils setDefault:author forKey:NOTE_DEFAULT_AUTHOR];
    if (delegate) {
        [delegate onBrowseDialogSave];
    }
}

-(IBAction) onCancel:(id)sender {
    if (delegate) {
        [delegate onBrowseDialogFinished];
    }
}

-(IBAction) onDelete:(id)sender {
    PFUTILS_showAlertDlg(
                         PF_L10N(@"save_delete_title"),
                         PF_L10N(@"save_delete_description"),
                         PF_L10N(@"ok"),
                         PF_L10N(@"cancel"),
                         self)    
}

-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex != [alertView cancelButtonIndex]) {
        [delegate onBrowseDialogDelete];
    }
}

-(void) navFinished:(PFFileNavController *)navController {
    if (navController.selectedPath) {
        [delegate onBrowseDialogLoad:navController.selectedPath];
    }
}

-(IBAction) onNew:(id)sender {
    [delegate onBrowseDialogNew];
}

-(IBAction) onArchive:(id)sender {
    [delegate onBrowseDialogArchive];
}

-(IBAction) onSend:(id)sender {
    [delegate onBrowseDialogSend];
}

-(IBAction) onHelp:(id)sender {
    [delegate onBrowseDialogHelp];
}

-(BOOL) deleteFile:(PFFileNavController *)navController path:(NSString *)path {
    DECLARE_PFNOTE_MODEL
    if ([model.note.path isEqualToString:path]) {
        PFUTILS_showAlertMsg(PF_L10N(@"app_message"),
                             PF_L10N(@"app_select_same_file"),
                             PF_L10N(@"ok"), nil);
        return NO;
    } else{
        DECLARE_PFUTILS
        [utils backupFile:path toFolderInDocument:PFITEM_BACKUP_FOLDER prefix:PFITEM_BACKUP_PREFIX];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        [fileManager removeItemAtPath:path error:NULL];
        return YES;
    }
}

-(BOOL) canSelectFile:(PFFileNavController *)navController path:(NSString *)path {
    DECLARE_PFNOTE_MODEL
    return ![model.note.path isEqualToString:path];
}

-(void) updateStyle:(PFFileNavController *)navController
         controller:(PFFolderViewController *)controller {
}

-(IBAction) onTest:(id)sender {
#ifdef DEBUG
    if (PFNOTE_ENABLE_DEBUG_UI) {
        DECLARE_PFNOTE_MODEL
        PFNote *savedNote = [model.note copy];
        for (int i = 0; i < 4; i++) {
            for (PFNoteParagraph *p in [savedNote getChapter].paragraphes) {
                [[model.note getChapter].paragraphes addObject:[p copy]];
            }
        }
        model.note.name = NSFormat(@"%@ x5", model.note.name);
        [model.note resetUUID];
        [model.note resetPath:NOTE_FOLDER_INBOX];        
        model.note.needSave = YES;
        [model saveNote];
    }
#endif
}

-(NSString *) getOperationTitle:(PFFileNavController *)navController {
    if (navController.operation == PFFileNavController_LOAD) {
        return PF_L10N(@"browse_load");
    }
    return nil;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == nameField) {
        [authorField becomeFirstResponder];
    } else if (textField == authorField) {
        [self onSave:textField];
    }
    return NO;
}

@end

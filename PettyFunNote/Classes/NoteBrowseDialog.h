//
//  NoteSaveDialog.h
//  PettyFunNote
//
//  Created by YJ Park on 11/20/10.
//  Copyright 2010 PettyFun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PFFileNavController.h"

@protocol NoteBrowseDialogDelegate<NSObject>
@required
-(void) onBrowseDialogFinished;
-(void) onBrowseDialogSave;
-(void) onBrowseDialogLoad:(NSString *)path;
-(void) onBrowseDialogNew;
-(void) onBrowseDialogSend;
-(void) onBrowseDialogDelete;
-(void) onBrowseDialogArchive;
-(void) onBrowseDialogHelp;
@end

@interface NoteBrowseDialog : PFViewController <UIAlertViewDelegate, PFFileNavDelegate, UITextFieldDelegate> {
    IBOutlet UITextField *nameField;
    IBOutlet UITextField *authorField;
    
    id<NoteBrowseDialogDelegate> delegate;
    
    IBOutlet UIToolbar *toolbar;
    IBOutlet UIBarButtonItem *testButton;
    
    IBOutlet UIView *loadView;
    PFFileNavController *fileNavController;
    
    IBOutlet UIBarButtonItem *helpButton;
}
@property (nonatomic, assign) id<NoteBrowseDialogDelegate> delegate;

-(IBAction) onDelete:(id)sender;
-(IBAction) onSave:(id)sender;
-(IBAction) onCancel:(id)sender;
-(IBAction) onNew:(id)sender;
-(IBAction) onSend:(id)sender;
-(IBAction) onArchive:(id)sender;

-(IBAction) onHelp:(id)sender;

-(IBAction) onTest:(id)sender;

- (void) initLoadView;

@end

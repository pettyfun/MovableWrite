//
//  NoteRedeemDialog.h
//  PettyFunNote
//
//  Created by YJ Park on 3/13/11.
//  Copyright 2011 PettyFun.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol NoteRedeemDialogDelegate<NSObject>
@required
-(void) onRedeemDialogRedeem:(NSString *)giftcode;
-(void) onRedeemDialogCancelled;
@end


@interface NoteRedeemDialog : PFViewController <UITextFieldDelegate> {
    IBOutlet UITextField *giftcodeField;
    
    id<NoteRedeemDialogDelegate> delegate;
}
@property (nonatomic, assign) IBOutlet id<NoteRedeemDialogDelegate> delegate;

-(IBAction) onOK:(id)sender;
-(IBAction) onCancel:(id)sender;

@end

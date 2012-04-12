//
//  NoteRedeemDialog.m
//  PettyFunNote
//
//  Created by YJ Park on 3/13/11.
//  Copyright 2011 PettyFun.com. All rights reserved.
//

#import "NoteRedeemDialog.h"
#import "PFUtils.h"
#import "PFNoteModel.h"

@implementation NoteRedeemDialog
@synthesize delegate;

- (void)dealloc {
    [super dealloc];
}

#pragma mark - View lifecycle

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    PF_L10N_VIEW(101, @"redeem_description");
    PF_L10N_VIEW(102, @"redeem_giftcode");
    PF_L10N_VIEW(201, @"ok");
    PF_L10N_VIEW(202, @"cancel");
    DECLARE_PFUTILS
    [utils setupGrayButton:self.view tag:201];
    [utils setupGrayButton:self.view tag:202];
    
    UIColor *backgroundColor = PFNOTE_POPUP_BACKGROUDCOLOR;
    self.view.backgroundColor = backgroundColor;
    PF_SET_VIEW_BACKGROUNDCOLOR(101, backgroundColor);

    UIColor *textColor = PFNOTE_POPUP_TEXTCOLOR;
    PF_SET_TEXTVIEW_TEXTCOLOR(101, textColor)
    PF_SET_LABEL_TEXTCOLOR(102, textColor)

    giftcodeField.delegate = self;
}

- (void)releaseViewElements {
    [super releaseViewElements];
    PF_Release_IBOutlet(giftcodeField);
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    giftcodeField.text = @"";
    [giftcodeField becomeFirstResponder];
}

-(void)viewDidDisappear:(BOOL)animated {
    [giftcodeField resignFirstResponder];
    [super viewDidDisappear:animated];
    [delegate onRedeemDialogCancelled];
}

-(IBAction) onOK:(id)sender {
    NSString *giftcode = [giftcodeField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (![giftcode isEqual:@""]) {
        [delegate onRedeemDialogRedeem:giftcodeField.text];
    } else {
        [giftcodeField becomeFirstResponder];
    }
}

-(IBAction) onCancel:(id)sender {
    [delegate onRedeemDialogCancelled];
}


- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
    [self onOK:nil];
    return YES;
}

-(BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    DECLARE_PFNOTE_MODEL
    return [model shouldAutorotateToInterfaceOrientation:interfaceOrientation];
}

@end

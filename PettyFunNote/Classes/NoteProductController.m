    //
//  NoteProductController.m
//  PettyFunNote
//
//  Created by YJ Park on 12/12/10.
//  Copyright 2010 PettyFun. All rights reserved.
//
#import "FlurryAPI.h"

#import "PFUtils.h"
#import "NoteProductController.h"
#import "PFNoteModel.h"

@implementation NoteProductController
@synthesize productInfo;

-(void) dealloc {
    [productInfo release];
    [super dealloc];
}

-(void) setProductInfo:(NSDictionary *)newProductInfo {
    if (productInfo) {
        [productInfo release];
    }
    productInfo = [newProductInfo retain];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onProductPurchased:)
                                                 name:[productInfo valueForKey:NOTE_PRODUCT_KEY]
                                               object:nil];
}

-(void) onBuy {
    DECLARE_PFNOTE_MODEL
    if ([model hadPurchased:[productInfo valueForKey:NOTE_PRODUCT_KEY]]) {
        PFUTILS_showAlertMsg(
                             PF_L10N(@"store_purchased_product_title"),
                             NSFormat(PF_L10N(@"store_purchased_product_desciption_%@"),
                                      [productInfo valueForKey:NOTE_PRODUCT_TITLE]),
                             PF_L10N(@"ok"),
                             nil)    
    } else if (![productInfo valueForKey:NOTE_PRODUCT_SKPRODUCT]) {
        PFUTILS_showAlertMsg(
                             PF_L10N(@"store_invalid_product_title"),
                             NSFormat(PF_L10N(@"store_invalid_product_desciption_%@"),
                                      [productInfo valueForKey:NOTE_PRODUCT_TITLE]),
                             PF_L10N(@"ok"),
                             nil)        
    } else if ([SKPaymentQueue canMakePayments]) {        
        PFUTILS_showAlertDlg(
                             PF_L10N(@"store_confirm_title"),
                             NSFormat(PF_L10N(@"store_confirm_desciption_%@"),
                                      [productInfo valueForKey:NOTE_PRODUCT_TITLE]),
                             PF_L10N(@"ok"),
                             PF_L10N(@"cancel"),
                             self)    
    } else {
        [model logProductEvent:@"unavailable:" productInfo:productInfo];
        PFUTILS_showAlertMsg(
                             PF_L10N(@"store_unavailable_title"),
                             PF_L10N(@"store_unavailable_description"),
                             PF_L10N(@"ok"),
                             nil)    
    }
}

-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    PFDebug(@"BUY IT %d", buttonIndex);    
    NSString *productKey = [productInfo valueForKey:NOTE_PRODUCT_KEY];
    DECLARE_PFNOTE_MODEL
    if (buttonIndex != [alertView cancelButtonIndex]) {
        SKProduct *product = [productInfo valueForKey:NOTE_PRODUCT_SKPRODUCT];
        if (product) {
            [model logProductEvent:@"buy:" productKey:productKey];
            SKPayment *payment = [SKPayment paymentWithProduct:product];
            [[SKPaymentQueue defaultQueue] addPayment:payment];
        } else {
            [model logProductEvent:@"invalid:" productKey:productKey];
        }
    } else {
        [model logProductEvent:@"cancel:" productKey:productKey];
    }
}

-(void) onProductPurchased:(NSNotification *)notification {
}

-(BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    DECLARE_PFNOTE_MODEL
    return [model shouldAutorotateToInterfaceOrientation:interfaceOrientation];
}

@end

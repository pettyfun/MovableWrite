//
//  NoteStoreController.h
//  PettyFunNote
//
//  Created by YJ Park on 12/12/10.
//  Copyright 2010 PettyFun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <StoreKit/StoreKit.h>
#import "NoteProductController.h"
#import "NotePreviewController.h"
#import "NoteRedeemDialog.h"
#import "PFHTTPRequest.h"
#import "PFHTTPAccessor.h"
#import "FlurryAdDelegate.h"

#define PFNOTE_STORE_PREVIEW_DELAY 0.0f
#define PFNOTE_STORE_REQUEST_TIMEOUT 30.0f

@protocol NoteStoreDelegate<NSObject>
@required
-(void) onStoreClosed;
@end

@interface NoteStoreController : NoteProductController
  <SKPaymentTransactionObserver, SKProductsRequestDelegate,
    NoteRedeemDialogDelegate, PFHTTPRequestDelegate, FlurryAdDelegate> {
    id<NoteStoreDelegate> delegate;
    
    IBOutlet UITableView *storeTable;
    
    NSArray *availableProducts;
    
    UIPopoverController *popoverController;
    IBOutlet NoteRedeemDialog *redeemDialog;

    IBOutlet NotePreviewController *previewController;
      
    SKProductsRequest *skProductsRequest;
    PFHTTPAccessor *httpAccessor;
        
    IBOutlet UIView *appCircleView;
    UIView *appCircleBanner;
}
@property (nonatomic, assign) id<NoteStoreDelegate> delegate;

-(IBAction) onClose:(id)sender;
-(IBAction) onRedeem:(id)sender;

-(void) resetProducts;
-(void) reloadProducts;
-(void) onPreview;

- (void) requestProductsData;

- (void)completeTransaction:(SKPaymentTransaction *)transaction;
- (void)failedTransaction:(SKPaymentTransaction *)transaction;
- (void)restoreTransaction:(SKPaymentTransaction *)transaction;

-(void) _notifyDelegate;
-(void) _updateCell:(UITableViewCell *) cell withProduct:(NSDictionary *)oneProductInfo;

@end

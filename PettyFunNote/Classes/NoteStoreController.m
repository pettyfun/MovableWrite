//
//  NoteStoreController.m
//  PettyFunNote
//
//  Created by YJ Park on 12/12/10.
//  Copyright 2010 PettyFun. All rights reserved.
//

#import "FlurryAPI.h"
#import "FlurryAPI+AppCircle.h"

#import "PFUtils.h"
#import "NoteStoreController.h"
#import "PFNoteModel.h"
#import "PFNotePainterFactory.h"

@implementation NoteStoreController
@synthesize delegate;

-(void) dealloc {
    [availableProducts release];
    [previewController release];
    [skProductsRequest release];
    [super dealloc];
}

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = PF_L10N(@"store_title");
    self.navigationItem.leftBarButtonItem = \
    [[[UIBarButtonItem alloc] initWithTitle:
      PF_L10N(@"done") style:UIBarButtonItemStyleDone target:self action:@selector(onClose:)] autorelease];        
    self.navigationItem.rightBarButtonItem = \
    [[[UIBarButtonItem alloc] initWithTitle:
      PF_L10N(@"store_redeem") style:UIBarButtonItemStyleDone target:self action:@selector(onRedeem:)] autorelease];   
    httpAccessor = [[PFHTTPAccessor alloc] init];
    
    DECLARE_PFNOTE_MODEL
    appCircleBanner = [[FlurryAPI getHook:@"Movable_Write_Store" 
                                     xLoc:0
                                     yLoc:0
                                     view:appCircleView
                             attachToView:YES
                              orientation:model.iPadMode ? @"portrait" : @"landscape"
                        canvasOrientation:model.iPadMode ? @"portrait" : @"landscapeRight" 
                              autoRefresh:YES
                           canvasAnimated:YES
                            rewardMessage:PF_L10N(@"store_appcircle_message") 
                              userCookies:nil
                        ] retain];
}

- (void)releaseViewElements {
    [super releaseViewElements];
    [appCircleBanner release];
    appCircleBanner = nil;
    PF_Release_IBOutlet(appCircleView);
    PF_Release_IBOutlet(storeTable)
    PF_Release_IBOutlet(previewController)
    PF_Release_IBOutlet(redeemDialog);
    [httpAccessor cancelAllRequests];
    PF_Release_And_Nil(httpAccessor)
}


-(void) viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    if (skProductsRequest) {
        [skProductsRequest cancel];
        [skProductsRequest release];
        skProductsRequest = nil;
    }
    
    DECLARE_PFUTILS
    [utils hideProgressHUD];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self reloadProducts];
    [FlurryAPI updateHook:appCircleBanner];
}
 
- (void)reloadProducts {
    if (availableProducts) {
        return;
    }
    DECLARE_PFNOTE_MODEL
    availableProducts = [[model getAvailableProductKeys] retain];
    DECLARE_PFUTILS
    [utils showProgressHUDInView:storeTable withText:PF_L10N(@"store_getting_products")];
    [self requestProductsData];
}

-(BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    DECLARE_PFNOTE_MODEL
    return [model shouldAutorotateToInterfaceOrientation:interfaceOrientation];
}

#pragma mark -
#pragma mark Store related
-(void) resetProducts {
    if (availableProducts) {
        [availableProducts release];
        availableProducts = nil;
    }
}

- (void) requestProductsData {
    if (skProductsRequest) {
        return;
    }
    NSSet *productIdentifiers = [NSSet setWithArray:availableProducts];
    skProductsRequest = [[SKProductsRequest alloc]
                                 initWithProductIdentifiers:productIdentifiers];
    skProductsRequest.delegate = self;
    [skProductsRequest start];
    PFUTILS_delayWithInterval(PFNOTE_STORE_REQUEST_TIMEOUT, nil, onRequestTimeout:)
}

- (void)onRequestTimeout:(NSTimer *)timer {
    if (skProductsRequest) {
        [skProductsRequest cancel];
        [skProductsRequest release];
        skProductsRequest = nil;
        
        [storeTable reloadData];
        DECLARE_PFUTILS
        [utils hideProgressHUD];
        PFUTILS_showAlertMsg(
                             PF_L10N(@"store_failed_products_title"),
                             PF_L10N(@"store_failed_products_description"),
                             PF_L10N(@"ok"),
                             nil)    
    }
}

- (void)productsRequest:(SKProductsRequest *)request
     didReceiveResponse:(SKProductsResponse *)response {
    if (skProductsRequest) {
        DECLARE_PFNOTE_MODEL
        for (NSString *identifier in response.invalidProductIdentifiers) {
            [model onInvalidProductIdentifier:identifier];
        }
        for (SKProduct *product in response.products) {
            [model onSKProduct:product];
        }
        [skProductsRequest release];
        skProductsRequest = nil;
        [storeTable reloadData];
        DECLARE_PFUTILS
        [utils hideProgressHUD];
    }
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [availableProducts count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"StoreItemCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                       reuseIdentifier:CellIdentifier] autorelease];
        //cell.selectionStyle = UITableViewCellSelectionStyleNone;
        UILabel *priceLabel = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 150.0f, 37.0f)] autorelease];
        priceLabel.text = @"";
        priceLabel.textAlignment = UITextAlignmentCenter;
        priceLabel.textColor = [UIColor redColor];
        cell.accessoryView = priceLabel;
    }
    
    // Configure the cell...
    DECLARE_PFNOTE_MODEL
    NSString *productKey = [availableProducts objectAtIndex:indexPath.row];
    NSDictionary *oneProductInfo = [model getProductInfo:productKey];
    [self _updateCell:cell withProduct:oneProductInfo];    
    return cell;
}

-(void) _updateCell:(UITableViewCell *) cell withProduct:(NSDictionary *)oneProductInfo {
    cell.textLabel.text = [oneProductInfo valueForKey:NOTE_PRODUCT_TITLE];
    cell.detailTextLabel.text = [oneProductInfo valueForKey:NOTE_PRODUCT_DESCRIPTION];
    UILabel *priceLabel = (UILabel *)cell.accessoryView;
    priceLabel.text = [oneProductInfo valueForKey:NOTE_PRODUCT_PRICE];
    NSString *icon = [oneProductInfo valueForKey:NOTE_PRODUCT_ICON];
    if (icon && icon != NOTE_PRODUCT_NONE) {
        cell.imageView.image = [UIImage imageWithContentsOfFile:
                                [[NSBundle mainBundle] 
                                 pathForResource:icon 
                                 ofType:nil]];
    }
    
    /*
    //FOR Taking screen shots only (when in-app purchase not testable)
    priceLabel.text = @"$0.99";
    if ([[oneProductInfo valueForKey:NOTE_PRODUCT_NAME] isEqual:NOTE_PRODUCT_ADFREE]) {
        priceLabel.text = @"$1.99";
    }
    */
}


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DECLARE_PFNOTE_MODEL
    NSString *productKey = [availableProducts objectAtIndex:indexPath.row];
    [self setProductInfo:[model getProductInfo:productKey]];
    if ([model hadPurchased:productKey]) {
        PFUTILS_showAlertMsg(
                             PF_L10N(@"store_purchased_product_title"),
                             NSFormat(PF_L10N(@"store_purchased_product_desciption_%@"),
                                      [productInfo valueForKey:NOTE_PRODUCT_TITLE]),
                             PF_L10N(@"ok"),
                             nil)    
    } else if ([productInfo valueForKey:NOTE_PRODUCT_TYPE] == PFNoteProductTypeTheme) {
        [self onPreview];
    } else {
        [self onBuy];
    }
}

#pragma mark -
#pragma mark Event Handler
-(IBAction) onClose:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
    [self _notifyDelegate];
}

-(IBAction) onRedeem:(id)sender {
    DECLARE_PFNOTE_MODEL
    if (model.iPadMode) {
        if (popoverController) return;
        
        popoverController = [[UIPopoverController alloc]
                             initWithContentViewController:redeemDialog]; 
        popoverController.popoverContentSize = CGSizeMake(480, 350);
        CGRect rect = CGRectMake(
                                 storeTable.frame.size.width / 2.0f,               
                                 0, 10, 10);
        [popoverController presentPopoverFromRect:
         rect
                                           inView:storeTable
                         permittedArrowDirections:UIPopoverArrowDirectionAny
                                         animated:YES];
    } else {
        [self presentModalViewController:redeemDialog animated:YES];
    }
}

-(void) onPreview{
    DECLARE_PFUTILS
    [utils showProgressHUD:self.view withText:@""];
    [previewController setProductInfo:productInfo];
    PFUTILS_delayWithInterval(PFNOTE_STORE_PREVIEW_DELAY, nil, onDelayPreview:)
}
-(void) onDelayPreview:(NSTimer *)timer {
    [self.navigationController pushViewController:previewController animated:YES];
}

#pragma mark -
#pragma mark Internal Methods
-(void) _notifyDelegate {
    if (delegate) {
        [delegate onStoreClosed];
    }
}


#pragma mark -
#pragma mark SKPaymentTransactionObserver methods
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions {
    for (SKPaymentTransaction *transaction in transactions) {
        PFError(@"paymentQueue:updatedTransaction: %@", 
                [NSString stringWithFormat:
                 @"%@\nsktransaction_id:%@ product_id: %@, date:%@, state:%d",
                 transaction, transaction.transactionIdentifier,
                 transaction.payment.productIdentifier,
                 transaction.transactionDate,
                 transaction.transactionState]);
        switch (transaction.transactionState) {
            case SKPaymentTransactionStatePurchased:
                [self completeTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                [self failedTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                [self restoreTransaction:transaction];
            default:
                break;
        }
    }
}

- (void) completeTransaction: (SKPaymentTransaction *)transaction {
    // Your application should implement these two methods.
    DECLARE_PFNOTE_MODEL
    NSString *productKey = transaction.payment.productIdentifier;
    [model purchase:productKey];
    [model logProductEvent:@"complete:" productKey:productKey];
    // Remove the transaction from the payment queue.
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}

- (void) restoreTransaction: (SKPaymentTransaction *)transaction {
    DECLARE_PFNOTE_MODEL
    NSString *productKey = transaction.originalTransaction.payment.productIdentifier;
    [model purchase:productKey];
    [model logProductEvent:@"restore:" productKey:productKey];
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}

- (void) failedTransaction: (SKPaymentTransaction *)transaction {
    DECLARE_PFNOTE_MODEL
    NSString *productKey = transaction.payment.productIdentifier;
    [model logProductEvent:@"failed:" productKey:productKey];
    if (transaction.error.code != SKErrorPaymentCancelled) {
        // Optionally, display an error here.
        PFUTILS_showAlertMsg(
                             PF_L10N(@"store_failed_product_purchase_title"),
                             PF_L10N(@"store_failed_product_purchase_title_description_%@"),
                             PF_L10N(@"ok"),
                             nil)    
    }
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}

-(void) onProductPurchased:(NSNotification *)notification {
    [self resetProducts];
    [self reloadProducts];
    [storeTable reloadData];
}

#pragma mark - redeem related
-(void) onRedeemDialogRedeem:(NSString *)giftcode {
    [FlurryAPI logEvent:@"redeem_request"];
    
    NSString *device_id = [[UIDevice currentDevice] uniqueIdentifier];
    NSURL *url = [NSURL URLWithString:NSFormat(NOTE_REDEEM_URL_PATTERN, device_id, giftcode)];
    PFHTTPRequest *request = [PFHTTPRequest requestWithURL:url];
    request.delegate = self;
    [httpAccessor accessAsynchronous:request];
    [self onRedeemDialogCancelled];
}

-(void) onRedeemDialogCancelled {
    DECLARE_PFNOTE_MODEL
    if (model.iPadMode) {
        [popoverController dismissPopoverAnimated:YES];
        [popoverController release];
        popoverController = nil;
    } else {
        [redeemDialog dismissModalViewControllerAnimated:YES];
    }
}


- (void)requestDidSucceed:(PFHTTPRequest *)request
                 response:(PFHTTPResponse *)response {
    NSString *responseString = response.responseString;
    NSArray *lines = [responseString componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    BOOL ok = NO;
    for (NSString *line in lines) {
        NSString *value = [line  stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if ([value isEqual:@"ok"]){
            ok = YES;
            break;
        }
    }
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:request.url forKey:@"request"];
    [parameters setObject:responseString forKey:@"response"];
    if (!ok) {
        PFUTILS_showAlertMsg(
                             PF_L10N(@"store_redeem_failed_title"),
                             NSFormat(PF_L10N(@"store_redeem_failed_desciption_%@"),
                                      response.responseString),
                             PF_L10N(@"ok"),
                             nil)    
        [FlurryAPI logEvent:@"redeem_failed" withParameters:parameters];
        return;
    }
    
    DECLARE_PFNOTE_MODEL
    NSMutableArray *redeemedProducts = [NSMutableArray array];
    NSArray *availableProductKeys = [model getAvailableProductKeys];

    for (NSString *line in lines) {
        NSString *value = [line  stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if ([availableProductKeys containsObject:value]){
            [model unlock:value];
            [redeemedProducts addObject:[model getProductInfo:value]];
            [model logProductEvent:@"redeem:" productKey:value];
        }
    }
    if (redeemedProducts.count > 0) {
        NSString *productTitles = [model getProductTitles:redeemedProducts];
        PFUTILS_showAlertMsg(
                             PF_L10N(@"store_redeem_succeed_title"),
                             NSFormat(PF_L10N(@"store_redeem_succeed_desciption_%@"),
                                      productTitles),
                             PF_L10N(@"ok"),
                             nil)    
        [parameters setObject:productTitles forKey:@"products"];
        [FlurryAPI logEvent:@"redeem_succeed" withParameters:parameters];
    } else {
        PFUTILS_showAlertMsg(
                             PF_L10N(@"store_redeem_failed_title"),
                             NSFormat(PF_L10N(@"store_redeem_failed_desciption_%@"),
                                      PF_L10N(@"store_redeem_failed_no_new_products")),
                             PF_L10N(@"ok"),
                             nil)    
    }
}

- (void)requestDidFail:(PFHTTPRequest *)request
                 error:(NSError *)error {
    PFUTILS_showAlertMsg(
                         PF_L10N(@"store_redeem_failed_title"),
                         NSFormat(PF_L10N(@"store_redeem_failed_desciption_%@"),
                                  error),
                         PF_L10N(@"ok"),
                         nil)    
    [FlurryAPI logError:@"redeem_failed" message:@"" error:error];
}

#pragma mark - AppCircle delegate
- (void)canvasWillDisplay:(NSString *)hook {
    [self dismissModalViewControllerAnimated:NO];
    [self _notifyDelegate];
    [FlurryAPI logEvent:@"appcircle_canvas"];
}

- (void)takeoverWillDisplay:(NSString *)hook {
    [FlurryAPI logEvent:@"appcircle_takeover"];
}


@end


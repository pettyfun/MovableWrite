//
//  NoteProductController.h
//  PettyFunNote
//
//  Created by YJ Park on 12/12/10.
//  Copyright 2010 PettyFun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PFPageView.h"
#import "PFNote.h"

@interface NoteProductController : PFViewController 
  <UIAlertViewDelegate> {
    NSDictionary *productInfo;
}
@property (readonly) NSDictionary *productInfo;

-(void) setProductInfo:(NSDictionary *)newProductInfo;
-(void) onBuy;
-(void) onProductPurchased:(NSNotification *)notification;

@end

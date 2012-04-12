//
//  FileNavController.h
//  PettyFunNote
//
//  Created by YJ Park on 11/14/10.
//  Copyright 2010 PettyFun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PFFolderViewController.h"
#import "PFItemType.h"


#define DECLARE_PFFileNavController PFFileNavController *navController = (PFFileNavController *)self.navigationController;

extern NSString *const PFFileNavController_LOAD;

@class PFFileNavController;

@protocol PFFileNavDelegate<NSObject>
@required
-(void) navFinished:(PFFileNavController *)navController;
@optional
-(void) updateStyle:(PFFileNavController *)navController
         controller:(PFFolderViewController *)controller;
-(BOOL) canDeleteFile:(PFFileNavController *)navController;
-(BOOL) deleteFile:(PFFileNavController *)navController path:(NSString *)path;

-(BOOL) canSelectFile:(PFFileNavController *)navController path:(NSString *)path;
-(NSString *) getOperationTitle:(PFFileNavController *)navController;
@end

@interface PFFileNavController : UINavigationController {
    NSDictionary *nameMap;
    NSString *operation;
    NSString *selectedPath;
    PFItemType *validType;
    id<PFFileNavDelegate> delegate;
    
    BOOL innerViewMode;
    BOOL doubleSelectToOperate;
    UITableViewStyle tableStyle;
}

@property (nonatomic, retain) NSDictionary *nameMap;
@property (nonatomic, retain) NSString *operation;
@property (nonatomic, retain) NSString *selectedPath;
@property (nonatomic, retain) PFItemType *validType;
@property (nonatomic, assign) id<PFFileNavDelegate> delegate;
@property (assign) BOOL innerViewMode;
@property (assign) BOOL doubleSelectToOperate;
@property (assign) UITableViewStyle tableStyle;

-(id) initWithStyle:(UITableViewStyle)style rootPath:(NSString *)path;
-(BOOL) isValidFile:(NSString *)path;
-(BOOL) canDeleteFile;
-(BOOL) deleteFile:(NSString *)path;
-(void) finishNav;
-(void) updateStyle:(PFFolderViewController *)controller;

-(BOOL) canSelectFile:(NSString *)path;
-(void) pushToFolder:(NSString *)path;
-(NSString *) getOperationTitle;
@end

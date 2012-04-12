//
//  FolderViewController.h
//  PettyFunNote
//
//  Created by YJ Park on 11/14/10.
//  Copyright 2010 PettyFun. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PFFileNavController;

@interface PFFolderViewController : UITableViewController {
    NSString *path;
    NSMutableArray *folders;
    NSMutableArray *files;
    NSString *selectedItemRef;
    
    UIColor *labelTextColor;
}
@property (nonatomic, retain) UIColor *labelTextColor;

-(id) initWithStyle:(UITableViewStyle)style path:(NSString *)folderPath;
-(void) loadFolderFiles;
-(void) onOperate;

@end

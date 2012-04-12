//
//  FileNavController.m
//  PettyFunNote
//
//  Created by YJ Park on 11/14/10.
//  Copyright 2010 PettyFun. All rights reserved.
//

#import "PFFileNavController.h"

NSString *const PFFileNavController_LOAD = @"load";

@implementation PFFileNavController
@synthesize operation;
@synthesize nameMap;
@synthesize selectedPath;
@synthesize validType;
@synthesize delegate;
@synthesize innerViewMode;
@synthesize doubleSelectToOperate;
@synthesize tableStyle;

-(void) dealloc {
    [nameMap release];
    [operation release];
    [selectedPath release];
    [validType release];
    [super dealloc];
}

-(id) initWithStyle:(UITableViewStyle)style rootPath:(NSString *)path {
    self.tableStyle = style;
    PFFolderViewController *controller = [[[PFFolderViewController alloc] initWithStyle:self.tableStyle path:path] autorelease];
    self = [super initWithRootViewController:controller];
    delegate = nil;
    return self;
}

-(BOOL) isValidFile:(NSString *)path {
    BOOL result = YES;
    if (validType) {
        result = [validType isFileWithType:path];
    }
    return result;
}

-(BOOL) canSelectFile:(NSString *)path {
    if (delegate && ([delegate respondsToSelector:@selector(canSelectFile:path:)])) {
        return [delegate canSelectFile:self path:path];
    }
    return NO;
}

-(BOOL) canDeleteFile {
    if (delegate && ([delegate respondsToSelector:@selector(canDeleteFile:)])) {
        return [delegate canDeleteFile:self];
    }
    return NO;
}

-(BOOL) deleteFile:(NSString *)path {
    if (delegate && ([delegate respondsToSelector:@selector(deleteFile:path:)])) {
        return [delegate deleteFile:self path:path];
    }
    return NO;
}

-(void) finishNav {
    if (delegate && ([delegate respondsToSelector:@selector(navFinished:)])) {
        [delegate navFinished:self];
    }
}

-(void) updateStyle:(PFFolderViewController *)controller {
    if (delegate && ([delegate respondsToSelector:@selector(updateStyle:controller:)])) {
        [delegate updateStyle:self controller:controller];
    }
}

-(void) pushToFolder:(NSString *)path {
    PFFolderViewController *controller = [[[PFFolderViewController alloc] initWithStyle:self.tableStyle path:path] autorelease];
    [self pushViewController:controller animated:YES];
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    [super pushViewController:viewController animated:animated];
    if (innerViewMode) {
        [viewController viewDidAppear:YES];
    }
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated {
    UIViewController *viewController = [super popViewControllerAnimated:animated];
    if (innerViewMode) {
        [self.topViewController viewDidAppear:YES];
    }
    return viewController;
}

-(NSString *) getOperationTitle {
    if (delegate && ([delegate respondsToSelector:@selector(getOperationTitle:)])) {
        NSString *title = [delegate getOperationTitle:self];
        if (title) {
            return title;
        }
    }
    if (self.operation == PFFileNavController_LOAD) {
        return PF_UTILS_L10N(@"file_load");
    }
    return PF_UTILS_L10N(@"file_operate");
}

@end

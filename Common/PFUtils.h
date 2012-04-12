//
//  PFUtils.h
//  PettyFunNote
//
//  Created by YJ Park on 11/9/10.
//  Copyright 2010 PettyFun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MBProgressHUD.h"
#import "UIColor-Expanded.h"

#define PF_COMMON_RESOURCE @"Common-Resources"

#define PF_PI 3.14159265359f
#define PF_GOLDEN 0.618f
/*
 Showing file name and line number in NSLog, based on:
 http://www.xm5design.com/?p=124
 A more complex one (with thread info), may be useful in the future.
 http://www.cocoacrumbs.com/blog/?p=69
 */
#define PFLog(format, ...) \
NSLog(@"[%s][%d] " format, [[@__FILE__ lastPathComponent] UTF8String], __LINE__, ##__VA_ARGS__);

#define PFCritical PFLog

//#define PFDebug PFLog
#define PFDebug(format, ...) 

#define PFTimeDebug PFLog

#define PFError PFLog

#define NSFormat(...) \
[NSString stringWithFormat:__VA_ARGS__]

#define PF_Release_IBOutlet(viewID) \
    [viewID release]; \
    viewID = nil;

#define PF_Release_And_Nil(objID) \
[objID release]; \
objID = nil;

#define PF_UTILS_L10N(l10nKey) [[PFUtils getInstance].l10n localizedStringForKey:l10nKey value:l10nKey table:nil]

#define DECLARE_PFUTILS PFUtils *utils = [PFUtils getInstance];

#define PFUTILS_delayWithInterval(delay, userInfoValue, selectorName) \
[NSTimer scheduledTimerWithTimeInterval:delay \
                                 target:self \
                               selector:@selector(selectorName) \
                               userInfo:userInfoValue \
                                repeats:NO]; 

#define PFUTILS_showAlertMsg(titleValue, messageValue, buttonTitle, delegateValue) \
UIAlertView *_alertView = [[UIAlertView alloc] \
                              initWithTitle:titleValue message:messageValue \
                              delegate:delegateValue \
                              cancelButtonTitle:buttonTitle \
                              otherButtonTitles:nil]; \
[_alertView show]; \
[_alertView release];

#define PFUTILS_showAlertDlg(titleValue, messageValue, okTitle, cancelTitle, delegateValue) \
UIAlertView *_alertView = [[UIAlertView alloc] \
initWithTitle:titleValue message:messageValue \
delegate:delegateValue \
cancelButtonTitle:cancelTitle \
otherButtonTitles:okTitle, nil]; \
[_alertView show]; \
[_alertView release];

@interface PFUtils : NSObject {
    //l10n
    NSBundle *l10n;
    BOOL iPadMode;
    
    MBProgressHUD *progressHUD;
    NSDate *markedTime;
    NSMutableDictionary *cache;
}
@property (readonly) NSBundle *l10n;
@property (readonly) BOOL iPadMode;
@property (readonly) MBProgressHUD *progressHUD;

+(NSString *) getPathInResource:(NSString *)path;
+(NSString *) getPathInCommonResource:(NSString *)path;
+(UIImage *) getImageInResource:(NSString *)path;
+(UIImage *) getImageInCommonResource:(NSString *)path;

+(PFUtils *) getInstance;

-(float) getRandomBetween0And1;
-(int) getRandomInt:(int)length;
-(NSNumber *) getAnalyticNumber:(int)value;

//File
-(void) createPathIfNotExist:(NSString *)path;
-(BOOL) isPathExist:(NSString *)path;

-(NSString *) getDocumentPath;
-(void) createPathesInDocument:(NSArray *)pathes;
-(NSString *) getPathInDocument:(NSString *)path;
-(void) copyFile:(NSString *)path
        toFolderInDocument:(NSString *)folder
                asRevision:(int)revision;
-(void) backupFile:(NSString *)path
    toFolderInDocument:(NSString *)folder
            prefix:(NSString *)prefix;

-(NSString *) getLibraryPath;
-(void) createPathesInLibrary:(NSArray *)pathes;
-(NSString *) getPathInLibrary:(NSString *)path;

//Default
-(id) getDefault:(NSString *)key;    
-(void) setDefault:(id)value forKey:(NSString *)key;
-(void) synchronizeDefaults;

//JSON
-(NSDictionary *) jsonDecode: (NSString *) str;
-(NSString *) jsonEncode: (NSDictionary *) msg;

//HUD
-(void) hideProgressHUD;
-(void) hideProgressHUD:(BOOL)animated;
-(void) showProgressHUD:(UIView *)view withText:(NSString *)text;
-(void) showProgressHUD:(UIView *)view withText:(NSString *)text animated:(BOOL)animated;
-(void) showProgressHUDInView:(UIView *)view withText:(NSString *)text;
-(void) showProgressHUDInView:(UIView *)view withText:(NSString *)text animated:(BOOL)animated;
-(void) updateProgressHUD:(NSString *)text;

//Time measure
-(void) markTime;
-(void) logTime:(NSString *)log;
-(void) logTime:(NSString *)log longerThan:(float)limit;

//Cache relate
-(void) clearCache;
-(void) clearCache:(NSString *)prefix;
-(id) getCache:(NSString *)key;
-(void) setCache:(id)value forKey:(NSString *)key;

//GUI L10n
-(void) setupButton:(UIView *)view tag:(int)tag image:(UIImage *)buttonImage;
-(void) setupBlueButton:(UIView *)view tag:(int)tag;
-(void) setupGrayButton:(UIView *)view tag:(int)tag;
-(void) l10nView:(UIView *)view bundle:(NSBundle *)l10nBundle
             tag:(int)tag key:(NSString *)l10nKey;
@end



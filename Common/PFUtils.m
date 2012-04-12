//
//  PFUtils.m
//  PettyFunNote
//
//  Created by YJ Park on 11/9/10.
//  Copyright 2010 PettyFun. All rights reserved.
//

#import "PFUtils.h"
#import "JSON.h"

static PFUtils *_utilsInstance = nil;

@implementation PFUtils
@synthesize l10n;
@synthesize iPadMode;
@synthesize progressHUD;

+(NSString *) getPathInResource:(NSString *)path {
    return [[[NSBundle mainBundle] resourcePath]
            stringByAppendingPathComponent:path];    
}

+(NSString *) getPathInCommonResource:(NSString *)path {
    return [[[[NSBundle mainBundle] resourcePath]
            stringByAppendingPathComponent:PF_COMMON_RESOURCE]
            stringByAppendingPathComponent:path];
}

+(UIImage *) getImageInResource:(NSString *)path {
    NSString *imagePath = [PFUtils getPathInResource:path];
    return [UIImage imageWithContentsOfFile:imagePath];
}

+(UIImage *) getImageInCommonResource:(NSString *)path {
    NSString *imagePath = [PFUtils getPathInCommonResource:path];
    return [UIImage imageWithContentsOfFile:imagePath];
}

+ (PFUtils *) getInstance {
	@synchronized(self) {
		if (_utilsInstance == nil) {
			_utilsInstance = [[PFUtils alloc] init];            
		}
	}
	return _utilsInstance;
}

-(id) init {
    if ((self = [super init])) {
        NSString *path = [PFUtils getPathInCommonResource:@"BucketCommonL10n.bundle"];
        l10n = [NSBundle bundleWithPath:path];
        
        srandom(time(NULL));      
        cache = [[NSMutableDictionary dictionaryWithCapacity:1024] retain];      
        
        iPadMode = NO;
        if ([[UIDevice currentDevice].model hasPrefix:@"iPad"]) {
            iPadMode = YES;
        }
    }
    return self;
}

-(void) dealloc {
    [markedTime release];
    [progressHUD release]; 
    [cache release];
    [super dealloc];
}

-(float) getRandomBetween0And1 {
    float result = (float)random() / RAND_MAX;
    if (result < 0) {
        result = 0;
    } else if (result > 1) {
        result = 1;
    }
    return result;
}

-(int) getRandomInt:(int)length {
    int result = random() % length;
    return result;
}

-(NSNumber *) getAnalyticNumber:(int)value {
    int analyticValue = 0;
    if (value > 1000000) {
        analyticValue = value / 1000000 * 1000000;
    } else if (value > 100000) {
        analyticValue = value / 100000 * 100000;
    } else if (value > 10000) {
        analyticValue = value / 10000 * 10000;
    } else if (value > 1000) {
        analyticValue = value / 1000 * 1000;
    } else if (value > 100) {
        analyticValue = value / 100 * 100;
    } else if (value > 10) {
        analyticValue = value / 10 * 10;
    } else if (value > 1) {
        analyticValue = value;
    }

    NSNumber *result = [NSNumber numberWithInt:analyticValue];
    return result;
}

-(NSString *) getDocumentPath{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [paths objectAtIndex:0];
    return documentDirectory;
}

-(NSString *) getPathInDocument:(NSString *)path {
    NSString *documentPath = [self getDocumentPath];
    return [documentPath stringByAppendingPathComponent:path];    
}

-(void) createPathesInDocument:(NSArray *)pathes {
    for (NSString *path in pathes) {
        [self createPathIfNotExist:[self getPathInDocument:path]];    
    }
}

-(void) copyFile:(NSString *)path
toFolderInDocument:(NSString *)folder
      asRevision:(int)revision {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *fileName = [NSString stringWithFormat:@"%@.%d",
                          [path lastPathComponent], revision];
    NSString *destFolder = [self getPathInDocument:folder];
    [fileManager copyItemAtPath:path 
                         toPath:[destFolder stringByAppendingPathComponent:fileName]
                          error:NULL];
}

-(void) backupFile:(NSString *)path
toFolderInDocument:(NSString *)folder
            prefix:(NSString *)prefix {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *fileName = [NSString stringWithFormat:@"%@_%@",
                          prefix,
                          [path lastPathComponent]];
    NSString *destFolder = [self getPathInDocument:folder];
    
    NSString *destPath = [destFolder stringByAppendingPathComponent:fileName];
    [fileManager removeItemAtPath:destPath error:NULL];
    [fileManager copyItemAtPath:path 
                         toPath:destPath
                          error:NULL];
}

-(NSString *) getLibraryPath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *libraryDirectory = [paths objectAtIndex:0];
    return libraryDirectory;
}

-(NSString *) getPathInLibrary:(NSString *)path {
    NSString *libraryDirectory = [self getLibraryPath];
    return [libraryDirectory stringByAppendingPathComponent:path];    
}

-(void) createPathesInLibrary:(NSArray *)pathes {
    for (NSString *path in pathes) {
        [self createPathIfNotExist:[self getPathInLibrary:path]];    
    }
}

-(BOOL) isPathExist:(NSString *)path {
    BOOL isDir;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    return [fileManager fileExistsAtPath:path isDirectory:&isDir];
}

-(void) createPathIfNotExist:(NSString *)path {
    BOOL isDir;
    NSFileManager *fileManager = [NSFileManager defaultManager];
        
    if (![fileManager fileExistsAtPath:path isDirectory:&isDir]) {
        [fileManager createDirectoryAtPath:path 
               withIntermediateDirectories:YES 
                                attributes:nil error:NULL];
    } else if (!isDir) {
        [fileManager removeItemAtPath:path error:NULL];
        [fileManager createDirectoryAtPath:path 
               withIntermediateDirectories:YES 
                                attributes:nil error:NULL];
    }
}

-(id) getDefault:(NSString *)key {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    id result = [defaults valueForKey:key];
    return result;
}

-(void) setDefault:(id)value forKey:(NSString *)key {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:value forKey:key];
}

-(void) synchronizeDefaults {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults synchronize];
}

-(NSDictionary *) jsonDecode: (NSString *) str {
	return [str JSONValue];
}

-(NSString *) jsonEncode: (NSDictionary *) msg {
	return [msg JSONRepresentation];
}

- (void) hideProgressHUD { 
    [self hideProgressHUD:YES];
} 

- (void) hideProgressHUD:(BOOL)animated { 
    if (progressHUD) {
		progressHUD.removeFromSuperViewOnHide = YES;
        [progressHUD hide:animated]; 
        [progressHUD release]; 
        progressHUD = nil;
    }
} 

- (void) showProgressHUD:(UIView *)view withText:(NSString *)text { 
    [self showProgressHUD:view withText:text animated:YES];
}

-(void) showProgressHUD:(UIView *)view withText:(NSString *)text animated:(BOOL)animated {
    if (progressHUD) {
        return;
    }
    if (view.window) {
        progressHUD = [[MBProgressHUD alloc] initWithWindow:view.window]; 
        [view.window addSubview:progressHUD];
        [progressHUD setLabelText:text]; 
        [progressHUD show:animated]; 
    }
}

-(void) updateProgressHUD:(NSString *)text {
    if (progressHUD) {
        [progressHUD setLabelText:text];
    }    
}

- (void) showProgressHUDInView:(UIView *)view withText:(NSString *)text {
    [self showProgressHUDInView:view withText:text animated:YES];
}

-(void) showProgressHUDInView:(UIView *)view withText:(NSString *)text animated:(BOOL)animated {
    if (progressHUD) {
        return;
    }
    if (view) {
        progressHUD = [[MBProgressHUD alloc] initWithView:view]; 
        [view addSubview:progressHUD];
        [progressHUD setLabelText:text]; 
        [progressHUD show:animated]; 
    }
}

#pragma mark -
#pragma mark Time measure
-(void) markTime {
    if (markedTime) {
        [markedTime release];
    }
    markedTime = [[NSDate date] retain];
}

-(void) logTime:(NSString *)log {
    [self logTime:log longerThan:0.0f];
}

-(void) logTime:(NSString *)log longerThan:(float)limit {
    NSString *timeStr = @"N/A";
    if (markedTime) {
        NSDate *nowTime = [NSDate date];
        float timeSpent = [nowTime timeIntervalSince1970] - [markedTime timeIntervalSince1970];
        timeStr = NSFormat(@"%.4f", timeSpent);
        if (timeSpent >= limit) {
            PFTimeDebug(@"Spent[%@]: %@", timeStr, log);
        }
    } else {
        PFTimeDebug(@"Spent[%@]: %@", timeStr, log);
    }
}

-(void) clearCache {
    NSLog(@"cache size = %d", [cache count]);
	@synchronized(cache) {
        [cache removeAllObjects];
    }
}

-(void) clearCache:(NSString *)prefix {
	@synchronized(cache) {
        NSMutableArray *keys = [NSMutableArray array];
        for (NSString *key in [cache allKeys]) {
            if ([key hasPrefix:prefix]) {
                [keys addObject:key];
            }
        }
        [cache removeObjectsForKeys:keys];
    }
}

-(id) getCache:(NSString *)key {
    id result = nil;
	@synchronized(cache) {
        result = [cache valueForKey:key];
    }
    return result;
}

-(void) setCache:(id)value forKey:(NSString *)key {
	@synchronized(cache) {
        [cache setValue:value forKey:key];
    }
}

#pragma mark -
#pragma mark GUI L10N related

-(void) setupBlueButton:(UIView *)view tag:(int)tag {
    UIImage *image = [PFUtils getImageInCommonResource:@"Images/blueButton.png"];
    [self setupButton:view tag:tag image:image];
}

-(void) setupGrayButton:(UIView *)view tag:(int)tag {
    UIImage *image = [PFUtils getImageInCommonResource:@"Images/grayButton.png"];
    [self setupButton:view tag:tag image:image];
}

-(void) setupButton:(UIView *)view tag:(int)tag image:(UIImage *)buttonImage {
    UIButton *button = (UIButton *)[view viewWithTag:tag];
    if (button) {
        UIImage *stretchImage =
        [buttonImage stretchableImageWithLeftCapWidth:15.0 topCapHeight:0.0];
        [button setBackgroundImage:stretchImage forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
}

-(void) l10nView:(UIView *)view bundle:(NSBundle *)l10nBundle
             tag:(int)tag key:(NSString *)l10nKey {
    UIView *target = [view viewWithTag:tag];
    if (!target) {
        return;
    }
    NSString *l10nValue = [l10nBundle localizedStringForKey:l10nKey value:l10nKey table:nil];
    if ([[target class] isSubclassOfClass:[UILabel class]]) {
        UILabel *label = (UILabel *)target;
        label.text = l10nValue;
    } else if ([[target class] isSubclassOfClass:[UITextView class]]) {
        UITextView *textview = (UITextView *)target;
        textview.text = l10nValue;
    } else if ([[target class] isSubclassOfClass:[UIButton class]]) {
        UIButton *button = (UIButton *)target;
        [button setTitle:l10nValue forState:UIControlStateNormal];
    }
}

@end

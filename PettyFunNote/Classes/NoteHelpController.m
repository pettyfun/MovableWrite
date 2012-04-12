//
//  NoteHelpController.m
//  PettyFunNote
//
//  Created by YJ Park on 3/15/11.
//  Copyright 2011 PettyFun.com. All rights reserved.
//

#import "NoteHelpController.h"
#import "PFNoteModel.h"
#import "PFUtils.h"

@implementation NoteHelpController
@synthesize delegate;

- (void)dealloc {
    [helpImageViews release];
    [super dealloc];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    PF_L10N_VIEW(101, @"done");

    self.view.backgroundColor = [UIColor blackColor];
    DECLARE_PFUTILS
    [utils setupGrayButton:self.view tag:101];
    
    scrollView.clipsToBounds = YES;
    scrollView.scrollEnabled = YES;
    scrollView.pagingEnabled = YES;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.delegate = self;
}

- (void)releaseViewElements {
    [super releaseViewElements];
    PF_Release_IBOutlet(scrollView);
    PF_Release_IBOutlet(pageControl);
}

-(BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    DECLARE_PFNOTE_MODEL
    return [model shouldAutorotateToInterfaceOrientation:interfaceOrientation];
}

-(IBAction) onClose:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
    [delegate onHelpClosed];
}

#pragma mark - deal with images

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self loadHelpImageViews];
}

-(void) viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    for (UIImageView *imageView in helpImageViews) {
        [imageView removeFromSuperview];
    }
    [helpImageViews removeAllObjects];
}

-(void) loadHelpImageViews {
    DECLARE_PFNOTE_MODEL
    if (helpImageViews == nil) helpImageViews = [[NSMutableArray alloc] init];
    
    NSString *helpImageFolder = [PFUtils getPathInResource:PFNOTE_HELP_IMAGE_PATH];
    helpImageFolder = [helpImageFolder stringByAppendingPathComponent:model.iPadMode ? @"iPad" : @"iPhone"];
    
    NSString *language = [[NSLocale preferredLanguages] objectAtIndex:0];
    if (language.length > 2) {
        language = [language substringToIndex:2];
    }
    
    DECLARE_PFUTILS
    if ([utils isPathExist:[helpImageFolder stringByAppendingPathComponent:language]]) {
        helpImageFolder = [helpImageFolder stringByAppendingPathComponent:language];
    }
    
    int i = 1;
    
    CGFloat width = scrollView.frame.size.width;
    CGFloat height = scrollView.frame.size.height;
    CGFloat imageOffsetY = model.iPadMode ? 20 : 5;
    CGFloat imageWidth = model.iPadMode ? PFNOTE_HELP_IMAGE_WIDTH_IPAD : PFNOTE_HELP_IMAGE_WIDTH_IPHONE;
    CGFloat imageHeight = model.iPadMode ? PFNOTE_HELP_IMAGE_HEIGHT_IPAD : PFNOTE_HELP_IMAGE_HEIGHT_IPHONE;
    while (YES) {
        NSString *imagePath = [helpImageFolder stringByAppendingPathComponent:NSFormat(@"%d.png", i)];
        if (![utils isPathExist:imagePath]) {
            break;
        }
        UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
        UIImageView *imageView = [[[UIImageView alloc] initWithImage:image] autorelease];
        [helpImageViews addObject:imageView];
        imageView.frame = CGRectMake((i - 1) * width + (width - imageWidth) / 2.0f,
                                     imageOffsetY,
                                     imageWidth,
                                     imageHeight);
        [scrollView addSubview:imageView];
        i++;
    }
    
    int number = i - 1;
    scrollView.contentSize = CGSizeMake(number * width, height);
    pageControl.numberOfPages = number;
    pageControl.currentPage = 0;
}

- (void)scrollViewDidScroll:(UIScrollView *)oneScrollView {
    pageControl.currentPage = (int)(scrollView.contentOffset.x / scrollView.frame.size.width + 0.5f);    
}

@end

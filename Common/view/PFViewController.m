//
//  PFViewController.m
//  TaskTimer
//
//  Created by YJ Park on 4/6/11.
//  Copyright 2011 PettyFun. All rights reserved.
//

#import "PFViewController.h"


@implementation PFViewController

- (void)dealloc
{
    [self releaseViewElements];
    [super dealloc];
}

#pragma mark - View lifecycle

- (void)viewDidUnload
{
    [super viewDidUnload];
    [self releaseViewElements];
}

- (void)releaseViewElements {    
}

@end

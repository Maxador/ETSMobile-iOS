//
//  ETSAboutViewController.m
//  ETSMobile
//
//  Created by Jean-Philippe Martin on 2014-04-06.
//  Copyright (c) 2014 ApplETS. All rights reserved.
//

#import "ETSAboutViewController.h"

@implementation ETSAboutViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    #ifdef __USE_TESTFLIGHT
    [TestFlight passCheckpoint:@"ABOUT_VIEWCONTROLLER"];
    #endif
    
    #ifdef __USE_BUGSENSE
    [BugSenseController leaveBreadcrumb:@"ABOUT_VIEWCONTROLLER"];
    #endif
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [self.navigationController setToolbarHidden:YES animated:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [UIView animateWithDuration:0.8
                          delay:0
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.aboutLabel.alpha = 1;
                     }
                     completion:nil];
}

@end

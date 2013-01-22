//
//  MaguroBaseViewController.m
//  Maguro
//
//  Created by Kelp on 2013/01/22.
//  Copyright (c) 2013 Accuvally Inc. All rights reserved.
//

#import "MaguroBaseViewController.h"
#import "Maguro.h"


@interface MaguroBaseViewController ()

@end

@implementation MaguroBaseViewController

@synthesize delegate = _delegate;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // set up UI
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        _cellBound.height = 10;
        _cellBound.width = 10;
    }
    else {
        _cellBound.height = 45;
        _cellBound.width = 30;
    }
    self.view.backgroundColor = _delegate.config.backgroundColor;
}

@end

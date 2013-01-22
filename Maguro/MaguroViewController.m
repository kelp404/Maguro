//
//  MaguroViewController.m
//  Maguro
//
//  Created by Kelp on 2013/01/18.
//  Copyright (c) 2013 Accuvally Inc. All rights reserved.
//

#import "MaguroViewController.h"
#import "Maguro.h"


@interface MaguroViewController ()

@end

@implementation MaguroViewController


#pragma mark - View Events
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)orientation
{
    return orientation != UIInterfaceOrientationPortraitUpsideDown;
}


#pragma mark - Click Events
- (IBAction)clickContactUs:(UIButton *)sender
{
    MaguroConfig *config = [MaguroConfig configWithSite:@"demo.uservoice.com"
                                                 andKey:@"pZJocTBPbg5FN4bAwczDLQ"
                                              andSecret:@"Q7UKcxRYLlSJN4CxegUYI6t0uprdsSAGthRIDvYmI"];
    
    config.subject = @"This ticket was submitted from iOS.";
    config.name = @"User Name";
    config.email = @"name@gmail.com";
//    config.navigationTintColor = [UIColor colorWithRed:0.216f green:0.369f blue:0.776f alpha:1];
//    config.backgroundColor = [UIColor whiteColor];
    
    [Maguro showContactUsForParentViewController:self withConfig:config andCloseHandler:^{
        NSLog(@"Closed");
    }];
}


@end

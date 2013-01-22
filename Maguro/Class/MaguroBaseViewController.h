//
//  MaguroBaseViewController.h
//  Maguro
//
//  Created by Kelp on 2013/01/22.
//  Copyright (c) 2013 Accuvally Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MaguroConfig.h"

@class Maguro;

@interface MaguroBaseViewController : UIViewController {
    CGSize _cellBound;
    Maguro *_delegate;
}


@property (nonatomic, strong) Maguro *delegate;

@end

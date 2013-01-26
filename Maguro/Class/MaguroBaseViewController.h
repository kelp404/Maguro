//
//  MaguroBaseViewController.h
//  Maguro
//
//  Created by Kelp on 2013/01/22.
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

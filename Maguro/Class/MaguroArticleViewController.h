//
//  MaguroArticleViewController.h
//  Maguro
//
//  Created by Kelp on 2013/01/22.
//

#import "MaguroBaseViewController.h"

@interface MaguroArticleViewController : MaguroBaseViewController <UIWebViewDelegate> {
    NSDictionary *_article;
    UIActivityIndicatorView *_activityIndicator;
}


@property (nonatomic, strong) NSDictionary *article;

@end

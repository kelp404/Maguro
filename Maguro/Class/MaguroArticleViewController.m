//
//  MaguroArticleViewController.m
//  Maguro
//
//  Created by Kelp on 2013/01/22.
//

#import "MaguroArticleViewController.h"
#import "Maguro.h"


@interface MaguroArticleViewController ()

@end

@implementation MaguroArticleViewController

@synthesize article = _article;

#pragma mark - View Events
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // set up title
    self.title = NSLocalizedStringFromTable(@"Knowledge Base", @"Maguro", @"Knowledge Base");
    
    // set up activity indicatorView
    _activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    _activityIndicator.hidesWhenStopped = YES;
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        _activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    }
    [_activityIndicator startAnimating];
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithCustomView:_activityIndicator];
    self.navigationItem.rightBarButtonItem = rightButton;
    
    // set up context
    UIWebView *webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    webView.delegate = self;
    webView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    NSString *html = [NSString stringWithFormat:@"<html><head><link rel=\"stylesheet\" type=\"text/css\" href=\"http://cdn.uservoice.com/stylesheets/vendor/typeset.css\"/></head><body class=\"typeset\" style=\"font-family: sans-serif; margin: 1em\"><h3>%@</h3>%@</body></html>", [_article objectForKey:@"question"], [_article objectForKey:@"answer_html"]];
    [webView loadHTMLString:html baseURL:nil];
    [self.view addSubview:webView];
}

#pragma mark - WebView Delegate
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [_activityIndicator stopAnimating];
}


@end

//
//  Maguro.m
//  Maguro
//
//  Created by Kelp on 2013/01/18.
//

#import "Maguro.h"
#import "MaguroNavigationViewController.h"
#import "MaguroContactUsViewController.h"
#import "KOAuth.h"
#import "JSONKit.h"

#if defined (__GNUC__) && (__GNUC__ >= 4)
#define MAGURO_ATTRIBUTES(attr, ...) __attribute__((attr, ##__VA_ARGS__))
#else  // defined (__GNUC__) && (__GNUC__ >= 4)
#define MAGURO_ATTRIBUTES(attr, ...)
#endif
#define BURST_LINK static __inline__ MAGURO_ATTRIBUTES(always_inline)

@implementation Maguro


#define URI_INSTANT_ANSWERS @"/api/v1/instant_answers/search.json"
#define URI_SUBMIT_TICKET @"/api/v1/tickets.json"


@synthesize config = _config;
@synthesize rootViewController = _rootViewController;

static Maguro *_instance;

#pragma mark - Static Messages
+ (void)showContactUsForParentViewController:(UIViewController *)parentViewController withConfig:(MaguroConfig *)config andCloseHandler:(void (^)(void))handler
{
    if (_instance == nil) {
        _instance = [Maguro new];
    }
    
    _instance.config = config;
    [_instance showContactUsForParentViewController:parentViewController withCloseHandler:handler];
}


#pragma mark - Show Maguro
- (void)showContactUsForParentViewController:(UIViewController *)parentViewController withCloseHandler:(void (^)(void))handler
{
    _closeHandler = handler;
    
    // set up root view
    MaguroContactUsViewController *controller = [MaguroContactUsViewController new];
    controller.title = NSLocalizedStringFromTable(@"Contact Us", @"Maguro", @"Contact Us");
    controller.delegate = self;
    
    // set up navigation
    _navigation = [[MaguroNavigationViewController alloc] initWithRootViewController:controller];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        _navigation.navigationBar.tintColor = _config.navigationTintColor;
    }
    _navigation.modalPresentationStyle = UIModalPresentationFormSheet;
    
    _rootViewController = parentViewController;
    [_rootViewController presentModalViewController:_navigation animated:YES];
}


#pragma mark - Network
// get instant answers
- (void)requestForInstantAnswers:(NSString *)query errorHandler:(void (^)(NSError *error))errorHandler completionHandler:(void (^)(NSDictionary *document))completionHandler
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@%@", _config.site, URI_INSTANT_ANSWERS]];
    NSMutableURLRequest *request = [KOAuth URLRequestForUrl:url
                                               GETParameters:@{@"query": query}
                                                 consumerKey:_config.key
                                              consumerSecret:_config.secret
                                                 accessToken:nil tokenSecret:nil];
    setDefaultRequestSettings(request);
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue new] completionHandler:^(NSURLResponse *rResponse, NSData *data, NSError *error) {
        NSHTTPURLResponse *response = (NSHTTPURLResponse *)rResponse;
        
        if (error != nil) {
            // error
            if (errorHandler) { dispatch_async(dispatch_get_main_queue(), ^{ errorHandler(error); }); }
            return;
        }
        else if (response.statusCode != 200) {
            // status code != 200
            if (errorHandler) { dispatch_async(dispatch_get_main_queue(), ^{ errorHandler([NSError errorWithDomain:[NSString stringWithFormat:@"status code is %i.", response.statusCode] code:response.statusCode userInfo:nil]); }); }
            return;
        }
        else if (data == nil) {
            // response data is null
            if (errorHandler) { dispatch_async(dispatch_get_main_queue(), ^{ errorHandler([NSError errorWithDomain:@"response data is null." code:0 userInfo:nil]); }); }
            return;
        }
        else {
            NSDictionary *document = nil;
            @try {
                document = data.objectFromJSONData;
                if (completionHandler) { dispatch_async(dispatch_get_main_queue(), ^{ completionHandler(document); }); }
            }
            @catch (NSException *exception) {
                if (errorHandler) { dispatch_async(dispatch_get_main_queue(), ^{ errorHandler([NSError errorWithDomain:@"parser json data failed." code:0 userInfo:nil]); }); }
            }
        }
    }];
}
// submit ticket
- (void)requestForSubmitTicket:(NSString *)message errorHandler:(void (^)(NSError *error))errorHandler completionHandler:(void (^)(NSDictionary *document))completionHandler
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@%@", _config.site, URI_SUBMIT_TICKET]];
    NSMutableURLRequest *request = [KOAuth URLRequestForUrl:url
                                              POSTParameters:@{@"email": _config.email,
                                                                        @"name": _config.name,
                                                                        @"ticket[subject]": _config.subject,
                                                                        @"ticket[message]": message}
                                                 consumerKey:_config.key
                                              consumerSecret:_config.secret
                                                 accessToken:nil tokenSecret:nil];
    setDefaultRequestSettings(request);
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue new] completionHandler:^(NSURLResponse *rResponse, NSData *data, NSError *error) {
        NSHTTPURLResponse *response = (NSHTTPURLResponse *)rResponse;
        
        if (error != nil) {
            // error
            if (errorHandler) { dispatch_async(dispatch_get_main_queue(), ^{ errorHandler(error); }); }
            return;
        }
        else if (response.statusCode != 200) {
            // status code != 200
            if (errorHandler) { dispatch_async(dispatch_get_main_queue(), ^{ errorHandler([NSError errorWithDomain:[NSString stringWithFormat:@"status code is %i.", response.statusCode] code:response.statusCode userInfo:nil]); }); }
            return;
        }
        else if (data == nil) {
            // response data is null
            if (errorHandler) { dispatch_async(dispatch_get_main_queue(), ^{ errorHandler([NSError errorWithDomain:@"response data is null." code:0 userInfo:nil]); }); }
            return;
        }
        else {
            NSDictionary *document = nil;
            @try {
                document = data.objectFromJSONData;
                if (completionHandler) { dispatch_async(dispatch_get_main_queue(), ^{ completionHandler(document); }); }
            }
            @catch (NSException *exception) {
                if (errorHandler) { dispatch_async(dispatch_get_main_queue(), ^{ errorHandler([NSError errorWithDomain:@"parser json data failed." code:0 userInfo:nil]); }); }
            }
        }
    }];
}


#pragma mark - Delegate
- (void)closed
{
    if (_closeHandler) {
        _closeHandler();
    }
}


#pragma mark - Shared
BURST_LINK void setDefaultRequestSettings(NSMutableURLRequest *request)
{
    [request setValue:request.URL.host forHTTPHeaderField:@"host"];
    if ([request.HTTPMethod isEqualToString:@"POST"]) {
        [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    }
    [request setTimeoutInterval:12];
}


@end

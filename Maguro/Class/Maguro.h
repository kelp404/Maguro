//
//  Maguro.h
//  Maguro
//
//  Created by Kelp on 2013/01/18.
//  Copyright (c) 2013 Accuvally Inc. All rights reserved.
//  MIT License.
//

#import <Foundation/Foundation.h>
#import "MaguroConfig.h"


@interface Maguro : NSObject {
    UINavigationController *_navigation;
    __block void (^_closeHandler)(void);
}

#pragma mark Maguro Config
@property (nonatomic, strong) MaguroConfig *config;
@property (nonatomic, strong) UIViewController *rootViewController;

#pragma mark - Static Messages
// handler run on the main thread
+ (void)showContactUsWithConfig:(MaguroConfig *)config andCloseHandler:(void (^)(void))handler;

#pragma mark - Messages
- (void)showContactUsWithCloseHandler:(void (^)(void))handler;

#pragma mark - Network
// handler run on the main thread
- (void)requestForInstantAnswers:(NSString *)query errorHandler:(void (^)(NSError *error))errorHandler completionHandler:(void (^)(NSDictionary *document))completionHandler;
- (void)requestForSubmitTicket:(NSString *)message errorHandler:(void (^)(NSError *error))errorHandler completionHandler:(void (^)(NSDictionary *document))completionHandler;

#pragma mark - For Delegate
- (void)closed;

@end

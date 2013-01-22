//
//  MaguroConfig.m
//  Maguro
//
//  Created by Kelp on 2013/01/21.
//  Copyright (c) 2013 Accuvally Inc. All rights reserved.
//

#import "MaguroConfig.h"

@implementation MaguroConfig

+ (MaguroConfig *)configWithSite:(NSString *)site andKey:(NSString *)key andSecret:(NSString *)secret
{
    MaguroConfig *config = [MaguroConfig new];
    config.site = site;
    config.key = key;
    config.secret = secret;
    
    return config;
}

- (id)init
{
    self = [super init];
    if (self) {
        _backgroundColor = [UIColor colorWithWhite:0.9 alpha:1];
    }
    return self;
}

@end

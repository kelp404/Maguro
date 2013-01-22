//
//  MaguroConfig.h
//  Maguro
//
//  Created by Kelp on 2013/01/21.
//  Copyright (c) 2013 Accuvally Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MaguroConfig : NSObject

@property (nonatomic, strong) NSString *site;
@property (nonatomic, strong) NSString *key;
@property (nonatomic, strong) NSString *secret;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSString *subject;
@property (nonatomic, strong) UIColor *navigationTintColor;
@property (nonatomic, strong) UIColor *backgroundColor;

+ (MaguroConfig *)configWithSite:(NSString *)site andKey:(NSString *)key andSecret:(NSString *)secret;

@end

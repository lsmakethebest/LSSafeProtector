//
//  NSMutableAttributedString+Safe.m
// https://github.com/lsmakethebest/LSSafeProtector
//
//  Created by liusong on 2018/4/20.
//  Copyright © 2018年 liusong. All rights reserved.

#import <UIKit/UIKit.h>
#import "NSObject+SafeCore.h"


@implementation NSAttributedString (Safe)

+(void)openSafeProtector
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        Class dClass = NSClassFromString(@"NSConcreteAttributedString");
        
        //initWithString:
        [self safe_exchangeInstanceMethod:dClass originalSel:@selector(initWithString:) newSel:@selector(safe_initWithString:)];
        
        //initWithAttributedString
        [self safe_exchangeInstanceMethod:dClass originalSel:@selector(initWithString:attributes:) newSel:@selector(safe_initWithString:attributes:)];
        
        //initWithString:attributes:
        [self safe_exchangeInstanceMethod:dClass originalSel:@selector(initWithAttributedString:) newSel:@selector(safe_initWithAttributedString:)];
        
    });
}

- (instancetype)safe_initWithString:(NSString *)str {
    id object = nil;
    @try {
        object = [self safe_initWithString:str];
    }
    @catch (NSException *exception) {
        LSSafeProtectionCrashLog(exception,LSSafeProtectorCrashTypeNSAttributedString);
    }
    @finally {
        return object;
    }
}

#pragma mark - initWithAttributedString
- (instancetype)safe_initWithAttributedString:(NSAttributedString *)attrStr {
    id object = nil;
    
    @try {
        object = [self safe_initWithAttributedString:attrStr];
    }
    @catch (NSException *exception) {
        LSSafeProtectionCrashLog(exception,LSSafeProtectorCrashTypeNSAttributedString);
    }
    @finally {
        return object;
    }
}

#pragma mark - initWithString:attributes:
- (instancetype)safe_initWithString:(NSString *)str attributes:(NSDictionary<NSString *,id> *)attrs {
    id object = nil;
    
    @try {
        object = [self safe_initWithString:str attributes:attrs];
    }
    @catch (NSException *exception) {
        LSSafeProtectionCrashLog(exception,LSSafeProtectorCrashTypeNSAttributedString);
    }
    @finally {
        return object;
    }
}



@end



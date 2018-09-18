//
//  NSMutableDictionary+Safe.m
// https://github.com/lsmakethebest/LSSafeProtector
//
//  Created by liusong on 2018/4/20.
//  Copyright © 2018年 liusong. All rights reserved.

#import "NSMutableDictionary+Safe.h"
#import "NSObject+SafeCore.h"

@implementation NSMutableDictionary (Safe)

+(void)openSafeProtector
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class dClass=NSClassFromString(@"__NSDictionaryM");
        [self safe_exchangeInstanceMethod:dClass originalSel:@selector(setObject:forKey:) newSel:@selector(safe_setObject:forKey:)];
        [self safe_exchangeInstanceMethod:dClass originalSel:@selector(setObject:forKeyedSubscript:) newSel:@selector(safe_setObject:forKeyedSubscript:)];
        [self safe_exchangeInstanceMethod:dClass originalSel:@selector(removeObjectForKey:) newSel:@selector(safe_removeObjectForKey:)];
    });
}


- (void)safe_setObject:(id)anObject forKey:(id<NSCopying>)aKey {
    
    @try {
        [self safe_setObject:anObject forKey:aKey];
    }
    @catch (NSException *exception) {
        LSSafeProtectionCrashLog(exception,LSSafeProtectorCrashTypeNSMutableDictionary);
    }
    @finally {
    }
}

- (void)safe_setObject:(id)anObject forKeyedSubscript:(id<NSCopying>)aKey {
    
    @try {
        [self safe_setObject:anObject forKeyedSubscript:aKey];
    }
    @catch (NSException *exception) {
        LSSafeProtectionCrashLog(exception,LSSafeProtectorCrashTypeNSMutableDictionary);
    }
    @finally {
    }
}

- (void)safe_removeObjectForKey:(id)aKey {
    
    @try {
        [self safe_removeObjectForKey:aKey];
    }
    @catch (NSException *exception) {
        LSSafeProtectionCrashLog(exception,LSSafeProtectorCrashTypeNSMutableDictionary);
    }
    @finally {
    }
}

@end




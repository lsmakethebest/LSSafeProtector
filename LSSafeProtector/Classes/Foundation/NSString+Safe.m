//
//  NSString+Safe.m
// https://github.com/lsmakethebest/LSSafeProtector
//
//  Created by liusong on 2018/4/20.
//  Copyright © 2018年 liusong. All rights reserved.

#import "NSString+Safe.h"
#import "NSObject+SafeCore.h"
@implementation NSString (Safe)

+(void)openSafeProtector
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
       
        Class NSPlaceholderStringClass=NSClassFromString(@"NSPlaceholderString");
        
        //initWithString:
        [self safe_exchangeInstanceMethod:NSPlaceholderStringClass originalSel:@selector(initWithString:) newSel:@selector(safe_initWithString:)];
         
         Class dClass=NSClassFromString(@"__NSCFConstantString");
         Class dClass2=NSClassFromString(@"NSTaggedPointerString");
         [self safe_changeAllMethod:dClass];
         [self safe_changeAllMethod:dClass2];     
        
    });
}

+(void)safe_changeAllMethod:(Class)dClass
{
    //hasPrefix
    [self safe_exchangeInstanceMethod:dClass originalSel:@selector(hasPrefix:) newSel:@selector(safe_hasPrefix:)];
    
    //hasSuffix
    [self safe_exchangeInstanceMethod:dClass originalSel:@selector(hasSuffix:) newSel:@selector(safe_hasSuffix:)];
    
    
    //substringFromIndex
    [self safe_exchangeInstanceMethod:dClass originalSel:@selector(substringFromIndex:) newSel:@selector(safe_substringFromIndex:)];
    
    //substringToIndex
    [self safe_exchangeInstanceMethod:dClass originalSel:@selector(substringToIndex:) newSel:@selector(safe_substringToIndex:)];
    
    //substringWithRange
    [self safe_exchangeInstanceMethod:dClass originalSel:@selector(substringWithRange:) newSel:@selector(safe_substringWithRange:)];
    
    //characterAtIndex
    [self safe_exchangeInstanceMethod:dClass originalSel:@selector(characterAtIndex:) newSel:@selector(safe_characterAtIndex:)];
    
    
    //stringByReplacingOccurrencesOfString:withString:options:range:
    [self safe_exchangeInstanceMethod:dClass originalSel:@selector(stringByReplacingOccurrencesOfString:withString:options:range:) newSel:@selector(safe_stringByReplacingOccurrencesOfString:withString:options:range:)];
    
    
    //stringByReplacingCharactersInRange:withString:
    [self safe_exchangeInstanceMethod:dClass originalSel:@selector(stringByReplacingCharactersInRange:withString:) newSel:@selector(safe_stringByReplacingCharactersInRange:withString:)];
}
-(instancetype)safe_initWithString:(NSString *)aString
{
    id instance = nil;
    @try {
        instance = [self safe_initWithString:aString];
    }
    @catch (NSException *exception) {
        LSSafeProtectionCrashLog(exception,LSSafeProtectorCrashTypeNSStirng);
    }
    @finally {
        return instance;
    }
}

-(BOOL)safe_hasPrefix:(NSString *)str
{
    BOOL has = NO;
    @try {
        has = [self safe_hasPrefix:str];
    }
    @catch (NSException *exception) {
        LSSafeProtectionCrashLog(exception,LSSafeProtectorCrashTypeNSStirng);
    }
    @finally {
        return has;
    }
}

-(BOOL)safe_hasSuffix:(NSString *)str
{
    BOOL has = NO;
    @try {
        has = [self safe_hasSuffix:str];
    }
    @catch (NSException *exception) {
        LSSafeProtectionCrashLog(exception,LSSafeProtectorCrashTypeNSStirng);
    }
    @finally {
        return has;
    }
}

- (NSString *)safe_substringFromIndex:(NSUInteger)from {
    
    NSString *subString = nil;
    @try {
        subString = [self safe_substringFromIndex:from];
    }
    @catch (NSException *exception) {
        LSSafeProtectionCrashLog(exception,LSSafeProtectorCrashTypeNSStirng);
        subString = nil;
    }
    @finally {
        return subString;
    }
}

- (NSString *)safe_substringToIndex:(NSUInteger)index {
    
    NSString *subString = nil;
    
    @try {
        subString = [self safe_substringToIndex:index];
    }
    @catch (NSException *exception) {
        LSSafeProtectionCrashLog(exception,LSSafeProtectorCrashTypeNSStirng);
        subString = nil;
    }
    @finally {
        return subString;
    }
}

- (NSString *)safe_substringWithRange:(NSRange)range {
    
    NSString *subString = nil;
    @try {
        subString = [self safe_substringWithRange:range];
    }
    @catch (NSException *exception) {
        LSSafeProtectionCrashLog(exception,LSSafeProtectorCrashTypeNSStirng);
        subString = nil;
    }
    @finally {
        return subString;
    }
}

- (unichar)safe_characterAtIndex:(NSUInteger)index {
    
    unichar characteristic;
    @try {
        characteristic = [self safe_characterAtIndex:index];
    }
    @catch (NSException *exception) {
        LSSafeProtectionCrashLog(exception,LSSafeProtectorCrashTypeNSStirng);
    }
    @finally {
        return characteristic;
    }
}


- (NSString *)safe_stringByReplacingOccurrencesOfString:(NSString *)target withString:(NSString *)replacement options:(NSStringCompareOptions)options range:(NSRange)searchRange {
    
    NSString *newStr = nil;
    
    @try {
        newStr = [self safe_stringByReplacingOccurrencesOfString:target withString:replacement options:options range:searchRange];
    }
    @catch (NSException *exception) {
       LSSafeProtectionCrashLog(exception,LSSafeProtectorCrashTypeNSStirng);
        newStr = nil;
    }
    @finally {
        return newStr;
    }
}


- (NSString *)safe_stringByReplacingCharactersInRange:(NSRange)range withString:(NSString *)replacement {
    
    NSString *newStr = nil;
    
    @try {
        newStr = [self safe_stringByReplacingCharactersInRange:range withString:replacement];
    }
    @catch (NSException *exception) {
        LSSafeProtectionCrashLog(exception,LSSafeProtectorCrashTypeNSStirng);
        newStr = nil;
    }
    @finally {
        return newStr;
    }
}


@end




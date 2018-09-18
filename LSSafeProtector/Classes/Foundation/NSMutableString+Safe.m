//
//  NSMutableString+Safe.m
// https://github.com/lsmakethebest/LSSafeProtector
//
//  Created by liusong on 2018/4/20.
//  Copyright © 2018年 liusong. All rights reserved.

#import "NSMutableString+Safe.h"
#import "NSObject+SafeCore.h"
@implementation NSMutableString (Safe)

+(void)openSafeProtector
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        Class dClass=NSClassFromString(@"__NSCFString");
        Class NSPlaceholderMutableStringClass=NSClassFromString(@"NSPlaceholderMutableString");
        
        //initWithString:
        [self safe_exchangeInstanceMethod:NSPlaceholderMutableStringClass originalSel:@selector(initWithString:) newSel:@selector(safe_initWithString:)];
        
        
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
        
        
        
        //replaceCharactersInRange:withString:
        [self safe_exchangeInstanceMethod:dClass originalSel:@selector(replaceCharactersInRange:withString:) newSel:@selector(safe_replaceCharactersInRange:withString:)];
        
        //replaceOccurrencesOfString:withString:options:range:
        [self safe_exchangeInstanceMethod:dClass originalSel:@selector(replaceOccurrencesOfString:withString:options:range:) newSel:@selector(safe_replaceOccurrencesOfString:withString:options:range:)];
        
        //insertString:atIndex:
        [self safe_exchangeInstanceMethod:dClass originalSel:@selector(insertString:atIndex:) newSel:@selector(safe_insertString:atIndex:)];
        
        //deleteCharactersInRange:
        [self safe_exchangeInstanceMethod:dClass originalSel:@selector(deleteCharactersInRange:) newSel:@selector(safe_deleteCharactersInRange:)];
        
        
        //appendString:
        [self safe_exchangeInstanceMethod:dClass originalSel:@selector(appendString:) newSel:@selector(safe_appendString:)];
        
        
        //setString:
        [self safe_exchangeInstanceMethod:dClass originalSel:@selector(setString:) newSel:@selector(safe_setString:)];
        
    });
}
-(instancetype)safe_initWithString:(NSString *)aString
{
    id instance = nil;
    @try {
        instance = [self safe_initWithString:aString];
    }
    @catch (NSException *exception) {
        LSSafeProtectionCrashLog(exception,LSSafeProtectorCrashTypeNSMutableString);
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
        LSSafeProtectionCrashLog(exception,LSSafeProtectorCrashTypeNSMutableString);
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
        LSSafeProtectionCrashLog(exception,LSSafeProtectorCrashTypeNSMutableString);
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
        LSSafeProtectionCrashLog(exception,LSSafeProtectorCrashTypeNSMutableString);
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
        LSSafeProtectionCrashLog(exception,LSSafeProtectorCrashTypeNSMutableString);
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
        LSSafeProtectionCrashLog(exception,LSSafeProtectorCrashTypeNSMutableString);
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
        LSSafeProtectionCrashLog(exception,LSSafeProtectorCrashTypeNSMutableString);
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
        LSSafeProtectionCrashLog(exception,LSSafeProtectorCrashTypeNSMutableString);
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
       LSSafeProtectionCrashLog(exception,LSSafeProtectorCrashTypeNSMutableString);
        newStr = nil;
    }
    @finally {
        return newStr;
    }
}

#pragma mark - NSMutableString特有的

-(void)safe_replaceCharactersInRange:(NSRange)range withString:(NSString *)aString
{
    @try {
         [self safe_replaceCharactersInRange:range withString:aString];
    }
    @catch (NSException *exception) {
        LSSafeProtectionCrashLog(exception,LSSafeProtectorCrashTypeNSMutableString);
    }
    @finally {
    }
}


-(NSUInteger)safe_replaceOccurrencesOfString:(NSString *)target withString:(NSString *)replacement options:(NSStringCompareOptions)options range:(NSRange)searchRange
{
    NSUInteger index=0;
    @try {
       index= [self safe_replaceOccurrencesOfString:target withString:replacement options:options range:searchRange];
    }
    @catch (NSException *exception) {
        LSSafeProtectionCrashLog(exception,LSSafeProtectorCrashTypeNSMutableString);
    }
    @finally {
        return index;
    }
}



-(void)safe_insertString:(NSString *)aString atIndex:(NSUInteger)loc
{
    @try {
        [self safe_insertString:aString atIndex:loc];
    }
    @catch (NSException *exception) {
        LSSafeProtectionCrashLog(exception,LSSafeProtectorCrashTypeNSMutableString);
    }
    @finally {
    }
}


-(void)safe_deleteCharactersInRange:(NSRange)range
{
    @try {
        [self safe_deleteCharactersInRange:range];
    }
    @catch (NSException *exception) {
        LSSafeProtectionCrashLog(exception,LSSafeProtectorCrashTypeNSMutableString);
    }
    @finally {
    }
}


-(void)safe_appendString:(NSString *)aString
{
    @try {
        [self safe_appendString:aString];
    }
    @catch (NSException *exception) {
        LSSafeProtectionCrashLog(exception,LSSafeProtectorCrashTypeNSMutableString);
    }
    @finally {
    }
}

-(void)safe_setString:(NSString *)aString
{
    @try {
        [self safe_setString:aString];
    }
    @catch (NSException *exception) {
        LSSafeProtectionCrashLog(exception,LSSafeProtectorCrashTypeNSMutableString);
    }
    @finally {
    }
}



@end




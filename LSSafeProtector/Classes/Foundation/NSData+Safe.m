
//
//  NSData+Safe.m
//  LSSafeProtector
// https://github.com/lsmakethebest/LSSafeProtector
//
//  Created by liusong on 2018/9/13.
//

#import "NSData+Safe.h"
#import "NSObject+SafeCore.h"
@implementation NSData (Safe)

+(void)openSafeProtector
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        [self safe_exchangeInstanceMethod:NSClassFromString(@"NSConcreteData") originalSel:@selector(subdataWithRange:) newSel:@selector(safe_subdataWithRangeConcreteData:)];
        [self safe_exchangeInstanceMethod:NSClassFromString(@"NSConcreteData") originalSel:@selector(rangeOfData:options:range:) newSel:@selector(safe_rangeOfDataConcreteData:options:range:)];
        
        
        [self safe_exchangeInstanceMethod:NSClassFromString(@"_NSZeroData") originalSel:@selector(subdataWithRange:) newSel:@selector(safe_subdataWithRangeZeroData:)];
        [self safe_exchangeInstanceMethod:NSClassFromString(@"_NSZeroData") originalSel:@selector(rangeOfData:options:range:) newSel:@selector(safe_rangeOfDataZeroData:options:range:)];
        
        
        [self safe_exchangeInstanceMethod:NSClassFromString(@"_NSInlineData") originalSel:@selector(subdataWithRange:) newSel:@selector(safe_subdataWithRangeInlineData:)];
        [self safe_exchangeInstanceMethod:NSClassFromString(@"_NSInlineData") originalSel:@selector(rangeOfData:options:range:) newSel:@selector(safe_rangeOfDataInlineData:options:range:)];
       
        
        [self safe_exchangeInstanceMethod:NSClassFromString(@"__NSCFData") originalSel:@selector(subdataWithRange:) newSel:@selector(safe_subdataWithRangeCFData:)];
        [self safe_exchangeInstanceMethod:NSClassFromString(@"__NSCFData") originalSel:@selector(rangeOfData:options:range:) newSel:@selector(safe_rangeOfDataCFData:options:range:)];
    });
}

-(NSData *)safe_subdataWithRangeConcreteData:(NSRange)range
{
    id object=nil;
    @try {
        object =  [self safe_subdataWithRangeConcreteData:range];
    }
    @catch (NSException *exception) {
        LSSafeProtectionCrashLog(exception,LSSafeProtectorCrashTypeNSData);
    }
    @finally {
        return object;
    }
}


-(NSData *)safe_subdataWithRangeZeroData:(NSRange)range
{
    id object=nil;
    @try {
        object =  [self safe_subdataWithRangeZeroData:range];
    }
    @catch (NSException *exception) {
        LSSafeProtectionCrashLog(exception,LSSafeProtectorCrashTypeNSData);
    }
    @finally {
        return object;
    }
}
-(NSData *)safe_subdataWithRangeInlineData:(NSRange)range
{
    id object=nil;
    @try {
        object =  [self safe_subdataWithRangeInlineData:range];
    }
    @catch (NSException *exception) {
        LSSafeProtectionCrashLog(exception,LSSafeProtectorCrashTypeNSData);
    }
    @finally {
        return object;
    }
}
-(NSData *)safe_subdataWithRangeCFData:(NSRange)range
{
    id object=nil;
    @try {
        object =  [self safe_subdataWithRangeCFData:range];
    }
    @catch (NSException *exception) {
        LSSafeProtectionCrashLog(exception,LSSafeProtectorCrashTypeNSData);
    }
    @finally {
        return object;
    }
}




-(NSRange)safe_rangeOfDataConcreteData:(NSData *)dataToFind options:(NSDataSearchOptions)mask range:(NSRange)searchRange
{
    NSRange object;
    @try {
        object =  [self safe_rangeOfDataConcreteData:dataToFind options:mask range:searchRange];
    }
    @catch (NSException *exception) {
        LSSafeProtectionCrashLog(exception,LSSafeProtectorCrashTypeNSData);
    }
    @finally {
        return object;
    }
}


-(NSRange)safe_rangeOfDataInlineData:(NSData *)dataToFind options:(NSDataSearchOptions)mask range:(NSRange)searchRange
{
    NSRange object;
    @try {
        object =  [self safe_rangeOfDataInlineData:dataToFind options:mask range:searchRange];
    }
    @catch (NSException *exception) {
        LSSafeProtectionCrashLog(exception,LSSafeProtectorCrashTypeNSData);
    }
    @finally {
        return object;
    }
}


-(NSRange)safe_rangeOfDataZeroData:(NSData *)dataToFind options:(NSDataSearchOptions)mask range:(NSRange)searchRange
{
    NSRange object;
    @try {
        object =  [self safe_rangeOfDataZeroData:dataToFind options:mask range:searchRange];
    }
    @catch (NSException *exception) {
        LSSafeProtectionCrashLog(exception,LSSafeProtectorCrashTypeNSData);
    }
    @finally {
        return object;
    }
}


-(NSRange)safe_rangeOfDataCFData:(NSData *)dataToFind options:(NSDataSearchOptions)mask range:(NSRange)searchRange
{
    NSRange object;
    @try {
        object =  [self safe_rangeOfDataCFData:dataToFind options:mask range:searchRange];
    }
    @catch (NSException *exception) {
        LSSafeProtectionCrashLog(exception,LSSafeProtectorCrashTypeNSData);
    }
    @finally {
        return object;
    }
}




@end



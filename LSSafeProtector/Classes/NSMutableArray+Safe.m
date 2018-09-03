//
//  NSMutableArray+Safe.m
// https://github.com/lsmakethebest/LSSafeProtector
//
//  Created by liusong on 2018/4/20.
//  Copyright © 2018年 liusong. All rights reserved.

#import "NSMutableArray+Safe.h"
#import "NSObject+Safe.h"
@implementation NSMutableArray (Safe)

+(void)openSafeProtector
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        //方法交换只要一次就好
        Class dClass=NSClassFromString(@"__NSArrayM");
        //由于低于11.0交换此方法会导致有键盘显示的地方，此时退到后台会crash [UIKeyboardLayoutStar release]: message sent to deallocated instance 0x7fd762cc11f0
        if ([UIDevice currentDevice].systemVersion.doubleValue>=11.0) {
            [self safe_exchangeInstanceMethod:dClass originalSel:@selector(objectAtIndex:) newSel:@selector(safe_objectAtIndexM:)];
        }
        //因为11.0以上系统才会调用此方法，所以大于11.0才交换此方法
        if([UIDevice currentDevice].systemVersion.doubleValue>=11.0){
            [self safe_exchangeInstanceMethod:dClass originalSel:@selector(objectAtIndexedSubscript:) newSel:@selector(safe_objectAtIndexedSubscriptM:)];
        }
        
        [self safe_exchangeInstanceMethod:dClass originalSel:@selector(insertObject:atIndex:) newSel:@selector(safe_insertObject:atIndex:)];
        [self safe_exchangeInstanceMethod:dClass originalSel:@selector(removeObjectAtIndex:) newSel:@selector(safe_removeObjectAtIndex:)];
        [self safe_exchangeInstanceMethod:dClass originalSel:@selector(replaceObjectAtIndex:withObject:) newSel:@selector(safe_replaceObjectAtIndex:withObject:)];
    });
}



-(id)safe_objectAtIndexedSubscriptM:(NSUInteger)index
{
    id object=nil;
    @try {
        object =  [self safe_objectAtIndexedSubscriptM:index];
    }
    @catch (NSException *exception) {
        LSSafeProtectionCrashLog(exception,LSSafeProtectorCrashTypeNSMutableArray);
    }
    @finally {
        return object;
    }
}

-(id)safe_objectAtIndexM:(NSUInteger)index
{
    id object=nil;
    @try {
        object= [self safe_objectAtIndexM:index];
    }
    @catch (NSException *exception) {
        LSSafeProtectionCrashLog(exception,LSSafeProtectorCrashTypeNSMutableArray);
    }
    @finally {
        return object;
    }
}


- (void)safe_insertObject:(id)anObject atIndex:(NSUInteger)index
{
    @try {
        [self safe_insertObject:anObject atIndex:index];
    }
    @catch (NSException *exception) {
        LSSafeProtectionCrashLog(exception,LSSafeProtectorCrashTypeNSMutableArray);
    }
    @finally {
        
    }
}


- (void)safe_removeObjectAtIndex:(NSUInteger)index
{
    @try {
        [self safe_removeObjectAtIndex:index];
    }
    @catch (NSException *exception) {
        LSSafeProtectionCrashLog(exception,LSSafeProtectorCrashTypeNSMutableArray);
    }
    @finally {
        
    }
}


- (void)safe_replaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject {
    
    @try {
        [self safe_replaceObjectAtIndex:index withObject:anObject];
    }
    @catch (NSException *exception) {
        LSSafeProtectionCrashLog(exception,LSSafeProtectorCrashTypeNSMutableArray);
    }
    @finally {
        
    }
}

@end

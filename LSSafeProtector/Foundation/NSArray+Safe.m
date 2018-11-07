//
//  NSArray+Safe.m
// https://github.com/lsmakethebest/LSSafeProtector
//
//  Created by liusong on 2018/4/20.
//  Copyright © 2018年 liusong. All rights reserved.
//

#import "NSArray+Safe.h"
#import "NSObject+SafeSwizzle.h"
#import "LSSafeProtector.h"

@implementation NSArray (Safe)

+(void)openSafeProtector
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        [self safe_exchangeInstanceMethod:objc_getClass("__NSPlaceholderArray") originalSel:@selector(initWithObjects:count:) newSel:@selector(safe_initWithObjects:count:)];
        
        [self safe_exchangeInstanceMethod:objc_getClass("__NSArrayI") originalSel:@selector(objectAtIndex:) newSel:@selector(safe_objectAtIndexI:)];
        [self safe_exchangeInstanceMethod:objc_getClass("__NSArrayI") originalSel:@selector(objectAtIndexedSubscript:) newSel:@selector(safe_objectAtIndexedSubscriptI:)];
        
        [self safe_exchangeInstanceMethod:objc_getClass("__NSArray0") originalSel:@selector(objectAtIndex:) newSel:@selector(safe_objectAtIndex0:)];
        
        [self safe_exchangeInstanceMethod:objc_getClass("__NSSingleObjectArrayI") originalSel:@selector(objectAtIndex:) newSel:@selector(safe_objectAtIndexSI:)];
        
        
        //这个方法不交换 会导致启动时crash，原因未知 NSKeyValuePopPendingNotificationPerThread() EXC_BAD_ACCESS
        //        [self safe_exchangeInstanceMethod:objc_getClass("__NSCFArray") originalSel:@selector(objectAtIndex:) newSel:@selector(safe_objectAtIndexCFArray:)];
        
        [self safe_exchangeInstanceMethod:objc_getClass("__NSCFArray") originalSel:@selector(insertObject:atIndex:) newSel:@selector(safe_insertObjectCFArray:atIndex:)];
        
        [self safe_exchangeInstanceMethod:objc_getClass("__NSCFArray") originalSel:@selector(removeObjectAtIndex:) newSel:@selector(safe_removeObjectAtIndexCFArray:)];
        
        [self safe_exchangeInstanceMethod:objc_getClass("__NSCFArray") originalSel:@selector(replaceObjectAtIndex:withObject:) newSel:@selector(safe_replaceObjectAtIndexCFArray:withObject:)];
        
    });
}
- (void)safe_insertObjectCFArray:(id)anObject atIndex:(NSUInteger)index
{
    @try {
        [self safe_insertObjectCFArray:anObject atIndex:index];
    }
    @catch (NSException *exception) {
        LSSafeProtectionCrashLog(exception,LSSafeProtectorCrashTypeNSArray);
    }
    @finally {
        
    }
}
- (void)safe_removeObjectAtIndexCFArray:(NSUInteger)index
{
    @try {
        [self safe_removeObjectAtIndexCFArray:index];
    }
    @catch (NSException *exception) {
        LSSafeProtectionCrashLog(exception,LSSafeProtectorCrashTypeNSArray);
    }
    @finally {
        
    }
}

- (void)safe_replaceObjectAtIndexCFArray:(NSUInteger)index withObject:(id)anObject {
    
    @try {
        [self safe_replaceObjectAtIndexCFArray:index withObject:anObject];
    }
    @catch (NSException *exception) {
        LSSafeProtectionCrashLog(exception,LSSafeProtectorCrashTypeNSArray);
    }
    @finally {
        
    }
}

-(instancetype)safe_initWithObjects:(id  _Nonnull const [])objects count:(NSUInteger)cnt
{
    
    id instance = nil;
    @try {
        instance = [self safe_initWithObjects:objects count:cnt];
    }
    @catch (NSException *exception) {
        LSSafeProtectionCrashLog(exception,LSSafeProtectorCrashTypeNSArray);
        
        //以下是对错误数据的处理，把为nil的数据去掉,然后初始化数组
        NSInteger newObjsIndex = 0;
        id   newObjects[cnt];
        
        for (int i = 0; i < cnt; i++) {
            if (objects[i] != nil) {
                newObjects[newObjsIndex] = objects[i];
                newObjsIndex++;
            }
        }
        instance = [self safe_initWithObjects:newObjects count:newObjsIndex];
    }
    @finally {
        return instance;
    }
    
}
-(id)safe_objectAtIndexedSubscriptI:(NSUInteger)index
{
    id object=nil;
    @try {
        object = [self safe_objectAtIndexedSubscriptI:index];
    }
    @catch (NSException *exception) {
        LSSafeProtectionCrashLog(exception,LSSafeProtectorCrashTypeNSArray);
    }
    @finally {
        return object;
    }
}
-(id)safe_objectAtIndexI:(NSUInteger)index
{
    id object=nil;
    @try {
        object = [self safe_objectAtIndexI:index];
    }
    @catch (NSException *exception) {
        LSSafeProtectionCrashLog(exception,LSSafeProtectorCrashTypeNSArray);
    }
    @finally {
        return object;
    }
}

-(id)safe_objectAtIndex0:(NSUInteger)index
{
    id object=nil;
    @try {
        object = [self safe_objectAtIndex0:index];
    }
    @catch (NSException *exception) {
        LSSafeProtectionCrashLog(exception,LSSafeProtectorCrashTypeNSArray);
    }
    @finally {
        return object;
    }
}
-(id)safe_objectAtIndexSI:(NSUInteger)index
{
    id object=nil;
    @try {
        object = [self safe_objectAtIndexSI:index];
    }
    @catch (NSException *exception) {
        LSSafeProtectionCrashLog(exception,LSSafeProtectorCrashTypeNSArray);
    }
    @finally {
        return object;
    }
}

-(id)safe_objectAtIndexCFArray:(NSUInteger)index
{
    id object=nil;
    @try {
        return  object = [self safe_objectAtIndexCFArray:index];
    }
    @catch (NSException *exception) {
        LSSafeProtectionCrashLog(exception,LSSafeProtectorCrashTypeNSArray);
    }
    @finally {
        return object;
    }
}

@end




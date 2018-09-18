//
//  NSArray+Safe.m
// https://github.com/lsmakethebest/LSSafeProtector
//
//  Created by liusong on 2018/4/20.
//  Copyright © 2018年 liusong. All rights reserved.
//

#import "NSArray+Safe.h"
#import "NSObject+SafeCore.h"


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
        
        // <=10系统为 __NSArrayI 或 __NSArray0 或 __NSSingleObjectArrayI
        //这里这个类不做hook，会导致无缘无故crash
//        [self safe_exchangeInstanceMethod:objc_getClass("__NSCFArray") originalSel:@selector(objectAtIndex:) newSel:@selector(safe_objectAtIndexCFArray:)];
        
    });
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
        object = [self safe_objectAtIndexCFArray:index];
    }
    @catch (NSException *exception) {
        LSSafeProtectionCrashLog(exception,LSSafeProtectorCrashTypeNSArray);
    }
    @finally {
        return object;
    }
}

@end




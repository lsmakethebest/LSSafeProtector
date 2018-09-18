
//
//  NSOrderedSet+Safe.m
//  LSSafeProtector
// https://github.com/lsmakethebest/LSSafeProtector
//
//  Created by liusong on 2018/9/13.
//

#import "NSOrderedSet+Safe.h"
#import "NSObject+SafeCore.h"
@implementation NSOrderedSet (Safe)


+(void)openSafeProtector
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class dClass=NSClassFromString(@"__NSPlaceholderOrderedSet");
        [self safe_exchangeInstanceMethod:dClass originalSel:@selector(initWithObjects:count:) newSel:@selector(safe_initWithObjects:count:)];
        [self safe_exchangeInstanceMethod:NSClassFromString(@"__NSOrderedSetI") originalSel:@selector(objectAtIndex:) newSel:@selector(safe_objectAtIndex:)];
    });
}
-(instancetype)safe_initWithObjects:(id  _Nonnull const [])objects count:(NSUInteger)cnt
{
    id instance = nil;
    @try {
        instance = [self safe_initWithObjects:objects count:cnt];
    }
    @catch (NSException *exception) {
        LSSafeProtectionCrashLog(exception,LSSafeProtectorCrashTypeNSOrderedSet);
        
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

-(id)safe_objectAtIndex:(NSUInteger)idx
{
    id object=nil;
    @try {
        object = [self safe_objectAtIndex:idx];
    }
    @catch (NSException *exception) {
        LSSafeProtectionCrashLog(exception,LSSafeProtectorCrashTypeNSOrderedSet);
    }
    @finally {
        return object;
    }
}

@end

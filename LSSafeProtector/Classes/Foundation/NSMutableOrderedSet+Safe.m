
//
//  NSMutableOrderedSet+Safe.m
//  LSSafeProtector
// https://github.com/lsmakethebest/LSSafeProtector
//
//  Created by liusong on 2018/9/13.
//

#import "NSMutableOrderedSet+Safe.h"
#import "NSObject+SafeCore.h"
@implementation NSMutableOrderedSet (Safe)

+(void)openSafeProtector
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        Class dClass=NSClassFromString(@"__NSOrderedSetM");
        
        [self safe_exchangeInstanceMethod:dClass originalSel:@selector(objectAtIndex:) newSel:@selector(safe_objectAtIndex:)];
        [self safe_exchangeInstanceMethod:dClass originalSel:@selector(insertObject:atIndex:) newSel:@selector(safe_insertObject:atIndex:)];
        [self safe_exchangeInstanceMethod:dClass originalSel:@selector(removeObjectAtIndex:) newSel:@selector(safe_removeObjectAtIndex:)];
        [self safe_exchangeInstanceMethod:dClass originalSel:@selector(replaceObjectAtIndex:withObject:) newSel:@selector(safe_replaceObjectAtIndex:withObject:)];
        [self safe_exchangeInstanceMethod:dClass originalSel:@selector(addObject:) newSel:@selector(safe_addObject:)];
    });
}
-(id)safe_objectAtIndex:(NSUInteger)idx
{
    id object=nil;
    @try {
        object = [self safe_objectAtIndex:idx];
    }
    @catch (NSException *exception) {
        LSSafeProtectionCrashLog(exception,LSSafeProtectorCrashTypeNSMutableOrderedSet);
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
        LSSafeProtectionCrashLog(exception,LSSafeProtectorCrashTypeNSMutableOrderedSet);
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
        LSSafeProtectionCrashLog(exception,LSSafeProtectorCrashTypeNSMutableOrderedSet);
    }
    @finally {
        
    }
}


- (void)safe_replaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject {
    
    @try {
        [self safe_replaceObjectAtIndex:index withObject:anObject];
    }
    @catch (NSException *exception) {
        LSSafeProtectionCrashLog(exception,LSSafeProtectorCrashTypeNSMutableOrderedSet);
    }
    @finally {
        
    }
}

- (void)safe_addObject:(id)object{
    
    @try {
        [self safe_addObject:object];
    }
    @catch (NSException *exception) {
        LSSafeProtectionCrashLog(exception,LSSafeProtectorCrashTypeNSMutableOrderedSet);
    }
    @finally {
        
    }
}


@end

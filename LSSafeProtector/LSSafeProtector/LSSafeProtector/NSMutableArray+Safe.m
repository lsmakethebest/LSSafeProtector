//

//  NSMutableArray+Safe.m
//  test
//
//  Created by liusong on 2018/6/27.
//

#import "NSMutableArray+Safe.h"
#import "NSObject+Safe.h"
@implementation NSMutableArray (Safe)

+(void)openSafeProtector
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        //方法交换只要一次就好
        Class dClass=NSClassFromString(@"__NSArrayM");
        [self safe_exchangeInstanceMethod:dClass originalSel:@selector(objectAtIndex:) newSel:@selector(safe_objectAtIndexM:)];
        
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

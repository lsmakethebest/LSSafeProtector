//
//  NSCache+Safe.m
//  LSSafeProtector
// https://github.com/lsmakethebest/LSSafeProtector
//
//  Created by liusong on 2018/9/13.
//

#import "NSCache+Safe.h"
#import "NSObject+SafeCore.h"
@implementation NSCache (Safe)

+(void)openSafeProtector
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class dClass=NSClassFromString(@"NSCache");
        [self safe_exchangeInstanceMethod:dClass originalSel:@selector(setObject:forKey:) newSel:@selector(safe_setObject:forKey:)];
        
        [self safe_exchangeInstanceMethod:dClass originalSel:@selector(setObject:forKey:cost:) newSel:@selector(safe_setObject:forKey:cost:)];
    });
}

-(void)safe_setObject:(id)obj forKey:(id)key
{
    if(key&&obj){
        [self safe_setObject:obj forKey:key];
    }else{
        NSString *reason=[NSString stringWithFormat:@"NSCache %@ key and value can`t be nil",NSStringFromSelector(_cmd)];
        NSException *exception=[NSException exceptionWithName:reason reason:reason userInfo:nil];
        LSSafeProtectionCrashLog(exception,LSSafeProtectorCrashTypeNSCache);
    }
}
-(void)safe_setObject:(id)obj forKey:(id)key cost:(NSUInteger)g
{
    if(key&&obj){
        [self safe_setObject:obj forKey:key cost:g];
    }else{
        NSString *reason=[NSString stringWithFormat:@"NSCache %@ key and value can`t be nil",NSStringFromSelector(_cmd)];
        NSException *exception=[NSException exceptionWithName:reason reason:reason userInfo:nil];
        LSSafeProtectionCrashLog(exception,LSSafeProtectorCrashTypeNSCache);
    }
}


@end

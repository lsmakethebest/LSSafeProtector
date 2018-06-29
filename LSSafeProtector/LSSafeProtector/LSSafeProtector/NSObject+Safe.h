

//
//  NSObject+Safe.h
//
//  Created by liusong on 2018/4/20.
//

#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#define LSSafeLog(fmt, ...) NSLog(fmt, ##__VA_ARGS__)
//#define LSSafeProtectionLog(fmt, ...)
#define  LSSafeProtectionCrashLog(exception) [NSObject safe_logCrashWithException:exception]

@interface  NSObject (Safe)

//打开目前所支持的所有安全保护
+ (void)openAllSafeProtector;

//打开当前类安全保护
+ (void)openSafeProtector;


//交换类方法
+ (void)safe_exchangeClassMethod:(Class)dClass    originalSel:(SEL)originalSelector newSel:(SEL)newSelector;

//交换对象方法
+ (void)safe_exchangeInstanceMethod:(Class)dClass originalSel:(SEL)originalSelector newSel: (SEL)newSelector;

+ (void)safe_logCrashWithException:(NSException *)exception;


@end




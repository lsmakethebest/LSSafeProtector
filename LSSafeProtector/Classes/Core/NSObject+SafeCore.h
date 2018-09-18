//
//  NSObject+SafeCore.h
//  LSSafeProtector
// https://github.com/lsmakethebest/LSSafeProtector
//
//  Created by liusong on 2018/9/18.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

#define  LSSafeLog(fmt, ...)  NSLog(fmt, ##__VA_ARGS__)
#define  LSSafeProtectionCrashLog(exception,crash)   [NSObject safe_logCrashWithException:exception crashType:crash]

//NSNotificationCenter 即使设置LogTypeAll 也不会打印，
//iOS9之后系统已经优化了，即使不移除也不会崩溃， 所以仅iOS8系统会出现此类型carsh,但是有的类是在dealloc里移除通知，而我们是在所有类的dealloc方法之前检测是否移除，没移除则去移除所以会误报crash，干脆直接不报此类型crash了

typedef enum : NSUInteger {
    LSSafeProtectorLogTypeNone,//所有log都不打印
    LSSafeProtectorLogTypeAll,//打印所有log
} LSSafeProtectorLogType;

//哪个类型的crash
typedef enum : NSUInteger {
    LSSafeProtectorCrashTypeSelector,
    LSSafeProtectorCrashTypeKVO,
    LSSafeProtectorCrashTypeNSArray,
    LSSafeProtectorCrashTypeNSMutableArray,
    LSSafeProtectorCrashTypeNSDictionary,
    LSSafeProtectorCrashTypeNSMutableDictionary,
    LSSafeProtectorCrashTypeNSStirng,
    LSSafeProtectorCrashTypeNSMutableString,
    LSSafeProtectorCrashTypeNSAttributedString,
    LSSafeProtectorCrashTypeNSMutableAttributedString,
    LSSafeProtectorCrashTypeNSNotificationCenter,
    LSSafeProtectorCrashTypeNSUserDefaults,
    LSSafeProtectorCrashTypeNSCache,
    LSSafeProtectorCrashTypeNSSet,
    LSSafeProtectorCrashTypeNSMutableSet,
    LSSafeProtectorCrashTypeNSData,
    LSSafeProtectorCrashTypeNSMutableData,
    LSSafeProtectorCrashTypeNSOrderedSet,
    LSSafeProtectorCrashTypeNSMutableOrderedSet,
    
} LSSafeProtectorCrashType;



typedef void(^LSSafeProtectorBlock)(NSException *exception,LSSafeProtectorCrashType crashType);

@interface NSObject (SafeCore)

//打开目前所支持的所有安全保护 回调block
+ (void)openAllSafeProtectorWithIsDebug:(BOOL)isDebug block:(LSSafeProtectorBlock)block;

//打开当前类安全保护
+ (void)openSafeProtector;

//交换类方法
+ (void)safe_exchangeClassMethod:(Class)dClass    originalSel:(SEL)originalSelector newSel:(SEL)newSelector;

//交换对象方法
+ (void)safe_exchangeInstanceMethod:(Class)dClass originalSel:(SEL)originalSelector newSel: (SEL)newSelector;

//打印crash信息
+ (void)safe_logCrashWithException:(NSException *)exception crashType:(LSSafeProtectorCrashType)crashType;

@end

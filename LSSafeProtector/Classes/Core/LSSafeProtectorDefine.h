//
//  LSSafeProtectorDefine.h
// https://github.com/lsmakethebest/LSSafeProtector
//
//  Created by liusong on 2018/9/18.
//

#ifndef LSSafeProtectorDefine_h
#define LSSafeProtectorDefine_h
@class LSSafeProtector;

#define  LSSafeLog(fmt, ...)  NSLog(fmt, ##__VA_ARGS__)
#define  LSSafeProtectionCrashLog(exception,crash)   [LSSafeProtector safe_logCrashWithException:exception crashType:crash]

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


#endif /* LSSafeProtectorDefine_h */

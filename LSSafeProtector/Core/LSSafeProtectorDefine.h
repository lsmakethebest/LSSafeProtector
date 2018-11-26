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
typedef NS_OPTIONS(NSUInteger,LSSafeProtectorCrashType)
{
    LSSafeProtectorCrashTypeSelector                  = 1 << 0,
    LSSafeProtectorCrashTypeKVO                       = 1 << 1,
    LSSafeProtectorCrashTypeNSNotificationCenter      = 1 << 2,
    LSSafeProtectorCrashTypeNSUserDefaults            = 1 << 3,
    LSSafeProtectorCrashTypeNSCache                   = 1 << 4,
    
    LSSafeProtectorCrashTypeNSArray                   = 1 << 5,
    LSSafeProtectorCrashTypeNSMutableArray            = 1 << 6,
    
    LSSafeProtectorCrashTypeNSDictionary              = 1 << 7,
    LSSafeProtectorCrashTypeNSMutableDictionary       = 1 << 8,
    
    LSSafeProtectorCrashTypeNSStirng                  = 1 << 9,
    LSSafeProtectorCrashTypeNSMutableString           = 1 << 10,
    
    LSSafeProtectorCrashTypeNSAttributedString        = 1 << 11,
    LSSafeProtectorCrashTypeNSMutableAttributedString = 1 << 12,
    
    LSSafeProtectorCrashTypeNSSet                     = 1 << 13,
    LSSafeProtectorCrashTypeNSMutableSet              = 1 << 14,
    
    LSSafeProtectorCrashTypeNSData                    = 1 << 15,
    LSSafeProtectorCrashTypeNSMutableData             = 1 << 16,
    
    LSSafeProtectorCrashTypeNSOrderedSet              = 1 << 17,
    LSSafeProtectorCrashTypeNSMutableOrderedSet       = 1 << 18,
    
    LSSafeProtectorCrashTypeNSArrayContainer = LSSafeProtectorCrashTypeNSArray|LSSafeProtectorCrashTypeNSMutableArray,
    
    LSSafeProtectorCrashTypeNSDictionaryContainer = LSSafeProtectorCrashTypeNSDictionary|LSSafeProtectorCrashTypeNSMutableDictionary,
    
    LSSafeProtectorCrashTypeNSStringContainer = LSSafeProtectorCrashTypeNSStirng|LSSafeProtectorCrashTypeNSMutableString,
    
    LSSafeProtectorCrashTypeNSAttributedStringContainer = LSSafeProtectorCrashTypeNSAttributedString|LSSafeProtectorCrashTypeNSMutableAttributedString,
    
    LSSafeProtectorCrashTypeNSSetContainer = LSSafeProtectorCrashTypeNSSet|LSSafeProtectorCrashTypeNSMutableSet,
    
    LSSafeProtectorCrashTypeNSDataContainer = LSSafeProtectorCrashTypeNSData|LSSafeProtectorCrashTypeNSMutableData,
    
      LSSafeProtectorCrashTypeNSOrderedSetContainer = LSSafeProtectorCrashTypeNSOrderedSet|LSSafeProtectorCrashTypeNSMutableOrderedSet,
    
    LSSafeProtectorCrashTypeAll =
        //支持所有类型的crash
    LSSafeProtectorCrashTypeSelector
    |LSSafeProtectorCrashTypeKVO
    |LSSafeProtectorCrashTypeNSNotificationCenter
    |LSSafeProtectorCrashTypeNSUserDefaults
    |LSSafeProtectorCrashTypeNSCache
    |LSSafeProtectorCrashTypeNSArrayContainer
    |LSSafeProtectorCrashTypeNSDictionaryContainer
    |LSSafeProtectorCrashTypeNSStringContainer
    |LSSafeProtectorCrashTypeNSAttributedStringContainer
    |LSSafeProtectorCrashTypeNSSetContainer
    |LSSafeProtectorCrashTypeNSDataContainer
    |LSSafeProtectorCrashTypeNSOrderedSetContainer
};



typedef void(^LSSafeProtectorBlock)(NSException *exception,LSSafeProtectorCrashType crashType);


#endif /* LSSafeProtectorDefine_h */

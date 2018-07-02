

//
//  NSObject+Safe.h
//
//  Created by liusong on 2018/4/20.
//

#import <UIKit/UIKit.h>
#import <objc/runtime.h>

//为什么需要忽略KVO和NotificationCenter,因为KVO好多人都是在dealloc里移除，而我们是在即将dealloc之前判断是否有未移除的，如果有则移除，此时我们去移除了本该在dealloc里移除的，而dealloc里又移除一遍，所以会报Cannot remove an observer  for the key path "fractionCompleted" from because it is not registered as an observer   或者  dealloc时通知中心未移除本对象，如果我们在dealloc方法之后处理，因为dealloc销毁，再去调用会导致exec bad address
//程序现在默认将NSNotificationCenterCrash忽略 不再打印log信息,KVO类型也不需要忽略了

//kvo类型在dealloc时存了一份字典保留监听了哪些对象的kaypath，同时移除。然后在类自己的dealloc方法里又移除一遍。此时可能会报错，但是如果保留的那份字典里有相同的keypath则不打印crash信息，没有才打印。所以在dealloc里remove两遍会不打印crash信息
#define  LSSafeLog(fmt, ...)  NSLog(fmt, ##__VA_ARGS__)
#define  LSSafeProtectionCrashLog(exception,crash)   [NSObject safe_logCrashWithException:exception crashType:crash]


typedef enum : NSUInteger {
    LSSafeProtectorLogTypeNone,//所有log都不打印
    LSSafeProtectorLogTypeAll,//打印所有log
    LSSafeProtectorLogTypeIgnoreKVO,//忽略KVO类型log
    LSSafeProtectorLogTypeIgnoreNSNotificationCenter,//忽略NSNotificationCenter类型log
    LSSafeProtectorLogTypeIgnoreKVOAndNSNotificationCenter,//忽略KVO和NSNotificationCenter类型log
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
    
} LSSafeProtectorCrashType;



typedef void(^LSSafeProtectorBlock)(NSException *exception,LSSafeProtectorCrashType crashType);


@interface  NSObject (Safe)

//设置打印哪些log
+(void)setSafeProtectorLogType:(LSSafeProtectorLogType)safeProtectorLogType;

//打开目前所支持的所有安全保护 回调block
+ (void)openAllSafeProtectorWithBlock:(LSSafeProtectorBlock)block;

//打开当前类安全保护
+ (void)openSafeProtector;


//交换类方法
+ (void)safe_exchangeClassMethod:(Class)dClass    originalSel:(SEL)originalSelector newSel:(SEL)newSelector;

//交换对象方法
+ (void)safe_exchangeInstanceMethod:(Class)dClass originalSel:(SEL)originalSelector newSel: (SEL)newSelector;

+ (void)safe_logCrashWithException:(NSException *)exception crashType:(LSSafeProtectorCrashType)crashType;


@end




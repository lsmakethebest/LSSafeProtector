//
//  NSObject+SafeCore.m
//  LSSafeProtector
// https://github.com/lsmakethebest/LSSafeProtector
//
//  Created by liusong on 2018/9/18.
//

#import "NSObject+SafeCore.h"
#import "NSObject+KVOSafe.h"
#import "NSMutableArray+MRCSafe.h"
static  LSSafeProtectorLogType ls_safe_logType=LSSafeProtectorLogTypeAll;
static  LSSafeProtectorBlock lsSafeProtectorBlock;

@implementation NSObject (SafeCore)


+(void)openAllSafeProtectorWithIsDebug:(BOOL)isDebug block:(LSSafeProtectorBlock)block
{
    if ([NSStringFromClass([self class]) isEqualToString:@"NSObject"]) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            [NSObject openSafeProtector];//开启防止selecetor crash
            [NSArray openSafeProtector];
            [NSMutableArray openSafeProtector];
            [NSDictionary openSafeProtector];
            [NSMutableDictionary openSafeProtector];
            [NSMutableArray openMRCSafeProtector];
            [NSString openSafeProtector];
            [NSMutableString openSafeProtector];
            [NSAttributedString openSafeProtector];
            [NSMutableAttributedString openSafeProtector];
            [NSNotificationCenter openSafeProtector];
            [NSObject openKVOSafeProtector];
            [NSUserDefaults openSafeProtector];
            [NSCache openSafeProtector];
            [NSSet openSafeProtector];
            [NSMutableSet openSafeProtector];
            [NSOrderedSet openSafeProtector];
            [NSMutableOrderedSet openSafeProtector];
            [NSData openSafeProtector];
            [NSMutableData openSafeProtector];
            if (isDebug) {
                ls_safe_logType=LSSafeProtectorLogTypeAll;
            }else{
                ls_safe_logType=LSSafeProtectorLogTypeNone;
            }
            lsSafeProtectorBlock=block;
        });
    }else{
        //只有NSObject 能调用openAllSafeProtector其他类调用没效果
        LSSafeLog(@"------- 请用  [NSObject openAllSafeProtectorWithBlock:] 调用此方法");
    }
}



#pragma mark - 交换类方法
+ (void)safe_exchangeClassMethod:(Class) dClass
                     originalSel:(SEL)originalSelector
                          newSel:(SEL)newSelector {
    
    Method originalMethod = class_getClassMethod(dClass, originalSelector);
    Method newMethod = class_getClassMethod(dClass, newSelector);
    // Method中包含IMP函数指针，通过替换IMP，使SEL调用不同函数实现
    //方法newMethod的  返回值表示是否添加成功
    BOOL isAdd = class_addMethod(self, originalSelector,
                                 method_getImplementation(newMethod),
                                 method_getTypeEncoding(newMethod));
    // class_addMethod:如果发现方法已经存在，会失败返回，也可以用来做检查用,我们这里是为了避免源方法没有实现的情况;如果方法没有存在,我们则先尝试添加被替换的方法的实现
    if (isAdd) {
        class_replaceMethod(self, newSelector,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));
    } else {
        // 添加失败：说明源方法已经有实现，直接将两个方法的实现交换即
        method_exchangeImplementations(originalMethod, newMethod);
    }
}
#pragma mark - 交换对象方法
+ (void)safe_exchangeInstanceMethod : (Class) dClass originalSel:(SEL)originalSelector newSel: (SEL)newSelector {
    Method originalMethod = class_getInstanceMethod(dClass, originalSelector);
    Method newMethod = class_getInstanceMethod(dClass, newSelector);
    // Method中包含IMP函数指针，通过替换IMP，使SEL调用不同函数实现
    //方法newMethod的  返回值表示是否添加成功
    BOOL isAdd = class_addMethod(dClass, originalSelector,
                                 method_getImplementation(newMethod),
                                 method_getTypeEncoding(newMethod));
    // class_addMethod:如果发现方法已经存在，会失败返回，也可以用来做检查用,我们这里是为了避免源方法没有实现的情况;如果方法没有存在,我们则先尝试添加被替换的方法的实现
    if (isAdd) {
        class_replaceMethod(dClass, newSelector,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));
    } else {
        // 添加失败：说明源方法已经有实现，直接将两个方法的实现交换即
        method_exchangeImplementations(originalMethod, newMethod);
    }
}


+ (void)safe_logCrashWithException:(NSException *)exception crashType:(LSSafeProtectorCrashType)crashType
{
    // 堆栈数据
    NSArray *callStackSymbolsArr = [NSThread callStackSymbols];
    
    //获取在哪个类的哪个方法中实例化的数组
    NSString *mainMessage = [self safe_getMainCallStackSymbolMessageWithCallStackSymbolArray: callStackSymbolsArr index:2 first:YES];
    
    if (mainMessage == nil) {
        mainMessage = @"崩溃方法定位失败,请您查看函数调用栈来查找crash原因";
    }
    
    NSString *crashName = [NSString stringWithFormat:@"\t\t[Crash Type]: %@",exception.name];
    
    NSString *crashReason = [NSString stringWithFormat:@"\t\t[Crash Reason]: %@",exception.reason];;
    NSString *crashLocation = [NSString stringWithFormat:@"\t\t[Crash Location]: %@",mainMessage];
    
    NSString *fullMessage = [NSString stringWithFormat:@"\n------------------------------------  Crash START -------------------------------------\n%@\n%@\n%@\n函数堆栈:\n%@\n------------------------------------   Crash END  -----------------------------------------", crashName, crashReason, crashLocation, exception.callStackSymbols];
    
    NSMutableDictionary *userInfo=[NSMutableDictionary dictionary];
    userInfo[@"callStackSymbols"]=[NSString stringWithFormat:@"%@",exception.callStackSymbols];
    userInfo[@"location"]=mainMessage;
    NSException *newException = [NSException exceptionWithName:exception.name reason:exception.reason userInfo:userInfo];
    if (lsSafeProtectorBlock) {
        lsSafeProtectorBlock(newException,crashType);
    }
    LSSafeProtectorLogType logType=ls_safe_logType;
    if (logType==LSSafeProtectorLogTypeNone) {
    }
    else if (logType==LSSafeProtectorLogTypeAll) {
        LSSafeLog(@"%@", fullMessage);
        NSAssert(NO, @"检测到崩溃，详情请查看上面信息");
    }
}

#pragma mark -   获取堆栈主要崩溃精简化的信息<根据正则表达式匹配出来
+ (NSString *)safe_getMainCallStackSymbolMessageWithCallStackSymbolArray:(NSArray *)callStackSymbolArray index:(NSInteger)index first:(BOOL)first
{
    NSString *  callStackSymbolString;
    if (callStackSymbolArray.count<=0) {
        return nil;
    }
    if (index<callStackSymbolArray.count) {
        callStackSymbolString=callStackSymbolArray[index];
    }
    //正则表达式
    //http://www.jianshu.com/p/b25b05ef170d
    
    //mainCallStackSymbolMsg 的格式为   +[类名 方法名]  或者 -[类名 方法名]
    __block NSString *mainCallStackSymbolMsg = nil;
    
    //匹配出来的格式为 +[类名 方法名]  或者 -[类名 方法名]
    NSString *regularExpStr = @"[-\\+]\\[.+\\]";
    
    NSRegularExpression *regularExp = [[NSRegularExpression alloc] initWithPattern:regularExpStr options:NSRegularExpressionCaseInsensitive error:nil];
    
    [regularExp enumerateMatchesInString:callStackSymbolString options:NSMatchingReportProgress range:NSMakeRange(0, callStackSymbolString.length) usingBlock:^(NSTextCheckingResult * _Nullable result, NSMatchingFlags flags, BOOL * _Nonnull stop) {
        if (result) {
            mainCallStackSymbolMsg = [callStackSymbolString substringWithRange:result.range];
            *stop = YES;
        }
    }];
    
    if (index==0) {
        return mainCallStackSymbolMsg;
    }
    if (mainCallStackSymbolMsg==nil) {
        NSInteger newIndex=0;
        if (first) {
            newIndex=callStackSymbolArray.count-1;
        }else{
            newIndex=index-1;
        }
        mainCallStackSymbolMsg = [self safe_getMainCallStackSymbolMessageWithCallStackSymbolArray:callStackSymbolArray index:newIndex first:NO];
    }
    return mainCallStackSymbolMsg;
}

@end

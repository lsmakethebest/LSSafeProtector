//
//  LSSafeProtector.m
// https://github.com/lsmakethebest/LSSafeProtector
//
//  Created by liusong on 2018/8/9.
//  Copyright © 2018年 liusong. All rights reserved.
//

#import "LSSafeProtector.h"

static  LSSafeProtectorLogType ls_safe_logType=LSSafeProtectorLogTypeAll;
static  LSSafeProtectorBlock lsSafeProtectorBlock;
static  BOOL LSSafeProtectorKVODebugInfoEnable=NO;
@interface NSObject (LSSafeProtector)
//打开当前类安全保护
+ (void)openSafeProtector;
+ (void)openKVOSafeProtector;
+(void)openMRCSafeProtector;
@end


#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincomplete-implementation"

@implementation NSObject (LSSafeProtector)
@end

#pragma clang diagnostic pop


@implementation LSSafeProtector

+(void)openSafeProtectorWithIsDebug:(BOOL)isDebug block:(LSSafeProtectorBlock)block
{
    [self openSafeProtectorWithIsDebug:isDebug types:LSSafeProtectorCrashTypeAll block:block];
}

+(void)openSafeProtectorWithIsDebug:(BOOL)isDebug types:(LSSafeProtectorCrashType)types block:(LSSafeProtectorBlock)block
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (types & LSSafeProtectorCrashTypeSelector) {
            //开启防止selecetor crash
            [NSObject openSafeProtector];
        }
        if (types & LSSafeProtectorCrashTypeNSArray) {
            [NSArray openSafeProtector];
        }
        
        if (types & LSSafeProtectorCrashTypeNSMutableArray) {
            [NSMutableArray openSafeProtector];
            [NSMutableArray openMRCSafeProtector];
        }
        
        if (types & LSSafeProtectorCrashTypeNSDictionary) {
            [NSDictionary openSafeProtector];
        }
        
        if (types & LSSafeProtectorCrashTypeNSMutableDictionary) {
            [NSMutableDictionary openSafeProtector];
        }
        
        if (types & LSSafeProtectorCrashTypeNSStirng) {
            [NSString openSafeProtector];
        }
        
        if (types & LSSafeProtectorCrashTypeNSMutableString) {
            [NSMutableString openSafeProtector];
        }
        
        if (types & LSSafeProtectorCrashTypeNSAttributedString) {
            [NSAttributedString openSafeProtector];
        }
        
        if (types & LSSafeProtectorCrashTypeNSMutableAttributedString) {
            [NSMutableAttributedString openSafeProtector];
        }
        
        if (types & LSSafeProtectorCrashTypeNSNotificationCenter) {
            [NSNotificationCenter openSafeProtector];
        }
    
        if (types & LSSafeProtectorCrashTypeKVO) {
            [NSObject openKVOSafeProtector];
        }
        
        if (types & LSSafeProtectorCrashTypeNSUserDefaults) {
            [NSUserDefaults openSafeProtector];
        }
        
        if (types & LSSafeProtectorCrashTypeNSCache) {
            [NSCache openSafeProtector];
        }
        
        if (types & LSSafeProtectorCrashTypeNSSet) {
            [NSSet openSafeProtector];
        }
        
        if (types & LSSafeProtectorCrashTypeNSMutableSet) {
            [NSMutableSet openSafeProtector];
        }
        
        if (types & LSSafeProtectorCrashTypeNSOrderedSet) {
            [NSOrderedSet openSafeProtector];
        }
        
        if (types & LSSafeProtectorCrashTypeNSMutableOrderedSet) {
            [NSMutableOrderedSet openSafeProtector];
        }
        
        if (types & LSSafeProtectorCrashTypeNSData) {
            [NSData openSafeProtector];
        }
        
        if (types & LSSafeProtectorCrashTypeNSMutableData) {
            [NSMutableData openSafeProtector];
        }
        
        if (isDebug) {
            ls_safe_logType=LSSafeProtectorLogTypeAll;
        }else{
            ls_safe_logType=LSSafeProtectorLogTypeNone;
        }
        lsSafeProtectorBlock=block;
    });
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
        assert(NO&&"检测到崩溃，详情请查看上面信息");
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
void safe_KVOCustomLog(NSString *format,...)
{
    if (LSSafeProtectorKVODebugInfoEnable) {
        va_list args;
        va_start(args, format);
        NSString *string = [[NSString alloc] initWithFormat:format arguments:args];
        NSString *strFormat = [NSString stringWithFormat:@"%@",string];
        NSLogv(strFormat, args);
        va_end(args);
    }
}

+(void)setLogEnable:(BOOL)enable
{
    LSSafeProtectorKVODebugInfoEnable=enable;
}

@end

//
//  LSSafeProtector.h
// https://github.com/lsmakethebest/LSSafeProtector

//  Created by liusong on 2018/8/9.
//  Copyright © 2018年 liusong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LSSafeProtectorDefine.h"

#define LSKVOSafeLog(fmt, ...) safe_KVOCustomLog(fmt,##__VA_ARGS__)

@interface LSSafeProtector : NSObject
    



/**
打开目前所支持的所有安全保护
 
 @param isDebug
 //isDebug=YES 代表测试环境，当捕获到crash时会利用断言闪退， 同时回调block
 //isDebug=NO  代表正式环境，当捕获到crash时不会利用断言闪退，会回调block
 @param block  回调的block
 */
+ (void)openSafeProtectorWithIsDebug:(BOOL)isDebug block:(LSSafeProtectorBlock)block;

/**
开启防止指定类型的crash

 @param isDebug
 //isDebug=YES 代表测试环境，当捕获到crash时会利用断言闪退， 同时回调block
 //isDebug=NO  代表正式环境，当捕获到crash时不会利用断言闪退，会回调block
 @param types 想防止哪些类crash
 @param block 回调的block
 */
+ (void)openSafeProtectorWithIsDebug:(BOOL)isDebug types:(LSSafeProtectorCrashType)types block:(LSSafeProtectorBlock)block;

+ (void)safe_logCrashWithException:(NSException *)exception crashType:(LSSafeProtectorCrashType)crashType;

//是否开启KVO添加移除日志信息，默认为NO
+ (void)setLogEnable:(BOOL)enable;
//自定义log函数
void safe_KVOCustomLog(NSString *format,...);

@end

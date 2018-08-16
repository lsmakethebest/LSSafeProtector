//
//  NSObject+KVOSafe.h
// https://github.com/lsmakethebest/LSSafeProtector
//
//  Created by liusong on 2018/4/20.
//  Copyright © 2018年 liusong. All rights reserved.

#import <Foundation/Foundation.h>

/**
 
 A addobserver B  A先dealloc  B未移除keypath的crash捕获不到，B先dealloc，B未移除keypath的crash可以捕获搭配
 1、重复添加相同的keyPath观察者，会重复调用 observeValueForKeyPath：...方法
 
 2、crash情况：
    1、移除未注册的观察者 会crash
    2、重复移除观察者 会crash
    3.添加了观察者但是没有实现-observeValueForKeyPath:ofObject:change:context:方法
    4.添加移除keypath=nil;
    5.添加移除observer=nil;
 */

@interface LSKVOObserverInfo:NSObject
@end

@interface NSObject (KVOSafe)

//打开KVO安全保护
+ (void)openKVOSafeProtector;


@end








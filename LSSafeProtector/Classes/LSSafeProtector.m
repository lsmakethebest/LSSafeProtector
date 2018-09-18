//
//  LSSafeProtector.m
// https://github.com/lsmakethebest/LSSafeProtector
//
//  Created by liusong on 2018/8/9.
//  Copyright © 2018年 liusong. All rights reserved.
//

#import "LSSafeProtector.h"
#import "NSObject+SafeCore.h"
@implementation LSSafeProtector

+(void)openSafeProtectorWithIsDebug:(BOOL)isDebug block:(LSSafeProtectorBlock)block
{
    [NSObject openAllSafeProtectorWithIsDebug:isDebug block:block];
}
    
@end

//
//  LSSafeProtector.h
// https://github.com/lsmakethebest/LSSafeProtector

//  Created by liusong on 2018/8/9.
//  Copyright © 2018年 liusong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSObject+SafeCore.h"
@interface LSSafeProtector : NSObject
    
//打开目前所支持的所有安全保护 回调block
+ (void)openSafeProtectorWithIsDebug:(BOOL)isDebug block:(LSSafeProtectorBlock)block;
    
@end

//
//  NSUserDefaults+Safe.h
//  LSSafeProtector
// https://github.com/lsmakethebest/LSSafeProtector
//
//  Created by liusong on 2018/9/13.
//

#import <Foundation/Foundation.h>

@interface NSUserDefaults (Safe)

/*
 可避免以下方法  key=nil时的崩溃
    objectForKey:
    stringForKey:
    arrayForKey:
    dataForKey:
    URLForKey:
    stringArrayForKey:
    floatForKey:
    doubleForKey:
    integerForKey:
    boolForKey:
 */
@end

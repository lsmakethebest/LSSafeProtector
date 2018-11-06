//
//  NSMutableSet+Safe.h
//  LSSafeProtector
// https://github.com/lsmakethebest/LSSafeProtector
//
//  Created by liusong on 2018/9/13.
//

#import <Foundation/Foundation.h>
/*
 可避免以下crash
 1.setWithObject:
 2.(instancetype)initWithObjects:(ObjectType)firstObj
 3.setWithObjects:(ObjectType)firstObj
 4.addObject:
 5.removeObject:
 */

@interface NSMutableSet (Safe)

@end

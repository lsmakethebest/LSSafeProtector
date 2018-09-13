//
//  NSMutableData+Safe.h
//  LSSafeProtector
// https://github.com/lsmakethebest/LSSafeProtector
//
//  Created by liusong on 2018/9/13.
//

#import <Foundation/Foundation.h>


/*
可防止以下crash
 1.resetBytesInRange:
 2.replaceBytesInRange:withBytes:
 3.replaceBytesInRange:withBytes:length:
 
 */

@interface NSMutableData (Safe)

@end

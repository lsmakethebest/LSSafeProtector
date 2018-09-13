//
//  NSCache+Safe.h
//  LSSafeProtector
// https://github.com/lsmakethebest/LSSafeProtector
//
//  Created by liusong on 2018/9/13.
//

#import <Foundation/Foundation.h>

/*
 可避免以下crash
 setObject:forKey:
 setObject:forKey:cost:
 
 */

@interface NSCache (Safe)

@end

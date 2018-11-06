//
//  NSOrderedSet+Safe.h
//  LSSafeProtector
// https://github.com/lsmakethebest/LSSafeProtector
//
//  Created by liusong on 2018/9/13.
//

#import <Foundation/Foundation.h>


/*
 可避免以下crash
 
 1.orderedSetWithSet
 2.initWithObjects:count:
 3.objectAtIndex:
 
 */
@interface NSOrderedSet (Safe)


@end

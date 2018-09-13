//
//  NSMutableOrderedSet+Safe.h
//  LSSafeProtector
// https://github.com/lsmakethebest/LSSafeProtector
//
//  Created by liusong on 2018/9/13.
//

#import <Foundation/Foundation.h>


/**
 可避免以下crash
 
 1. - (void)addObject:(ObjectType)anObject
 2. - (void)insertObject:(ObjectType)anObject atIndex:(NSUInteger)index;
 3. - (id)objectAtIndex:(NSUInteger)index( 包含   array[index]  形式  )
 4. - (void)removeObjectAtIndex:(NSUInteger)index
 5. - (void)replaceObjectAtIndex:(NSUInteger)index
 
 */

@interface NSMutableOrderedSet (Safe)

@end

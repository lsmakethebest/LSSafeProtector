//
//  NSArray+Safe.h
// https://github.com/lsmakethebest/LSSafeProtector
//
//  Created by liusong on 2018/4/20.
//  Copyright © 2018年 liusong. All rights reserved.

#import <Foundation/Foundation.h>

@interface NSArray (Safe)
@end

// < = iOS 8:下都是__NSArrayI 如果是通过json转成的id 为__NSCFArray
//iOS9 @[] 是__NSArray0  @[@"fd"]是__NSArrayI
//iOS10以后(含10): 分 __NSArrayI、  __NSArray0、__NSSingleObjectArrayI


//__NSArrayM   NSMutableArray创建的都为__NSArrayM
//__NSArray0   除__NSArrayM 0个元素都为__NSArray0
// __NSSingleObjectArrayI @[@"fds"]只有此形式创建而且仅一个元素为__NSSingleObjectArrayI
//__NSArrayI   @[@"fds",@"fsd"]方式创建多于1个元素 或者 arrayWith创建都是__NSArrayI

//__NSCFArray
//arr@[11] 调用的是  [__NSCFArray objectAtIndex:]


//__NSArray0
//arr@[11]   调用的是  [__NSArray0 objectAtIndex:]

//__NSSingleObjectArrayI
//arr@[11] 调用的是  [__NSSingleObjectArrayI objectAtIndex:]

//不可变数组
// <  iOS11： arr@[11]  调用的是[__NSArrayI objectAtIndex:]
// >= iOS11： arr@[11]  调用的是[__NSArrayI objectAtIndexedSubscript]
//  任意系统   [arr objectAtIndex:111]  调用的都是[__NSArrayM objectAtIndex:]

//可变数组
// <  iOS11： arr@[11]  调用的是[__NSArrayM objectAtIndex:]
// >= iOS11： arr@[11]  调用的是[__NSArrayM objectAtIndexedSubscript]
//  任意系统   [arr objectAtIndex:111]  调用的都是[__NSArrayI objectAtIndex:]



/*
   目前能避免以下crash
 
   1. NSArray的快速创建方式 NSArray *array = @[@"chenfanfang", @"AvoidCrash"];//其实调用的是3中的方法
   2. + (instancetype)arrayWithObjects:(const ObjectType _Nonnull [_Nonnull])objects count:(NSUInteger)cnt;调用的也是3中的方法
   3. - (instancetype)initWithObjects:(const ObjectType _Nonnull [_Nullable])objects count
   4. - (id)objectAtIndex:(NSUInteger)index
 
 */







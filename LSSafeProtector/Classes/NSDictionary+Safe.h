//
//  NSDictionary+Safe.h
//  test
//
//  Created by liusong on 2018/6/27.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (Safe)
@end

/*
 大概和NSArray类似  也是iOS8之前都是__NSDictionaryI，其他的参考NSArray
 
 __NSSingleEntryDictionaryI
 @{@"key":@"value"} 此种形式创建而且仅一个可以为__NSSingleEntryDictionaryI
 __NSDictionaryM
 NSMutableDictionary创建都为__NSDictionaryM
 __NSDictionary0
 除__NSDictionaryM外 不管什么方式创建0个key都为__NSDictionary0
 __NSDictionaryI
 @{@"key":@"value",@"key2",@"value2"}此种方式创建多于1个key，或者initWith创建都是__NSDictionaryI
 */


/*
    目前可避免以下crash  NSDictionary和NSMutableDictionary 调用 objectForKey： key为nil不会崩溃
 
 1.+ (instancetype)dictionaryWithObjects:(const ObjectType _Nonnull [_Nullable])objects forKeys:(const KeyType <NSCopying> _Nonnull [_Nullable])keys count:(NSUInteger)cnt会调用2中的方法
 2.- (instancetype)initWithObjects:(const ObjectType _Nonnull [_Nullable])objects forKeys:(const KeyType _Nonnull [_Nullable])keys count:(NSUInteger)cnt;
 3. @{@"key1":@"value1",@"key2":@"value2"}也会调用2中的方法
 4. - (instancetype)initWithObjects:(NSArray<ObjectType> *)objects forKeys:(NSArray<KeyType <NSCopying>> *)keys;
 */




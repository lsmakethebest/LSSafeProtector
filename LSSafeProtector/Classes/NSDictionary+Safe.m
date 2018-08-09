

//
//  NSDictionary+Safe.m
//
//  Created by liusong on 2018/4/20.
//

#import "NSDictionary+Safe.h"
#import "NSObject+Safe.h"




@implementation NSDictionary (Safe)

+(void)openSafeProtector
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        [self safe_exchangeInstanceMethod:NSClassFromString(@"__NSPlaceholderDictionary") originalSel:@selector(initWithObjects:forKeys:count:) newSel:@selector(safe_initWithObjects:forKeys:count:)];
        [self safe_exchangeInstanceMethod:NSClassFromString(@"__NSPlaceholderDictionary") originalSel:@selector(initWithObjects:forKeys:) newSel:@selector(safe_initWithObjects:forKeys:)];        
    });
}

-(instancetype)safe_initWithObjects:(NSArray *)objects forKeys:(NSArray<id<NSCopying>> *)keys
{
    id instance = nil;
    @try {
        instance = [self safe_initWithObjects:objects forKeys:keys];
    }
    @catch (NSException *exception) {
        
        LSSafeProtectionCrashLog(exception,LSSafeProtectorCrashTypeNSDictionary);
        
        //处理错误的数据，重新初始化一个字典
        NSUInteger count=MIN(objects.count, keys.count);
        NSMutableArray *newObjects=[NSMutableArray array];
        NSMutableArray *newKeys=[NSMutableArray array];
        for (int i = 0; i < count; i++) {
            if (objects[i] && keys[i]) {
                [newObjects addObject:objects[i]];
                [newKeys addObject:keys[i]];
            }
        }
        instance = [self safe_initWithObjects:newObjects forKeys:newKeys];
    }
    @finally {
        return instance;
    }
}
-(instancetype)safe_initWithObjects:(id  _Nonnull const [])objects forKeys:(id<NSCopying>  _Nonnull const [])keys count:(NSUInteger)cnt
{

    id instance = nil;
    @try {
        instance = [self safe_initWithObjects:objects forKeys:keys count:cnt];
    }
    @catch (NSException *exception) {

        LSSafeProtectionCrashLog(exception,LSSafeProtectorCrashTypeNSDictionary);

        //处理错误的数据，重新初始化一个字典
        NSUInteger index = 0;
        id   newObjects[cnt];
        id   newkeys[cnt];

        for (int i = 0; i < cnt; i++) {
            if (objects[i] && keys[i]) {
                newObjects[index] = objects[i];
                newkeys[index] = keys[i];
                index++;
            }
        }
        instance = [self safe_initWithObjects:newObjects forKeys:newkeys count:index];
    }
    @finally {
        return instance;
    }
}

@end


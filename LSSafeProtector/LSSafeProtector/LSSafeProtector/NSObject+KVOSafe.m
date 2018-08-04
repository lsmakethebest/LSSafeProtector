


//
//  NSObject+KVOSafe.m
//
//  Created by liusong on 2018/6/28.
//  Copyright © 2018年 liusong. All rights reserved.
//

#import "NSObject+KVOSafe.h"
#import "NSObject+Safe.h"
#import <objc/message.h>


#define LSKVOSafeLog(fmt, ...) NSLog(fmt,##__VA_ARGS__)

@implementation NSObject (KVOSafe)

static NSMutableSet *KVOSafeSwizzledClasses() {
    static dispatch_once_t onceToken;
    static NSMutableSet *swizzledClasses = nil;
    dispatch_once(&onceToken, ^{
        swizzledClasses = [[NSMutableSet alloc] init];
    });
    
    return swizzledClasses;
}

+ (void)openKVOSafeProtector
{
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        [self safe_exchangeInstanceMethod:[self class] originalSel:@selector(addObserver:forKeyPath:options:context:) newSel:@selector(safe_addObserver:forKeyPath:options:context:)];
        
        [self safe_exchangeClassMethod:[self class] originalSel:@selector(observeValueForKeyPath:ofObject:change:context:) newSel:@selector(safe_observeValueForKeyPath:ofObject:change:context:)];
        
        [self safe_exchangeInstanceMethod:[self class] originalSel:@selector(removeObserver:forKeyPath:) newSel:@selector(safe_removeObserver:forKeyPath:)];
        
        [self safe_exchangeInstanceMethod:[self class] originalSel:@selector(removeObserver:forKeyPath:context:) newSel:@selector(safe_removeObserver:forKeyPath:context:)];
    });
}
//最后添替换的dealloc 会最先调用倒序
-(void)safe_KVOChangeDidDeallocSignal
{
    //此处交换dealloc方法是借鉴RAC源码
    Class classToSwizzle=[self class];
    @synchronized (KVOSafeSwizzledClasses()) {
        NSString *className = NSStringFromClass(classToSwizzle);
        if ([KVOSafeSwizzledClasses() containsObject:className]) return;
        
        SEL deallocSelector = sel_registerName("dealloc");
        
        __block void (*originalDealloc)(__unsafe_unretained id, SEL) = NULL;
        
        id newDealloc = ^(__unsafe_unretained id self) {
            [self safe_KVODealloc];
            if (originalDealloc == NULL) {
                struct objc_super superInfo = {
                    .receiver = self,
                    .super_class = class_getSuperclass(classToSwizzle)
                };
                
                void (*msgSend)(struct objc_super *, SEL) = (__typeof__(msgSend))objc_msgSendSuper;
                msgSend(&superInfo, deallocSelector);
            } else {
                originalDealloc(self, deallocSelector);
            }
        };
        
        IMP newDeallocIMP = imp_implementationWithBlock(newDealloc);
        
        if (!class_addMethod(classToSwizzle, deallocSelector, newDeallocIMP, "v@:")) {
            // The class already contains a method implementation.
            Method deallocMethod = class_getInstanceMethod(classToSwizzle, deallocSelector);
            
            // We need to store original implementation before setting new implementation
            // in case method is called at the time of setting.
            originalDealloc = (__typeof__(originalDealloc))method_getImplementation(deallocMethod);
            
            // We need to store original implementation again, in case it just changed.
            originalDealloc = (__typeof__(originalDealloc))method_setImplementation(deallocMethod, newDeallocIMP);
        }
        
        [KVOSafeSwizzledClasses() addObject:className];
    }
}
#pragma mark - 被监听的所有keypath 字典
- (NSMutableDictionary *)safe_downObservedKeyPathDictionary
{
    NSMutableDictionary *dict = objc_getAssociatedObject(self, _cmd);
    if (!dict) {
        dict = [NSMutableDictionary new];
        objc_setAssociatedObject(self, _cmd, dict, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return dict;
}

- (void)setSafe_downObservedKeyPathDictionary:(NSMutableDictionary *)safe_beObservedKeyPathDictionary
{
    objc_setAssociatedObject(self, @selector(safe_downObservedKeyPathDictionary), safe_beObservedKeyPathDictionary, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}



#pragma mark - 监听了哪些对象数组
- (NSMutableDictionary *)safe_upObservedDictionary{
    NSMutableDictionary *dict = objc_getAssociatedObject(self, _cmd);
    if (!dict) {
        dict = [NSMutableDictionary new];
        [self setSafe_upObservedDictionary:dict];
    }
    return dict;
}

- (void)setSafe_upObservedDictionary:(NSMutableDictionary *)safe_upObservedDictionary{
    objc_setAssociatedObject(self, @selector(safe_upObservedDictionary), safe_upObservedDictionary, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

//存放dealloc之前还没有remove的keypaths
-(NSMutableDictionary *)safe_cacheKVODeallocDictionary{
    return  objc_getAssociatedObject(self, _cmd);
}
-(void)setSafe_cacheKVODeallocDictionary:(NSMutableDictionary *)safe_cacheKVODeallocDictionary{
    objc_setAssociatedObject(self, @selector(safe_cacheKVODeallocDictionary), safe_cacheKVODeallocDictionary, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
-(void)safe_observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    @try{
        [self safe_observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }@catch (NSException *exception){
        LSSafeProtectionCrashLog(exception,LSSafeProtectorCrashTypeKVO);
    }@finally{
        
    }
}

// keyPath为对象的属性，通过keyPath作为Key创建对应对应的一条观察者关键路径：keyPath --> observers-self
- (void)safe_addObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(void *)context
{
    if(!observer||!keyPath||([keyPath isKindOfClass:[NSString class]]&&keyPath.length<=0)){
        return;
    }
    @try {
        [self safe_addObserver:observer forKeyPath:keyPath options:options context:context];
    }
    @catch (NSException *exception) {
        LSSafeProtectionCrashLog(exception,LSSafeProtectorCrashTypeKVO);
    }
    @finally {
        
        //存放每个keyPath的所有监听者
        //已经添加过对应keypath的观察者
        NSHashTable *observers = self.safe_downObservedKeyPathDictionary[keyPath];
        if (observers && [observers containsObject:observer]) {
            return;
        }
        
        if (!observers) {
            //NSPointerFunctionsObjectPointerPersonality对于isEqual:和hash使用直接的指针比较
            observers = [[NSHashTable alloc] initWithOptions:NSPointerFunctionsWeakMemory|NSPointerFunctionsObjectPointerPersonality capacity:0];
        }
        @synchronized(observers){
            [observers addObject:observer];
            //每个keyPath的监听者数组存放在NSMutableDictionary中
            [self.safe_downObservedKeyPathDictionary setObject:observers forKey:keyPath];
        }
        
        
        //监听了哪些对象存储结构
        NSString *key =[NSString stringWithFormat:@"%p",self];
        NSMutableDictionary *listeningObjecteDic = observer.safe_upObservedDictionary[key];
        if (!listeningObjecteDic) {
            listeningObjecteDic = [NSMutableDictionary dictionary];
            NSMapTable *mapTable =[NSMapTable weakToWeakObjectsMapTable];
            [mapTable setObject:self forKey:@"observer"];
            listeningObjecteDic[@"observer"]=mapTable;
            listeningObjecteDic[@"keyPaths"]=[NSMutableArray array];
        }
        NSMutableArray *array=listeningObjecteDic[@"keyPaths"];
        @synchronized(array){
            [array addObject:keyPath];
        }
        [observer.safe_upObservedDictionary setObject:listeningObjecteDic forKey:key];
        [observer safe_KVOChangeDidDeallocSignal];
        [self safe_KVOChangeDidDeallocSignal];
        
    }
}

//移除时不但要把 有哪些对象监听了自己字典移除，还要把observer的监听了哪些人字典移除
- (void)safe_removeObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath
{
    if ([self safe_contaninObserverOrKeypathWithObserver:observer keyPath:keyPath]==NO) {
        // 重复删除观察者或不含有 或者keypath=nil  observer=nil
        return;
    }
    
    @try {
        LSKVOSafeLog(@"%@ safe_removeObserver %@  keyPath:%@",[self class],[observer class],keyPath);
        [self safe_removeObserver:observer forKeyPath:keyPath];
    }
    @catch (NSException *exception) {
        LSSafeProtectionCrashLog(exception,LSSafeProtectorCrashTypeKVO);
    }
    @finally {
        
        //监听了哪些对象存储结构 移除目标
        NSString *key =[NSString stringWithFormat:@"%p",self];
        NSMutableDictionary *listeningObjecteDic = observer.safe_upObservedDictionary[key];
        if(listeningObjecteDic==nil)return;//证明observer监听字典里已经没有了
        NSMutableArray *array=listeningObjecteDic[@"keyPaths"];
        if (array!=nil) {
            @synchronized(array){
                [array removeObject:keyPath];
            }
        }
        observer.safe_upObservedDictionary[key]=listeningObjecteDic;
        if (array.count<=0) {
            [observer.safe_upObservedDictionary removeObjectForKey:key];
        }
        
        
        //当先dealloc时 NSHashTable 里的元素也就为空了因为是weak指针销毁了 自动为nil
        NSHashTable *observers = self.safe_downObservedKeyPathDictionary[keyPath];
        @synchronized(observers){
            [observers removeObject:observer];
            [self.safe_downObservedKeyPathDictionary setObject:observers forKey:keyPath];
            
        }
    }
}

- (void)safe_removeObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath context:(void *)context
{
    if ([self safe_contaninObserverOrKeypathWithObserver:observer keyPath:keyPath]==NO) {
        // 重复删除观察者或不含有 或者keypath=nil  observer=nil
        return;
    }
    
    @try {
        LSKVOSafeLog(@"%@ safe_removeObserver %@  keyPath:%@",[self class],[observer class],keyPath);
        [self safe_removeObserver:observer forKeyPath:keyPath context:context];
    }
    @catch (NSException *exception) {
        LSSafeProtectionCrashLog(exception,LSSafeProtectorCrashTypeKVO);
    }
    @finally {
        
        //监听了哪些对象存储结构 移除目标
        NSString *key =[NSString stringWithFormat:@"%p",self];
        NSMutableDictionary *listeningObjecteDic = observer.safe_upObservedDictionary[key];
        if(listeningObjecteDic==nil)return;//证明observer监听字典里已经没有了
        NSMutableArray *array=listeningObjecteDic[@"keyPaths"];
        if (array!=nil) {
            @synchronized(array){
                [array removeObject:keyPath];
            }
        }
        observer.safe_upObservedDictionary[key]=listeningObjecteDic;
        if (array.count<=0) {
            [observer.safe_upObservedDictionary removeObjectForKey:key];
        }
        
        
        //当先dealloc时 NSHashTable 里的元素也就为空了因为是weak指针销毁了 自动为nil
        NSHashTable *observers = self.safe_downObservedKeyPathDictionary[keyPath];
        @synchronized(observers){
            [observers removeObject:observer];
            [self.safe_downObservedKeyPathDictionary setObject:observers forKey:keyPath];
            
        }
    }
}
//为什么判断能否移除 而不是直接remove try catch 捕获异常，因为有的类remove keypath两次，try直接就崩溃了
-(BOOL)safe_contaninObserverOrKeypathWithObserver:(id)observer keyPath:(NSString*)keyPath
{
    if(!observer||!keyPath||([keyPath isKindOfClass:[NSString class]]&&keyPath.length<=0)){
        return NO;
    }
    
    NSHashTable *observers = self.safe_downObservedKeyPathDictionary[keyPath];
    // keyPath集合为空证明没有正在监听的人
    if (!observers) {
        return NO;
    }
    
    NSString *objectKey=[NSString stringWithFormat:@"%p",self];
    NSMutableDictionary *uploadDic=[observer safe_upObservedDictionary][objectKey];
    NSMapTable *maptable=uploadDic[@"observer"];
    BOOL have = [uploadDic[@"keyPaths"] containsObject:keyPath];
    id uploadObserver = [maptable objectForKey:@"observer"];
    
    
    // A的down包含B   或者B的up包含A 都可以remove,解决了A和B谁先移除，导致的NSMapTable里的值自动变为nil的问题
    if ([observers containsObject:observer]||(uploadObserver!=nil&&have)) {
        return YES;
    }
    
    //自己监听自己情况
    if (self == observer && have) {
        return YES;
    }
    return NO;
}

/* 防止此种崩溃所以新创建个NSArray 和 NSMutableDictionary遍历
 Terminating app due to uncaught exception 'NSGenericException', reason: '*** Collection <__NSArrayM: 0x61800024f7b0> was mutated while being enumerated.'
 
 Terminating app due to uncaught exception 'NSGenericException', reason: '*** Collection <__NSDictionaryM: 0x170640de0> was mutated while being enumerated.'
 */
-(void)safe_KVODealloc
{
    LSKVOSafeLog(@"%@  safe_KVODealloc",[self class]);
    
    
    self.safe_cacheKVODeallocDictionary=[NSMutableDictionary dictionary];
    for (NSString *objectKey in self.safe_upObservedDictionary) {
        NSDictionary *dic=self.safe_upObservedDictionary[objectKey];
        NSMutableArray *keypathArray=[dic[@"keyPaths"] mutableCopy];
        self.safe_cacheKVODeallocDictionary[objectKey]=keypathArray;
    }
    

    
    //A->B A先销毁 B的safe_upObservedDictionary observer=nil  然后在B dealloc里在remove会导致移除不了，然后系统会报销毁时还持有某keypath的crash
    //A->B B先销毁 此时A remove 但事实上的A的safe_downObservedDictionary observer=nil  所以B remove里会判断observer是否有值，如果没值则不remove导致没有remove
    
    //监听了哪些人 让那些人移除自己
    NSMutableDictionary *newDic=[self.safe_upObservedDictionary mutableCopy];
    for (NSString *objectKey in newDic) {
        NSDictionary *dic=newDic[objectKey];
        NSMapTable *maptable=dic[@"observer"];
        id  observer=[maptable objectForKey:@"observer"];
        NSMutableArray *keypathArray=dic[@"keyPaths"];
        NSArray *newArray=[keypathArray mutableCopy];
        for (NSString *keypath in newArray) {
            if (observer) {
                LSKVOSafeLog(@"%@ dealloc的时候，仍然监听着 %@ 的keyPath of %@ ,框架自动remove",[self class],[observer class],keypath);
                [observer removeObserver:self forKeyPath:keypath ];
            }
            else{
                LSKVOSafeLog(@"%@ dealloc的时候，仍然监听着自己的keyPath of %@ ,框架自动remove",[self class],keypath);
                if ([objectKey isEqualToString:[NSString stringWithFormat:@"%p",self]]){
                    //自己监听自己 两个字典都有值 这快移除完，下个字典就没值了，所以不用再处理
                    [self removeObserver:self forKeyPath:keypath ];
                }
            }
        }
    }
    
    
    
    //谁监听了自己 移除他们
    NSMutableDictionary *downNewDic=[self.safe_downObservedKeyPathDictionary mutableCopy];
    [downNewDic enumerateKeysAndObjectsUsingBlock:^(NSString * keyPath, id  _Nonnull obj, BOOL * _Nonnull stop) {
        NSHashTable *table=downNewDic[keyPath];
        NSArray *array= [table.allObjects mutableCopy];
        for (id obj in array) {
            LSKVOSafeLog(@"%@ dealloc的时候，%@ 仍然监听着 %@ 的keyPath of %@ ,框架自动remove",[self class],[obj class],[self class],keyPath);
            [self removeObserver:obj forKeyPath:keyPath];
        }
    }];
}



@end

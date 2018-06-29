


//
//  NSObject+KVOSafe.m
//
//  Created by liusong on 2018/6/28.
//  Copyright © 2018年 liusong. All rights reserved.
//

#import "NSObject+KVOSafe.h"
#import "NSObject+Safe.h"
#import <objc/message.h>


@interface NSObject(KVOSafe)
@property (nonatomic,assign) BOOL safe_isKVOWillDealloc;
@property (nonatomic,strong) NSMutableDictionary *safe_cacheKVODeallocDictionary;
@end

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
            if([NSStringFromClass([self class]) hasPrefix:@"_"])return ;
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
-(void)safe_observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    @try{
        [self safe_observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }@catch (NSException *exception){
        LSSafeProtectionCrashLog(exception);
    }@finally{
        
    }
}

// keyPath为对象的属性，通过keyPath作为Key创建对应对应的一条观察者关键路径：keyPath --> observers-self
- (void)safe_addObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(void *)context {
    if( !keyPath||([keyPath isKindOfClass:[NSString class]]&&keyPath.length<=0)){
        return;
    }
    @try {
        [self safe_addObserver:observer forKeyPath:keyPath options:options context:context];
    }
    @catch (NSException *exception) {
        LSSafeProtectionCrashLog(exception);
        
    }
    @finally {
        //观察者为空 或者keypath为空
        if (!observer || !keyPath||([keyPath isKindOfClass:[NSString class]]&&keyPath.length<=0)) {
            return;
        }
        //存放每个keyPath的所有监听者
        //已经添加过对应keypath的观察者
        NSHashTable *observers = self.safe_beObservedKeyPathDictionary[keyPath];
        if (observers && [observers containsObject:observer]) {
            return;
        }
        
        if (!observers) {
            //          NSPointerFunctionsObjectPointerPersonality对于isEqual:和hash使用直接的指针比较
            observers = [[NSHashTable alloc] initWithOptions:NSPointerFunctionsWeakMemory|NSPointerFunctionsObjectPointerPersonality capacity:0];
        }
        
        [observers addObject:observer];
        //每个keyPath的监听者数组存放在NSMutableDictionary中
        [self.safe_beObservedKeyPathDictionary setObject:observers forKey:keyPath];
        
        
        //监听了哪些对象存储结构
        NSString *key =[NSString stringWithFormat:@"%@",self];
        NSMutableDictionary *listeningObjecteDic = observer.safe_observedDictionary[key];
        if (!listeningObjecteDic) {
            listeningObjecteDic = [NSMutableDictionary dictionary];
            NSMapTable *mapTable =[NSMapTable weakToWeakObjectsMapTable];
            [mapTable setObject:self forKey:@"observer"];
            listeningObjecteDic[@"observer"]=mapTable;
            listeningObjecteDic[@"keyPaths"]=[NSMutableArray array];
        }
        NSMutableArray *array=listeningObjecteDic[@"keyPaths"];
        [array addObject:keyPath];
        [observer.safe_observedDictionary setObject:listeningObjecteDic forKey:key];
        [observer safe_KVOChangeDidDeallocSignal];
        
    }
}

//移除时不但要把 有哪些对象监听了自己字典移除，还要把observer的监听了哪些人字典移除
- (void)safe_removeObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath
{
    @try {
        [self safe_removeObserver:observer forKeyPath:keyPath];
    }
    @catch (NSException *exception) {
        if (!observer.safe_isKVOWillDealloc) {
            // 打印crash信息
            LSSafeProtectionCrashLog(exception);
        }
    }
    @finally {
        
        if (!observer || !keyPath) {
            return;
        }
        
        //监听了哪些对象存储结构 移除目标
        NSString *key =[NSString stringWithFormat:@"%@",self];
        NSMutableDictionary *listeningObjecteDic = observer.safe_observedDictionary[key];
        if(listeningObjecteDic==nil)return;//证明observer监听字典里已经没有了
        //        if (!listeningObjecteDic) {
        //            listeningObjecteDic = [NSMutableDictionary dictionary];
        //            NSMapTable *mapTable =[NSMapTable weakToWeakObjectsMapTable];
        //            [mapTable setObject:self forKey:@"observer"];
        //            listeningObjecteDic[@"observer"]=mapTable;
        //            listeningObjecteDic[@"keyPaths"]=[NSMutableArray array];
        //        }
        NSMutableArray *array=listeningObjecteDic[@"keyPaths"];
        [array removeObject:keyPath];
        observer.safe_observedDictionary[key]=listeningObjecteDic;
        
        if (array.count<=0) {
            [observer.safe_observedDictionary removeObjectForKey:key];
        }
        
        
        //当先dealloc时 NSHashTableo 里的元素也就为空了因为是weak指针销毁了 自动为nil
        NSHashTable *observers = self.safe_beObservedKeyPathDictionary[keyPath];
        // keyPath集合中未包含这个观察者
        if (!observers) {
            return;
        }
        // 重复删除观察者
        if (![observers containsObject:observer]) {
            return;
        }
        [observers removeObject:observer];
        [self.safe_beObservedKeyPathDictionary setObject:observers forKey:keyPath];
          
    }
}

- (void)safe_removeObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath context:(void *)context
{
    @try {
        [self safe_removeObserver:observer forKeyPath:keyPath context:context];
    }
    @catch (NSException *exception) {
        // 打印crash信息
        LSSafeProtectionCrashLog(exception);
    }
    @finally {
        
        if (!observer || !keyPath) {
            return;
        }
        
        
        //监听了哪些人处理
        //监听了哪些对象存储结构 移除目标
        NSString *key =[NSString stringWithFormat:@"%@",self];
        NSMutableDictionary *listeningObjecteDic = observer.safe_observedDictionary[key];
        if(listeningObjecteDic==nil)return;
        //        if (!listeningObjecteDic) {
        //            listeningObjecteDic = [NSMutableDictionary dictionary];
        //            NSMapTable *mapTable =[NSMapTable weakToWeakObjectsMapTable];
        //            [mapTable setObject:self forKey:@"observer"];
        //            listeningObjecteDic[@"observer"]=mapTable;
        //            listeningObjecteDic[@"keyPaths"]=[NSMutableArray array];
        //        }
        NSMutableArray *array=listeningObjecteDic[@"keyPaths"];
        [array removeObject:keyPath];
        observer.safe_observedDictionary[key]=listeningObjecteDic;
        
        if (array.count<=0) {
            [observer.safe_observedDictionary removeObjectForKey:key];
        }
        
        
        
        //有哪些人监听自己处理
        NSHashTable *observers = self.safe_beObservedKeyPathDictionary[keyPath];
        // keyPath集合中未包含这个观察者
        if (!observers) {
            return;
        }
        // 重复删除观察者
        if (![observers containsObject:observer]) {
            return;
        }
        [observers removeObject:observer];
        [self.safe_beObservedKeyPathDictionary setObject:observers forKey:keyPath];
        
    }
}


#pragma mark - 被监听的所有keypath 字典
- (NSMutableDictionary *)safe_beObservedKeyPathDictionary
{
    NSMutableDictionary *dict = objc_getAssociatedObject(self, _cmd);
    if (!dict) {
        dict = [NSMutableDictionary new];
        objc_setAssociatedObject(self, _cmd, dict, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return dict;
}

- (void)setSafe_beObservedKeyPathDictionary:(NSMutableDictionary *)safe_beObservedKeyPathDictionary
{
    objc_setAssociatedObject(self, @selector(safe_beObservedKeyPathDictionary), safe_beObservedKeyPathDictionary, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}



#pragma mark - 监听了哪些对象数组
- (NSMutableDictionary *)safe_observedDictionary{
    NSMutableDictionary *dict = objc_getAssociatedObject(self, _cmd);
    if (!dict) {
        dict = [NSMutableDictionary new];
        [self setSafe_observedDictionary:dict];
    }
    return dict;
}

- (void)setSafe_observedDictionary:(NSMutableDictionary *)safe_observedDictionary{
    objc_setAssociatedObject(self, @selector(safe_observedDictionary), safe_observedDictionary, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


-(void)safe_KVODealloc
{
    NSLog(@"%@  safe_KVODealloc",[self class]);
    //    for (NSString *objectKey in self.safe_observedDictionary) {
    //         NSDictionary *dic=self.safe_observedDictionary[objectKey];
    //    }
    self.safe_isKVOWillDealloc=YES;
    for (NSString *objectKey in self.safe_observedDictionary) {
        NSDictionary *dic=self.safe_observedDictionary[objectKey];
        NSMapTable *maptable=dic[@"observer"];
        id  observer=[maptable objectForKey:@"observer"];
        NSMutableArray *keypathArray=dic[@"keyPaths"];
        for (NSString *keypath in keypathArray) {
            [observer removeObserver:self forKeyPath:keypath ];
            NSLog(@"11111111111  %@",keypath);
        }
    }
}
-
(NSMutableDictionary *)safe_cacheKVODeallocDictionary
{
    return  objc_getAssociatedObject(self, _cmd);
}
-(void)setSafe_cacheKVODeallocDictionary:(NSMutableDictionary *)safe_cacheKVODeallocDictionary
{
    objc_setAssociatedObject(self, @selector(safe_cacheKVODeallocDictionary), safe_cacheKVODeallocDictionary, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(BOOL)safe_isKVOWillDealloc
{
    return [objc_getAssociatedObject(self, _cmd)boolValue];
}
-(void)setSafe_isKVOWillDealloc:(BOOL)safe_isKVOWillDealloc
{
    return objc_setAssociatedObject(self, @selector(safe_isKVOWillDealloc), @(safe_isKVOWillDealloc), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}



@end

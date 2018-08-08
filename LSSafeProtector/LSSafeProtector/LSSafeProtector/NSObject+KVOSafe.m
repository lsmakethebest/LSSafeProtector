


//
//  NSObject+KVOSafe.m
//
//  Created by liusong on 2018/6/28.
//  Copyright © 2018年 liusong. All rights reserved.
//

#import "NSObject+KVOSafe.h"
#import "NSObject+Safe.h"
#import <objc/message.h>


//#define LSKVOSafeLog(fmt, ...) NSLog(fmt,##__VA_ARGS__)
#define LSKVOSafeLog(fmt, ...)

@implementation NSObject (KVOSafe)

static NSMutableSet *KVOSafeSwizzledClasses() {
    static dispatch_once_t onceToken;
    static NSMutableSet *swizzledClasses = nil;
    dispatch_once(&onceToken, ^{
        swizzledClasses = [[NSMutableSet alloc] init];
    });    
    return swizzledClasses;
}

static NSMutableDictionary *KVOSafeDeallocCrashes() {
    static dispatch_once_t onceToken;
    static NSMutableDictionary *KVOSafeDeallocCrashes = nil;
    dispatch_once(&onceToken, ^{
        KVOSafeDeallocCrashes = [[NSMutableDictionary alloc] init];
    });
    return KVOSafeDeallocCrashes;
}

+ (void)openKVOSafeProtector{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        [self safe_exchangeInstanceMethod:[self class] originalSel:@selector(addObserver:forKeyPath:options:context:) newSel:@selector(safe_addObserver:forKeyPath:options:context:)];
        
        [self safe_exchangeClassMethod:[self class] originalSel:@selector(observeValueForKeyPath:ofObject:change:context:) newSel:@selector(safe_observeValueForKeyPath:ofObject:change:context:)];
        
        [self safe_exchangeInstanceMethod:[self class] originalSel:@selector(removeObserver:forKeyPath:) newSel:@selector(safe_removeObserver:forKeyPath:)];
        
        [self safe_exchangeInstanceMethod:[self class] originalSel:@selector(removeObserver:forKeyPath:context:) newSel:@selector(safe_removeObserver:forKeyPath:context:)];
    });
}
//最后添替换的dealloc 会最先调用倒序
-(void)safe_KVOChangeDidDeallocSignal{
    //此处交换dealloc方法是借鉴RAC源码
    Class classToSwizzle=[self class];
    @synchronized (KVOSafeSwizzledClasses()) {
        NSString *className = NSStringFromClass(classToSwizzle);
        if ([KVOSafeSwizzledClasses() containsObject:className]) return;
        
        SEL deallocSelector = sel_registerName("dealloc");
        
        __block void (*originalDealloc)(__unsafe_unretained id, SEL) = NULL;
        
        id newDealloc = ^(__unsafe_unretained id self) {
            [self safe_KVODealloc];
            NSString *classAddress=[NSString stringWithFormat:@"%p",self];
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
            [NSClassFromString(className) safe_dealloc_crash:classAddress];
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
- (NSMutableDictionary *)safe_downObservedKeyPathDictionary{
    NSMutableDictionary *dict = objc_getAssociatedObject(self, _cmd);
    if (!dict) {
        dict = [NSMutableDictionary new];
        objc_setAssociatedObject(self, _cmd, dict, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return dict;
}

- (void)setSafe_downObservedKeyPathDictionary:(NSMutableDictionary *)safe_beObservedKeyPathDictionary{
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
    if([self safe_contaninObserverOrKeypathWithObserver:observer keyPath:keyPath isUser:NO]){
        //如果添加过了直接return
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
            listeningObjecteDic[@"className"]=[NSString stringWithFormat:@"%@",[self class]];
            listeningObjecteDic[@"keyPaths"]=[NSMutableArray array];
        }
        NSMutableArray *keyPathsArray=listeningObjecteDic[@"keyPaths"];
        @synchronized(keyPathsArray){
            [keyPathsArray addObject:keyPath];
        }
        [observer.safe_upObservedDictionary setObject:listeningObjecteDic forKey:key];
        
        //交换dealloc方法
        [observer safe_KVOChangeDidDeallocSignal];
        [self safe_KVOChangeDidDeallocSignal];
        
    }
}

//移除时不但要把 有哪些对象监听了自己字典移除，还要把observer的监听了哪些人字典移除
- (void)safe_removeObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath{
   [self safe_allRemoveObserver:observer forKeyPath:keyPath context:nil isContext:NO isUser:YES];
}
- (void)safe_removeObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath context:(void *)context{
    [self safe_allRemoveObserver:observer forKeyPath:keyPath context:context isContext:YES isUser:YES];
}


/**
 @param isContext 是否有context
 @param isUser 是否是用户移除的，而不是框架替用户移除的
 */
- (void)safe_allRemoveObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath context:(void *)context isContext:(BOOL)isContext isUser:(BOOL)isUser{
    if ([self safe_contaninObserverOrKeypathWithObserver:observer keyPath:keyPath isUser:isUser]==NO) {
        // 重复删除观察者或不含有 或者keypath=nil  observer=nil
        return;
    }
    
    @try {
        LSKVOSafeLog(@"%@ safe_removeObserver %@  keyPath:%@",[self class],[observer class],keyPath);
        if (isContext) {
            [self safe_removeObserver:observer forKeyPath:keyPath context:context];
        }else{
            [self safe_removeObserver:observer forKeyPath:keyPath];
        }
    }
    @catch (NSException *exception) {
        LSSafeProtectionCrashLog(exception,LSSafeProtectorCrashTypeKVO);
    }
    @finally {
        
        //监听了哪些对象存储结构 移除目标
        NSString *key =[NSString stringWithFormat:@"%p",self];
        NSMutableDictionary *listeningObjecteDic = observer.safe_upObservedDictionary[key];
        if(listeningObjecteDic==nil)return;//证明observer监听字典里已经没有了
        NSMutableArray *keyPathArray=listeningObjecteDic[@"keyPaths"];
        if (keyPathArray!=nil) {
            @synchronized(keyPathArray){
                [keyPathArray removeObject:keyPath];
            }
        }
        observer.safe_upObservedDictionary[key]=listeningObjecteDic;
        if (keyPathArray.count<=0) {
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
-(BOOL)safe_contaninObserverOrKeypathWithObserver:(id)observer keyPath:(NSString*)keyPath isUser:(BOOL)isUser
{
    if(!observer||!keyPath||([keyPath isKindOfClass:[NSString class]]&&keyPath.length<=0)){
        return NO;
    }
    
    NSString *objectKey=[NSString stringWithFormat:@"%p",self];
    if (isUser) {
        [KVOSafeDeallocCrashes()[[NSString stringWithFormat:@"%p",observer]][objectKey][@"keyPaths"] removeObject:keyPath];
    }
    
    NSHashTable *observers = self.safe_downObservedKeyPathDictionary[keyPath];
    // keyPath集合为空证明没有正在监听的人
    if (!observers) {
        return NO;
    }
    
    
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
    NSString *currentKey=[NSString stringWithFormat:@"%p",self];
    KVOSafeDeallocCrashes()[currentKey]=[NSMutableDictionary dictionary];
    for (NSString *objectKey in self.safe_upObservedDictionary) {
        NSDictionary *dic=self.safe_upObservedDictionary[objectKey];
        NSMutableArray *keypathArray=[dic[@"keyPaths"] mutableCopy];
//        self.safe_cacheKVODeallocDictionary[objectKey]=keypathArray;
        NSMutableDictionary *newDic=[NSMutableDictionary dictionary];
        newDic[@"className"]=dic[@"className"];
        newDic[@"keyPaths"]=keypathArray;
        KVOSafeDeallocCrashes()[currentKey][objectKey]=newDic;
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
        NSArray *newKeypathArray=[keypathArray mutableCopy];
        for (NSString *keypath in newKeypathArray) {
            if (observer) {
                LSKVOSafeLog(@"%@ dealloc的时候，仍然监听着 %@ 的 keyPath of %@ ,框架自动remove",[self class],[observer class],keypath);
                [observer safe_allRemoveObserver:self forKeyPath:keypath context:nil isContext:NO isUser:NO];
            }
            else{
                if ([objectKey isEqualToString:[NSString stringWithFormat:@"%p",self]]){
                    //自己监听自己 NSHashTable和NSMapTable里的值都没了，所以需要单独判断，这快移除完，下个字典就没值了，所以不用再处理
                    LSKVOSafeLog(@"%@ dealloc的时候，仍然监听着自己的 keyPath of %@ ,框架自动remove",[self class],keypath);
                    [self safe_allRemoveObserver:self forKeyPath:keypath context:nil isContext:NO isUser:NO];
                }
            }
        }
    }
    
    
    
    //谁监听了自己 移除他们 这块必须处理  不然 A->B   A先销毁了 在B里面调用A remove就无效了，因为A=nil
    NSMutableDictionary *downNewDic=[self.safe_downObservedKeyPathDictionary mutableCopy];
    [downNewDic enumerateKeysAndObjectsUsingBlock:^(NSString * keyPath, id  _Nonnull obj, BOOL * _Nonnull stop) {
        NSHashTable *table=downNewDic[keyPath];
        NSArray *array= [table.allObjects mutableCopy];
        for (id obj in array) {
            LSKVOSafeLog(@"%@ dealloc的时候，%@ 仍然监听着 %@ 的 keyPath of %@ ,框架自动remove",[self class],[obj class],[self class],keyPath);
            [self safe_allRemoveObserver:obj forKeyPath:keyPath context:nil isContext:NO isUser:NO];
        }
    }];
}
+(void)safe_dealloc_crash:(NSString*)classAddress
{
    NSDictionary *dic = KVOSafeDeallocCrashes()[classAddress];
    for (NSString *key in dic) {
        NSArray *array = dic[key][@"keyPaths"];
        if (array.count>0) {
            for (NSString *keyPath in array) {
                NSString *reason=[NSString stringWithFormat:@"%@（%@） dealloc时仍然监听着 %@ 的 keyPath of %@",[self class],classAddress,dic[key][@"className"],keyPath];
            NSException *exception=[NSException exceptionWithName:@"KVO crash" reason:reason userInfo:nil]; LSSafeProtectionCrashLog(exception,LSSafeProtectorCrashTypeKVO);
            }
        }
    }
    [KVOSafeDeallocCrashes() removeObjectForKey:classAddress];
}


@end

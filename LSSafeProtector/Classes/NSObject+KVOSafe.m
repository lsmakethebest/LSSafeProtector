//
//  NSObject+KVOSafe.m
// https://github.com/lsmakethebest/LSSafeProtector
//
//  Created by liusong on 2018/4/20.
//  Copyright © 2018年 liusong. All rights reserved.

#import "NSObject+KVOSafe.h"
#import "NSObject+Safe.h"
#import <objc/message.h>


/*
 内部存储结构
 down(NSMutableDictionary）-> keypath1->NSMapTable->id
 keypath2->NSMapTable->id
 keypath3->NSMapTable->id
 
 监听对象的地址
 up(Dictionary)->0x03739239->Dictionary->observer-NSMapTable->observer-id
 ->className->NSString
 ->keyPaths(Array)->keyPath1
 ->keyPath2
 */
#define LSKVOSafeLog(fmt, ...) NSLog(fmt,##__VA_ARGS__)

//#define LSKVOSafeLog(fmt, ...)




@interface LSKVOObserverInfo()

@property (nonatomic,weak) id target;
@property (nonatomic,weak) id observer;
@property (nonatomic,copy)NSString *targetAddress;
@property (nonatomic,copy)NSString *observerAddress;
@property (nonatomic,copy)NSString *keyPath;
@property (nonatomic,assign) void * context;

@end

@implementation LSKVOObserverInfo
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
- (NSMutableArray *)safe_downObservedKeyPathArray{
    NSMutableArray *array = objc_getAssociatedObject(self, _cmd);
    if (!array) {
        array = [NSMutableArray new];
        objc_setAssociatedObject(self, _cmd, array, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return array;
}

- (void)setSafe_downObservedKeyPathArray:(NSMutableArray *)safe_downObservedKeyPathArray{
    objc_setAssociatedObject(self, @selector(safe_downObservedKeyPathArray), safe_downObservedKeyPathArray, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark - 监听了哪些对象数组
- (NSMutableArray *)safe_upObservedArray{
    NSMutableArray *array = objc_getAssociatedObject(self, _cmd);
    if (!array) {
        array = [NSMutableArray array];
        [self setSafe_upObservedArray:array];
    }
    return array;
}

- (void)setSafe_upObservedArray:(NSMutableArray *)safe_upObservedArray{
    objc_setAssociatedObject(self, @selector(safe_upObservedArray), safe_upObservedArray, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
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
    if([self safe_canAddOrRemoveObserverWithKeypathWithObserver:observer keyPath:keyPath context:context isUser:NO isAdd:YES]==NO){
        //如果添加过了直接return
        LSKVOSafeLog(@"添加失败%@:%p safe_addObserver %@:%p  keyPath:%@",[self class],self,[observer class],observer,keyPath);
        return;
    }
    @try {
        LSKVOSafeLog(@"添加成功%@:%p safe_addObserver %@:%p  keyPath:%@",[self class],self,[observer class],observer,keyPath);
        
        NSString *targetAddress=[NSString stringWithFormat:@"%p",self];
        NSString *observerAddress=[NSString stringWithFormat:@"%p",observer];
        LSKVOObserverInfo *downInfo=[LSKVOObserverInfo new];
        downInfo.target=self;
        downInfo.observer=observer;
        downInfo.keyPath=keyPath;
        downInfo.context=context;
        downInfo.targetAddress=targetAddress;
        downInfo.observerAddress=observerAddress;
        [self.safe_downObservedKeyPathArray addObject:downInfo];
        
        LSKVOObserverInfo *upInfo=[LSKVOObserverInfo new];
        upInfo.target=self;
        upInfo.observer=observer;
        upInfo.keyPath=keyPath;
        upInfo.context=context;
        upInfo.targetAddress=targetAddress;
        upInfo.observerAddress=observerAddress;
        [observer.safe_upObservedArray addObject:upInfo];
        
        [self safe_addObserver:observer forKeyPath:keyPath options:options context:context];
        
        //交换dealloc方法
        [observer safe_KVOChangeDidDeallocSignal];
        [self safe_KVOChangeDidDeallocSignal];
    }
    @catch (NSException *exception) {
        LSSafeProtectionCrashLog(exception,LSSafeProtectorCrashTypeKVO);
    }
    @finally {
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
    if ([self safe_canAddOrRemoveObserverWithKeypathWithObserver:observer keyPath:keyPath context:context isUser:isUser isAdd:NO]==NO) {
        // 重复删除观察者或不含有 或者keypath=nil  observer=nil
        LSKVOSafeLog(@"移除失败%@:%p safe_removeObserver %@:%p  keyPath:%@",[self class],self,[observer class],observer,keyPath);
        return;
    }
    
    @try {
        LSKVOSafeLog(@"移除成功%@:%p safe_removeObserver %@:%p  keyPath:%@",[self class],self,[observer class],observer,keyPath);
        if (isContext) {
            [self safe_removeSuccessObserver:observer forKeyPath:keyPath context:context];
            [self safe_removeObserver:observer forKeyPath:keyPath context:context];
        }else{
            [self safe_removeSuccessObserver:observer forKeyPath:keyPath context:context];
            [self safe_removeObserver:observer forKeyPath:keyPath];
        }
    }
    @catch (NSException *exception) {
        LSSafeProtectionCrashLog(exception,LSSafeProtectorCrashTypeKVO);
    }
    @finally {
    }
}

-(void)safe_removeSuccessObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath context:(void*)context
{
    //    NSString *key =[NSString stringWithFormat:@"%p",self];
    
    //哪些对象监听了自己
    NSMutableArray *downArray = self.safe_downObservedKeyPathArray;
    __block LSKVOObserverInfo *downInfo;
    [downArray enumerateObjectsUsingBlock:^(LSKVOObserverInfo *  obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.targetAddress isEqualToString: [NSString stringWithFormat:@"%p",self]]&&[obj.observerAddress isEqualToString:[NSString stringWithFormat:@"%p",observer]]&&[obj.keyPath isEqualToString:keyPath]&&obj.context==context) {
            downInfo=obj;
            *stop=YES;
        }
    }];
    if (downInfo) {
        [downArray removeObject:downInfo];
    }
    
    
    //observer监听了哪些对象
    NSMutableArray *upArray = observer.safe_upObservedArray;
    __block LSKVOObserverInfo *upInfo;
    [upArray enumerateObjectsUsingBlock:^(LSKVOObserverInfo *  obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.targetAddress isEqualToString: [NSString stringWithFormat:@"%p",self]]&&[obj.observerAddress isEqualToString:[NSString stringWithFormat:@"%p",observer]]&&[obj.keyPath isEqualToString:keyPath]&&obj.context==context) {
            upInfo=obj;
            *stop=YES;
        }
    }];
    if (upInfo) {
        [upArray removeObject:upInfo];
    }
}

//为什么判断能否移除 而不是直接remove try catch 捕获异常，因为有的类remove keypath两次，try直接就崩溃了
-(BOOL)safe_canAddOrRemoveObserverWithKeypathWithObserver:(NSObject *)observer keyPath:(NSString*)keyPath context:(void*)context isUser:(BOOL)isUser isAdd:(BOOL)isAdd
{
    if(!observer||!keyPath||([keyPath isKindOfClass:[NSString class]]&&keyPath.length<=0)){
        return NO;
    }
    
    
    //    NSString *objectKey=[NSString stringWithFormat:@"%p",self];
    //    if (isUser) {
    //        [KVOSafeDeallocCrashes()[[NSString stringWithFormat:@"%p",observer]][objectKey][@"keyPaths"] removeObject:keyPath];
    //    }
    
    
    __block BOOL have=NO;
    //哪些对象监听了自己
    NSMutableArray *downArray = self.safe_downObservedKeyPathArray;
    [downArray enumerateObjectsUsingBlock:^(LSKVOObserverInfo *  obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.observer==observer&&[obj.keyPath isEqualToString:keyPath]&&obj.context==context) {
            have=YES;
            *stop=YES;
        }
    }];
    
    if (have) {
        if (isAdd) {
            return NO;
        }
        return YES;
    }
    //observer监听了哪些对象
    NSMutableArray *upArray = observer.safe_upObservedArray;
    [upArray enumerateObjectsUsingBlock:^(LSKVOObserverInfo *  obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.target==self&&[obj.keyPath isEqualToString:keyPath]&&obj.context==context) {
            have=YES;
            *stop=YES;
        }
    }];
    
    if (have) {
        if (isAdd) {
            return NO;
        }
        return YES;
    }
    
    //自己监听自己情况
    if (self == observer) {
        [upArray enumerateObjectsUsingBlock:^(LSKVOObserverInfo *  obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj.targetAddress isEqualToString:obj.observerAddress]&&[obj.keyPath isEqualToString:keyPath]&&obj.context==context) {
                have=YES;
                *stop=YES;
            }
        }];
    }
    if (isAdd) {
        return !have;
    }
    return have;
    
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
    //    for (LSKVOObserverInfo *info in self.safe_upObservedArray) {
    //            NSDictionary *dic=self.safe_upObservedDictionary[objectKey];
    //            NSMutableArray *keypathArray=[dic[@"keyPaths"] mutableCopy];
    //            NSMutableDictionary *newDic=[NSMutableDictionary dictionary];
    //            newDic[@"className"]=dic[@"className"];
    //            newDic[@"keyPaths"]=keypathArray;
    //            KVOSafeDeallocCrashes()[currentKey][objectKey]=newDic;
    //    }
    
    
    //A->B A先销毁 B的safe_upObservedDictionary observer=nil  然后在B dealloc里在remove会导致移除不了，然后系统会报销毁时还持有某keypath的crash
    //A->B B先销毁 此时A remove 但事实上的A的safe_downObservedDictionary observer=nil  所以B remove里会判断observer是否有值，如果没值则不remove导致没有remove
    
    //监听了哪些人 让那些人移除自己
    NSMutableArray *newUpArray=[self.safe_upObservedArray mutableCopy];
    for (LSKVOObserverInfo *upInfo in newUpArray) {
        id target=upInfo.target;
        if (target) {
            [target safe_allRemoveObserver:self forKeyPath:upInfo.keyPath context:upInfo.context isContext:NO isUser:NO];
        }else if ([upInfo.targetAddress isEqualToString:[NSString stringWithFormat:@"%p",self]]){
            [self safe_allRemoveObserver:self forKeyPath:upInfo.keyPath context:upInfo.context isContext:NO isUser:NO];
        }
    }
    
    
    
    //谁监听了自己 移除他们 这块必须处理  不然 A->B   A先销毁了 在B里面调用A remove就无效了，因为A=nil
    NSMutableArray *downNewArray=[self.safe_downObservedKeyPathArray mutableCopy];
    for (LSKVOObserverInfo *downInfo in downNewArray) {
            [self safe_allRemoveObserver:downInfo.observer forKeyPath:downInfo.keyPath context:downInfo.context isContext:NO isUser:NO];
    }
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

//
//  NSObject+KVOSafe.m
// https://github.com/lsmakethebest/LSSafeProtector
//
//  Created by liusong on 2018/4/20.
//  Copyright © 2018年 liusong. All rights reserved.

#import "NSObject+KVOSafe.h"
#import "NSObject+SafeCore.h"
#import <objc/message.h>

//#define LSKVOSafeLog(fmt, ...) NSLog(fmt,##__VA_ARGS__)
#define LSKVOSafeLog(fmt, ...)


@interface LSKVOObserverInfo()

@property (nonatomic,weak) id target;
@property (nonatomic,copy)NSString *targetAddress;
@property (nonatomic,copy)NSString *targetClassName;

@property (nonatomic,weak) id observer;
@property (nonatomic,copy)NSString *observerAddress;
@property (nonatomic,copy)NSString *observerClassName;

@property (nonatomic,copy)NSString *keyPath;
@property (nonatomic,assign) void * context;


@end
@implementation LSKVOObserverInfo
@end

@interface LSRecursiveLock : NSRecursiveLock
@end
@implementation LSRecursiveLock
-(void)dealloc
{
    LSKVOSafeLog(@"LSRecursiveLock  ---- dealloc -------  %@",self);
}

@end

@interface NSObject()
@property (nonatomic,weak) LSKVOObserverInfo *safe_willRemoveObserverInfo;
//dealloc时标记有多少没移除，然后手动替他移除，比如有7个 我都替他移除掉，数量还是7，然后用户手动移除时，数量会减少，然后计算最终剩多少就是用户没有移除的，提示用户有没移除的KVO  默认为YES dealloc时改为NO
@property (nonatomic,assign) BOOL safe_notNeedRemoveKeypathFromCrashArray;
@property (nonatomic,strong) NSRecursiveLock *safe_lock;
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
//最后替换的dealloc 会最先调用倒序
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
-(void)setSafe_willRemoveObserverInfo:(LSKVOObserverInfo *)safe_willRemoveObserverInfo{
    objc_setAssociatedObject(self, @selector(safe_willRemoveObserverInfo), safe_willRemoveObserverInfo, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
-(LSKVOObserverInfo *)safe_willRemoveObserverInfo{
    return  objc_getAssociatedObject(self, _cmd);
}

-(void)setSafe_notNeedRemoveKeypathFromCrashArray:(BOOL)safe_notNeedRemoveKeypathFromCrashArray{
    objc_setAssociatedObject(self, @selector(safe_notNeedRemoveKeypathFromCrashArray),@(safe_notNeedRemoveKeypathFromCrashArray), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
-(BOOL)safe_notNeedRemoveKeypathFromCrashArray{
    return  [objc_getAssociatedObject(self, _cmd) boolValue];
}

-(void)setSafe_lock:(NSRecursiveLock *)safe_lock{
    objc_setAssociatedObject(self, @selector(safe_lock),safe_lock, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
-(NSRecursiveLock *)safe_lock
{
    @synchronized(self){
        LSRecursiveLock *myLock=objc_getAssociatedObject(self, _cmd);
        if (myLock==nil) {
            myLock=[[LSRecursiveLock alloc]init];
            self.safe_lock=myLock;
        }
        return myLock;
    }
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
        return ;
    }
    observer.safe_notNeedRemoveKeypathFromCrashArray=YES;
    [self.safe_lock lock];
    
    LSKVOObserverInfo *info=[self safe_canAddOrRemoveObserverWithKeypathWithObserver:observer keyPath:keyPath context:context haveContext:YES isAdd:YES];
    
    if(info!=nil){
        //如果添加过了直接return
        LSKVOSafeLog(@"添加失败:%d %@:%p safe_addObserver %@:%p  keyPath:%@",(context!=NULL),[self class],self,[observer class],observer,keyPath);
        [self.safe_lock unlock];
        return;
    }
    @try {
        LSKVOSafeLog(@"添加成功:%d %@:%p safe_addObserver %@:%p  keyPath:%@",(context!=NULL),[self class],self,[observer class],observer,keyPath);
        
        NSString *targetAddress=[NSString stringWithFormat:@"%p",self];
        NSString *observerAddress=[NSString stringWithFormat:@"%p",observer];
        LSKVOObserverInfo *info=[LSKVOObserverInfo new];
        info.target=self;
        info.observer=observer;
        info.keyPath=keyPath;
        info.context=context;
        info.targetAddress=targetAddress;
        info.observerAddress=observerAddress;
        info.targetClassName=NSStringFromClass([self class]);
        info.observerClassName=NSStringFromClass([observer class]);
        [self.safe_downObservedKeyPathArray addObject:info];
        [observer.safe_upObservedArray addObject:info];
        [self safe_addObserver:observer forKeyPath:keyPath options:options context:context];
        
        //交换dealloc方法
        [observer safe_KVOChangeDidDeallocSignal];
        [self safe_KVOChangeDidDeallocSignal];
    }
    @catch (NSException *exception) {
        LSSafeProtectionCrashLog(exception,LSSafeProtectorCrashTypeKVO);
    }
    @finally {
        LSKVOSafeLog(@"添加结束:%d %@:%p safe_addObserver %@:%p  keyPath:%@",(context!=NULL),[self class],self,[observer class],observer,keyPath);
        [self.safe_lock unlock];
    }
}

//以下两个方法的区别
//带context的方法只能移除监听了context的kvo，否则会崩溃，即使有相同kaypath不带context也会崩溃
//不带context优先移除不带context的kvo，然后寻找keypath相同带context的kvo
//移除时不但要把 有哪些对象监听了自己字典移除，还要把observer的监听了哪些人字典移除
- (void)safe_removeObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath{
    [self safe_allRemoveObserver:observer forKeyPath:keyPath context:nil isContext:NO];
}
- (void)safe_removeObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath context:(void *)context{
    [self safe_allRemoveObserver:observer forKeyPath:keyPath context:context isContext:YES];
}

/**
 @param isContext 是否有context
 */
- (void)safe_allRemoveObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath context:(void *)context isContext:(BOOL)isContext{
    
    if(!observer||!keyPath||([keyPath isKindOfClass:[NSString class]]&&keyPath.length<=0)){
        return ;
    }
    NSRecursiveLock *lock = self.safe_lock;
    [lock lock];
    LSKVOObserverInfo *info=[self safe_canAddOrRemoveObserverWithKeypathWithObserver:observer keyPath:keyPath context:context haveContext:isContext isAdd:NO];
    if (info==nil) {
        // 重复删除观察者或不含有 或者keypath=nil  observer=nil
        LSKVOSafeLog(@"移除失败:%d %@:%p safe_removeObserver %@:%p  keyPath:%@",isContext,[self class],self,[observer class],observer,keyPath);
        [lock unlock];
        return;
    }
    
    @try {
        LSKVOSafeLog(@"移除成功:%d %@:%p safe_removeObserver %@:%p  keyPath:%@",isContext, [self class],self,[observer class],observer,keyPath);
        if (isContext) {
            NSString *targetAddress=[NSString stringWithFormat:@"%p",self];
            NSString *observerAddress=[NSString stringWithFormat:@"%p",observer];
            //此处是因为remove  keypath context调用的还是remove keypath方法
            LSKVOObserverInfo *info=[LSKVOObserverInfo new];
            info.keyPath=keyPath;
            info.context=context;
            info.targetAddress=targetAddress;
            info.observerAddress=observerAddress;
            self.safe_willRemoveObserverInfo=info;
            [self safe_removeObserver:observer forKeyPath:keyPath context:context];
        }else{
            void *newContext=NULL;
            if(self.safe_willRemoveObserverInfo){
                newContext=self.safe_willRemoveObserverInfo.context;
            }
            [self safe_removeObserver:observer forKeyPath:keyPath];
        }
    }
    @catch (NSException *exception) {
        LSSafeProtectionCrashLog(exception,LSSafeProtectorCrashTypeKVO);
    }
    @finally {
        if(isContext){
            self.safe_willRemoveObserverInfo=nil;
        }
        [self safe_removeSuccessObserver:observer info:info];
        [lock unlock];
    }
}

-(void)safe_removeSuccessObserver:(NSObject*)observer info:(LSKVOObserverInfo*)info
{
    //    NSString *key =[NSString stringWithFormat:@"%p",self];
    //哪些对象监听了自己
    NSMutableArray *downArray = self.safe_downObservedKeyPathArray;
    
    //observer监听了哪些对象
    NSMutableArray *upArray = observer.safe_upObservedArray;
    
    if(info){
        [downArray removeObject:info];
        [upArray removeObject:info];
    }
}

//为什么判断能否移除 而不是直接remove try catch 捕获异常，因为有的类remove keypath两次，try直接就崩溃了
-(LSKVOObserverInfo*)safe_canAddOrRemoveObserverWithKeypathWithObserver:(NSObject *)observer keyPath:(NSString*)keyPath context:(void*)context haveContext:(BOOL)haveContext isAdd:(BOOL)isAdd
{
    if(observer.safe_notNeedRemoveKeypathFromCrashArray==NO){
        NSString *observerKey=LSFormatterStringFromObject(observer);
        NSMutableDictionary *dic=KVOSafeDeallocCrashes()[observerKey];
        NSMutableArray *array=dic[@"keyPaths"];
        __block NSMutableDictionary *willRemoveDic;
        if(array.count>0){
            [array enumerateObjectsUsingBlock:^(NSMutableDictionary *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if([obj[@"targetName"] isEqualToString:NSStringFromClass([self class])]&&[obj[@"targetAddress"] isEqualToString:[NSString stringWithFormat:@"%p",self]]&&[keyPath isEqualToString:obj[@"keyPath"]]){
                    willRemoveDic=obj;
                    *stop=YES;
                }
            }];
            if(willRemoveDic){
                [array removeObject:willRemoveDic];
                if (array.count<=0) {
                    @synchronized(KVOSafeDeallocCrashes()){
                        [KVOSafeDeallocCrashes() removeObjectForKey:observerKey];
                    }
                }
            }
        }
    }
    
    if(haveContext==NO&&self.safe_willRemoveObserverInfo){
        context=self.safe_willRemoveObserverInfo.context;
    }
    
    BOOL contextIsNULL=(context==NULL);
    
    //哪些对象监听了自己
    NSMutableArray *downArray = self.safe_downObservedKeyPathArray;
    NSMutableArray *downKeypathArray=[NSMutableArray array];
    
    __block LSKVOObserverInfo *info;
    [downArray enumerateObjectsUsingBlock:^(LSKVOObserverInfo *  obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.observerAddress isEqualToString:[NSString stringWithFormat:@"%p",observer]]&&[obj.keyPath isEqualToString:keyPath]) {
            if(contextIsNULL){
                [downKeypathArray addObject:obj];
            }else{
                if(obj.context==context){
                    info=obj;
                    *stop=YES;
                }
            }
        }
    }];
    
    if(info){
        return info;
    }
    
    //此处是为了添加了多个相同的keypath,一个不带context,其他的带,remove的时候没加context参数,移除不带context的KVO
    //添加多个带context的kvo，remove时不带context会移除最后添加的那个带context的kvo
    if(contextIsNULL){
        if(isAdd){
            [downKeypathArray enumerateObjectsUsingBlock:^(LSKVOObserverInfo * obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if(obj.context==NULL){
                    info=obj;
                    *stop=YES;
                }
            }];
            if(info){
                return info;
            }
        }else{
            __block BOOL have;
            //寻找是否有不带context的KVO
            if(downKeypathArray.count>0){
                [downKeypathArray enumerateObjectsUsingBlock:^(LSKVOObserverInfo * obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    if(obj.context==NULL){
                        have=YES;
                        info=obj;
                        *stop=YES;
                    }
                }];
            }
            if(info){return info;}
            
            ////没有不带context的KVO,都是带context的KVO,移除最后一个
            if(downKeypathArray.count>0){
                info=downKeypathArray.lastObject;
            }
        }
    }
    return info;
}

/* 防止此种崩溃所以新创建个NSArray 和 NSMutableDictionary遍历
 Terminating app due to uncaught exception 'NSGenericException', reason: '*** Collection <__NSArrayM: 0x61800024f7b0> was mutated while being enumerated.'
 
 Terminating app due to uncaught exception 'NSGenericException', reason: '*** Collection <__NSDictionaryM: 0x170640de0> was mutated while being enumerated.'
 */
-(void)safe_KVODealloc
{
    LSKVOSafeLog(@"%@  safe_KVODealloc",[self class]);
    if (self.safe_upObservedArray.count>0) {
        @synchronized(KVOSafeDeallocCrashes()){
            NSString *currentKey=LSFormatterStringFromObject(self);
            NSMutableDictionary *crashDic=[NSMutableDictionary dictionary];
            NSMutableArray *array=[NSMutableArray array];
            crashDic[@"keyPaths"]=array;
            crashDic[@"className"]=NSStringFromClass([self class]);
            KVOSafeDeallocCrashes()[currentKey]=crashDic;
            for (LSKVOObserverInfo *info in self.safe_upObservedArray) {
                NSMutableDictionary *newDic=[NSMutableDictionary dictionary];
                newDic[@"targetName"]=info.targetClassName;
                newDic[@"targetAddress"]=info.targetAddress;
                newDic[@"keyPath"]=info.keyPath;
                newDic[@"context"]=[NSString stringWithFormat:@"%p",info.context];
                [array addObject:newDic];
            }
        }
    }
    
    
    //A->B A先销毁 B的safe_upObservedArray 里的info.target=nil,然后在B dealloc里在remove会导致移除不了，然后系统会报销毁时还持有某keypath的crash
    //A->B B先销毁 此时A remove 但事实上的A的safe_downObservedArray里info.observer=nil  所以B remove里会判断observer是否有值，如果没值则不remove导致没有remove
    
    //监听了哪些人 让那些人移除自己
    NSMutableArray *newUpArray=[self.safe_upObservedArray mutableCopy];
    for (LSKVOObserverInfo *upInfo in newUpArray) {
        id target=upInfo.target;
        if (target) {
            [target safe_allRemoveObserver:self forKeyPath:upInfo.keyPath context:upInfo.context isContext:upInfo.context!=NULL];
        }else if ([upInfo.targetAddress isEqualToString:[NSString stringWithFormat:@"%p",self]]){
            [self safe_allRemoveObserver:self forKeyPath:upInfo.keyPath context:upInfo.context isContext:upInfo.context!=NULL];
        }
    }
    
    
    //谁监听了自己 移除他们 这块必须处理  不然 A->B   A先销毁了 在B里面调用A remove就无效了，因为A=nil
    NSMutableArray *downNewArray=[self.safe_downObservedKeyPathArray mutableCopy];
    for (LSKVOObserverInfo *downInfo in downNewArray) {
        [self safe_allRemoveObserver:downInfo.observer forKeyPath:downInfo.keyPath context:downInfo.context isContext:downInfo.context!=NULL];
    }
    self.safe_notNeedRemoveKeypathFromCrashArray=NO;
}
+(void)safe_dealloc_crash:(NSString*)classAddress
{
    //比如A先释放了然后走到此处，然后地址又被B重新使用了，A又释放了走了safe_KVODealloc方法，KVOSafeDeallocCrashes以地址为key的值又被重新赋值，导致误报(A还监听着B监听的内容)，赋值KVOSafeDeallocCrashes以地址为kay的字典的时候，导致字典被释放其他地方又使用，导致野指针
    @synchronized(KVOSafeDeallocCrashes()){
        NSString *currentKey=[NSString stringWithFormat:@"%@-%@",classAddress,NSStringFromClass(self)];
        NSDictionary *crashDic = KVOSafeDeallocCrashes()[currentKey];
        for (NSMutableDictionary *dic in crashDic[@"keyPaths"]) {
            NSString *reason=[NSString stringWithFormat:@"%@:(%@） dealloc时仍然监听着 %@:%@ 的 keyPath of %@ context:%@",crashDic[@"className"],classAddress,dic[@"targetName"],dic[@"targetAddress"],dic[@"keyPath"],dic[@"context"]];
            NSException *exception=[NSException exceptionWithName:@"KVO crash" reason:reason userInfo:nil]; LSSafeProtectionCrashLog(exception,LSSafeProtectorCrashTypeKVO);
        }
        [KVOSafeDeallocCrashes() removeObjectForKey:currentKey];
    }
}
NSString * LSFormatterStringFromObject(id object) {
    return   [NSString stringWithFormat:@"%p-%@",object,NSStringFromClass([object class])];
}

@end

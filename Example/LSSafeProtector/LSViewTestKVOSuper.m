

//
//  LSViewTestKVOSuper.m
//  LSSafeProtector
//
//  Created by liusong on 2018/7/2.
//  Copyright © 2018年 liusong. All rights reserved.
//

#import "LSViewTestKVOSuper.h"
#import "NSNotificationTestObject.h"

@interface LSViewTestKVOSuper()

@property (nonatomic,strong) NSNotificationTestObject *testObject;
@property (nonatomic,strong) NSHashTable *table;
@end

@implementation LSViewTestKVOSuper

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(instancetype)initWithFrame:(CGRect)frame
{
    if (self=[super initWithFrame:frame]) {
        self.testObject=[NSNotificationTestObject new];
//        [self addObserver:self.testObject forKeyPath:@"326863287" options:(NSKeyValueObservingOptionNew) context:nil];
        self.table=[[NSHashTable alloc]initWithOptions:(NSPointerFunctionsWeakMemory) capacity:10];
//        [self.table addObject:self];
        
    }
    return self;
}
-(void)dealloc
{
    NSLog(@"");
}

@end

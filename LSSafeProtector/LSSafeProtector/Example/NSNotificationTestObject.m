


//
//  NSNotificationTestObject.m
//  fds11
//
//  Created by liusong on 2018/6/27.
//  Copyright © 2018年 liusong. All rights reserved.
//

#import "NSNotificationTestObject.h"

@implementation NSNotificationTestObject
-(void)handle:(NSNotification*)note
{
    NSLog(@"11111111");
}
-(void)dealloc
{
    NSLog(@"%@  dealloc",NSStringFromClass([self class]));
    [[NSNotificationCenter defaultCenter]removeObserver:self];
//    [self removeObserver:self forKeyPath:@"frame"];
}

//-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
//{
//    NSLog(@"");
//}
@end

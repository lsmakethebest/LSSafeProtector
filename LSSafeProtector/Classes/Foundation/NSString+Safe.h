//
//  NSString+Safe.h
// https://github.com/lsmakethebest/LSSafeProtector
//
//  Created by liusong on 2018/4/20.
//  Copyright © 2018年 liusong. All rights reserved.

#import <Foundation/Foundation.h>

@interface NSString (Safe)
@end

/*
initWithString导致的crash
 如果是[NSString alloc]initWithString 类为NSPlaceholderString
 如果是[NSMutableString alloc]initWithString 类为NSPlaceholderMutableString
 
 __NSCFString
 非常量 或者 [NSMutableString stringWithFormat:@"fs"];
 [[NSMutableString alloc]initWithString:@"fs"];
 [NSString stringWithFormat:]大于7字节
 
 __NSCFConstantString  
 @"fdsfsds"
 [[NSString alloc]initWithString:@"fs"];
 
 NSTaggedPointerString [NSString stringWithFormat:@"fs"]形式创建 当字节小于7时是NSTaggedPointerString 大于7字节时是__NSCFString
 @"123456"0xa003635343332316  当字节大于7填满时并不会立即变成__NSCFString，而是采用一种压缩算法，当压缩之后大于7字节时才会变成__NSCFString ( @"1234567"为 0xa373635343332317 没有压缩， @"12345678"为 0xa007a87dcaecc2a8 开始压缩了）//第一位为a代表是字符串  b为NSNumber,当为NSNumber时最后一位表示(long 3 float为4，Int为2，double为5）
 
 想更多了解可以参考以下链接
 https://www.jianshu.com/p/e354f9137ba8
 http://www.cocoachina.com/ios/20150918/13449.html
 
 */


/*
   1. initWithString
   2. hasPrefix
   3. hasSuffix
   4. substringFromIndex:(NSUInteger)from
   5. substringToIndex:(NSUInteger)to {
   6. substringWithRange:(NSRange)range {
   7. characterAtIndex:(NSUInteger)index
   8. stringByReplacingOccurrencesOfString:(NSString *)target withString:(NSString *)replacement 实际上调用的是9方法
   9. stringByReplacingOccurrencesOfString:(NSString *)target withString:(NSString *)replacement options:(NSStringCompareOptions)options range:(NSRange)searchRange
   10. stringByReplacingCharactersInRange:(NSRange)range withString:(NSString *)replacement
 
 */

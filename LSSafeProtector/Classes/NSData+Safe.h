//
//  NSData+Safe.h
//  LSSafeProtector
// https://github.com/lsmakethebest/LSSafeProtector
//
//  Created by liusong on 2018/9/13.
//

#import <Foundation/Foundation.h>


/*
1. _NSZeroData
   [NSData data]空data
 
2.NSConcreteMutableData
   [NSMutableData data];
 
3.NSConcreteData
   [NSJSONSerialization dataWithJSONObject:[NSMutableDictionary dictionary] options:0 error:nil]
 
4._NSInlineData
     [[NSData alloc]initWithContentsOfURL:[NSURL URLWithString:@"https://www.baidu.com/"]]
 
5.__NSCFData 
*/

/*
 可防止以下crash
 1.subdataWithRange
 2.rangeOfData:options:range:
 
 */



@interface NSData (Safe)

@end

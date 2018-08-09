//
//  NSMutableString+Safe.h
// https://github.com/lsmakethebest/LSSafeProtector
//
//  Created by liusong on 2018/4/20.
//  Copyright © 2018年 liusong. All rights reserved.

#import <Foundation/Foundation.h>

@interface NSMutableString (Safe)
@end

/*
 
除NSString的一些方法外又额外避免了一些方法crash
 
 1.- (void)replaceCharactersInRange:(NSRange)range withString:(NSString *)aString;
 2.- (NSUInteger)replaceOccurrencesOfString:(NSString *)target withString:(NSString *)replacement options:(NSStringCompareOptions)options range:(NSRange)searchRange;
 3.- (void)insertString:(NSString *)aString atIndex:(NSUInteger)loc;
 4.- (void)deleteCharactersInRange:(NSRange)range;
 5.- (void)appendString:(NSString *)aString;
 6.- (void)setString:(NSString *)aString;
 
*/





//
//  NSAttributedString+Safe.h
//  test
//
//  Created by liusong on 2018/6/27.
//

#import <Foundation/Foundation.h>

@interface NSAttributedString (Safe)

@end


/*
 
 目前可避免以下方法crash
    1.- (instancetype)initWithString:(NSString *)str;
    2.- (instancetype)initWithString:(NSString *)str attributes:(nullable NSDictionary<NSAttributedStringKey, id> *)attrs;
    3.- (instancetype)initWithAttributedString:(NSAttributedString *)attrStr;
 
 */

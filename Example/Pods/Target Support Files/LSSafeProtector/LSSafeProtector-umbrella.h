#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "LSSafeProtector.h"
#import "NSArray+Safe.h"
#import "NSAttributedString+Safe.h"
#import "NSDictionary+Safe.h"
#import "NSMutableArray+Safe.h"
#import "NSMutableAttributedString+Safe.h"
#import "NSMutableDictionary+Safe.h"
#import "NSMutableString+Safe.h"
#import "NSNotificationCenter+Safe.h"
#import "NSObject+KVOSafe.h"
#import "NSObject+Safe.h"
#import "NSString+Safe.h"

FOUNDATION_EXPORT double LSSafeProtectorVersionNumber;
FOUNDATION_EXPORT const unsigned char LSSafeProtectorVersionString[];


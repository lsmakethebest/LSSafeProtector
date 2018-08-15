//
//  NSNotificationTestObject.h
//  fds11
//
//  Created by liusong on 2018/6/27.
//  Copyright © 2018年 liusong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LSViewTestKVO.h"

@interface NSNotificationTestObject : NSObject

@property (nonatomic,weak) LSViewTestKVO *kvo;
@property (nonatomic,copy)NSString *name;
@end

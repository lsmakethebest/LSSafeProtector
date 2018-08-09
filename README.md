# LSSafeProtector
强大的防止crash框架
## 
### #import "LSSafeProtector.h"
-  通过如下方式开启防止闪退功能,debug模式会打印crash日志，同时会利用断言来让程序闪退，也会回调block,达到测试环境及时发现及时修改，Release模式既不打印也不会断言闪退，会回调block，自己可以上传exception到bugly
```
    [LSSafeProtector openSafeProtectorWithIsDebug:YES block:^(NSException *exception, LSSafeProtectorCrashType crashType) {
        //[Bugly reportException:exception];
        
        //此方法相对于上面的方法，好处在于bugly后台查看bug崩溃位置时，不用点击跟踪数据，再点击crash_attach.log，查看里面的额外信息来查看崩溃位置
        [Bugly reportExceptionWithCategory:3 name:exception.name reason:[NSString stringWithFormat:@"%@  崩溃位置:%@",exception.reason,exception.userInfo[@"location"]] callStack:@[exception.userInfo[@"callStackSymbols"]] extraInfo:exception.userInfo terminateApp:NO];
    }];
```
### 
## 目前支持以下类型crash

##### LSSafeProtectorCrashTypeSelector
##### LSSafeProtectorCrashTypeKVO,
##### LSSafeProtectorCrashTypeNSArray,
##### LSSafeProtectorCrashTypeNSMutableArray,
##### LSSafeProtectorCrashTypeNSDictionary,
##### LSSafeProtectorCrashTypeNSMutableDictionary,
##### LSSafeProtectorCrashTypeNSStirng,
##### LSSafeProtectorCrashTypeNSMutableString,
##### LSSafeProtectorCrashTypeNSAttributedString,
##### LSSafeProtectorCrashTypeNSMutableAttributedString,
##### LSSafeProtectorCrashTypeNSNotificationCenter








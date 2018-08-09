# LSSafeProtector
强大的防止crash框架
## 
### #import "LSSafeProtector.h"
-  通过如下方式开启防止闪退功能,debug模式会打印crash日志，同时会利用断言来让程序闪退，也会回调block,达到测试环境及时发现及时修改，Release模式既不打印也不会断言闪退，会回调block，自己可以上传exception到bugly
```
    [LSSafeProtector openSafeProtectorWithIsDebug:YES block:^(NSException *exception, LSSafeProtectorCrashType crashType) {
        [Bugly reportException:exception];
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








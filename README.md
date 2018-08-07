# LSSafeProtector
强大的防止crash框架
## 
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


### #import "NSObject+Safe.h"
### 通过如下方式开启防止闪退功能,debug模式会打印crash日志，同时会利用断言来让程序闪退，也会回调block,达到测试环境及时发现及时修改，Release模式既不打印也不会断言闪退，会回调block，自己可以上传exception到bugly
``
[NSObject openAllSafeProtectorWithIsDebug:YES block:^(NSException *exception, LSSafeProtectorCrashType crashType) {
    [Bugly reportException:exception];
}];
``
## 目前发现个问题，就是用系统相机拍照，第一次拍没问题，第二次拍就闪退，正在找原因，会尽快解决，所以可以先关闭防止kvo闪退功能，到NSOBbject+Safe.m里的openAll方法里注释[NSObject openKVOSafe]这行代码，等到修复这个问题之后再打开

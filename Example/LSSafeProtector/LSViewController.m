//
//  ViewController.m
//  LSSafeProtector
//
//  Created by liusong on 2018/6/27.
//  Copyright © 2018年 liusong. All rights reserved.
//

#import "LSViewController.h"
#import "NSNotificationTestObject.h"
#import "LSViewTestKVO.h"
#import "LSViewTestKVOSuper.h"
#import <LSSafeProtector/LSSafeProtector.h>
#import <Bugly/Bugly.h>

@interface LSViewController ()
@property (weak, nonatomic) IBOutlet UIButton *testButton;
@property (weak, nonatomic) IBOutlet UIButton *productionButton;

@property (nonatomic,strong) NSNotificationTestObject *testObject;
@property (nonatomic,strong) NSNotificationTestObject *testObject2;
@property (nonatomic,assign) BOOL kvoTest;
@property (nonatomic,weak) LSViewTestKVO *testView1;
@property (nonatomic,weak) LSViewTestKVO *testView2;
@property (nonatomic,copy)NSString *name;

-(void)getName;
-(void)getAge:(NSInteger)age;
-(id)getSafeObject;
@end

@implementation LSViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}
- (IBAction)testStart:(id)sender {
    [self startSafe:YES];
}

- (IBAction)productionStart:(id)sender {
    [self startSafe:NO];
}

-(void)startSafe:(BOOL)isDebug
{
    self.testButton.enabled=NO;
    self.productionButton.enabled=NO;
    
    //    IsDebug=YES代表开发环境  捕捉到崩溃 ，会打印崩溃信息，同时利用断言闪退，会回调block
    //    IsDebug=NO，代表线上环境，拦截到崩溃不打印崩溃信息，也不会断言闪退，会回调block
    [LSSafeProtector openSafeProtectorWithIsDebug:isDebug block:^(NSException *exception, LSSafeProtectorCrashType crashType) {
        //[Bugly reportException:exception];
        //此方法方便在bugly后台查看bug崩溃位置，而不用点击跟踪数据，再点击crash_attach.log来查看崩溃位置
        [Bugly reportExceptionWithCategory:3 name:exception.name reason:[NSString stringWithFormat:@"%@  崩溃位置:%@",exception.reason,exception.userInfo[@"location"]] callStack:@[exception.userInfo[@"callStackSymbols"]] extraInfo:exception.userInfo terminateApp:NO];
    }];
}

-(void)haha
{
    NSLog(@"1111111");
}



-(IBAction)testUnrecognizedSelector
{
    [self getName];
}

-(IBAction)testKVO
{
    //添加值为nil
    //    [self addObserver:nil forKeyPath:@"fsd" options:(NSKeyValueObservingOptionNew) context:nil];
    //    [self addObserver:self.testView1 forKeyPath:nil options:(NSKeyValueObservingOptionNew) context:nil];
    
    
    
    //演示添加 然后自己移除 然后交换的dealloc方法里就不会在移除了
    //    LSViewTestKVO *view1 =[LSViewTestKVO new];
    //    [self.view addSubview:view1];
    //    self.testView1=view1;
    //    self.testView1.con=self;
    //    [self addObserver:self.testView1 forKeyPath:@"kvoTest" options:(NSKeyValueObservingOptionNew) context:nil];
    //    [self removeObserver:self.testView1 forKeyPath:@"kvoTest"];
    //    [self.testView1 removeFromSuperview];
    
    
    //重复移除
    //    LSViewTestKVO *view1 =[LSViewTestKVO new];
    //    [self.view addSubview:view1];
    //    self.testView1=view1;
    //    self.testView1.con=self;
    //    [self addObserver:self.testView1 forKeyPath:@"kvoTest" options:(NSKeyValueObservingOptionNew) context:nil];
    //    [self removeObserver:self.testView1 forKeyPath:@"kvoTest"];
    //    [self removeObserver:self.testView1 forKeyPath:@"kvoTest" context:nil];
    
    
    //重复添加
    //                LSViewTestKVO *view1 =[LSViewTestKVO new];
    //        [self.view addSubview:view1];
    //        self.testView1=view1;
    //        self.testView1.con=self;
    //                [self addObserver:self.testView1 forKeyPath:@"kvoTest" options:(NSKeyValueObservingOptionNew) context:nil];
    //        [self addObserver:self.testView1 forKeyPath:@"kvoTest" options:(NSKeyValueObservingOptionNew) context:nil];
    
    
    
    
    //    dealloc时没有移除obverser
    //        LSViewTestKVO *view1 =[LSViewTestKVO new];
    //        [self.view addSubview:view1];
    //        self.testView1=view1;
    //        self.testView1.con=self;
    //        [self.testView1 addObserver:self.testView1 forKeyPath:@"kvoTest" options:(NSKeyValueObservingOptionNew) context:nil];
    
    
    self.testObject=[[NSNotificationTestObject alloc]init];
    //       self.testObject.kvo=self;
    //       [self.testObject addObserver:self.testObject forKeyPath:@"fractionCompleted" options:(NSKeyValueObservingOptionNew) context:@"fsd22"];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self.testObject addObserver:self.testObject forKeyPath:@"fractionCompleted1" options:(NSKeyValueObservingOptionNew) context:@"fsd22"];
        //        [self.testObject addObserver:self.testObject forKeyPath:@"fractionCompleted1" options:(NSKeyValueObservingOptionNew) context:@"fsd22"];
        //        [self.testObject addObserver:self.testObject forKeyPath:@"fractionCompleted3" options:(NSKeyValueObservingOptionNew) context:@"fsd22"];
    });
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self.testObject addObserver:self.testObject forKeyPath:@"fractionCompleted1" options:(NSKeyValueObservingOptionNew) context:@"fsd22"];
    });
    //    dispatch_async(dispatch_get_global_queue(0, 0), ^{
    //        [self.testObject addObserver:self.testObject forKeyPath:@"fractionCompleted3" options:(NSKeyValueObservingOptionNew) context:@"fsd22"];
    //    });
    //    [self.testObject addObserver:self.testObject forKeyPath:@"name" options:(NSKeyValueObservingOptionNew) context:nil];
    //       [self addObserver:self.testObject forKeyPath:@"name" options:(NSKeyValueObservingOptionNew) context:nil];
    //     [self addObserver:self.testObject forKeyPath:@"name" options:(NSKeyValueObservingOptionNew) context:nil];
    
    //         [self removeObserver:self.testObject forKeyPath:@"name"];
    //        [self removeObserver:self.testObject forKeyPath:@"name"];
    //        [self removeObserver:self.testObject forKeyPath:@"name"];
    //        [self removeObserver:self.testObject forKeyPath:@"name" ];
    //        [self removeObserver:self.testObject forKeyPath:@"name" context:@"fsd"];
    //        [self.testView1 removeFromSuperview];
    //        self.testObject=nil;
    //        self.name=@"fs";
    //        [self.testView1  removeFromSuperview];
    
    
    
    
    
    //    self.testObject2=[[NSNotificationTestObject alloc]init];
    //     [self.testView1 addObserver:self.testObject2 forKeyPath:@"frame" options:(NSKeyValueObservingOptionNew) context:@"fsd"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.testObject=nil;
//        dispatch_async(dispatch_get_global_queue(0, 0), ^{
//            [self.testObject removeObserver:self.testObject forKeyPath:@"fractionCompleted1"];
//        });
//        dispatch_async(dispatch_get_global_queue(0, 0), ^{
//            [self.testObject removeObserver:self.testObject forKeyPath:@"fractionCompleted1"];
//        });
    });
    //        self.testObject2=nil;
    //    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    //
    //        self.testView1.frame=CGRectZero;
    //    });
    
    //        [self addObserver:self.testObject forKeyPath:@"kvoTest" options:(NSKeyValueObservingOptionNew) context:nil];
    
    //        [self.testView1 removeFromSuperview];
    //        self.testObject=nil;
    
    //        self.kvoTest=YES;
}


-(IBAction)testArray
{
    NSString *value=nil;
    NSString *strings[3];
    strings[0]=@"000";
    strings[1]=value;
    strings[2]=@"222";
    [NSArray arrayWithObjects:strings count:3];
    //        [[NSArray alloc]initWithObjects:strings count:3];
    
    //        NSArray *a1=[NSArray array];
    //        a1[10];
    //
    //
    //        NSArray *a2=@[@"fs"];
    //        a2[10];
    //
    //        NSArray *a3=@[@"fs",@"fsd"];
    //        a3[10];
}

-(IBAction)testMutableArray
{
    NSString *value=nil;
    NSString *strings[3];
    strings[0]=@"000";
    strings[1]=value;
    strings[2]=@"222";
    //        [NSMutableArray arrayWithObjects:strings count:3];
    //        [[NSMutableArray alloc]initWithObjects:strings count:3];
    
    NSMutableArray *a1=[NSMutableArray array];
    //    dispatch_async(dispatch_get_global_queue(0, 0), ^{
    a1[10];
    //    });
}


-(IBAction)testDictionary
{
    NSString *value=nil;
    NSString *strings[3];
    strings[0]=@"000";
    strings[1]=value;
    strings[2]=@"222";
    [[NSDictionary alloc]initWithObjects:strings forKeys:strings count:3];
    [[NSDictionary alloc]initWithObjects:@[@"key1",value,@"key3"] forKeys:@[@"value1",value,@"value3"]];
    NSDictionary *dic1=@{};
    dic1[value];
    
    NSDictionary *dic2=@{@"key1":@"vlaue1"};
    dic2[value];
    
    NSDictionary *dic3=@{@"key1":@"vlaue1",@"key2":@"value2"};
    dic3[value];
}

-(IBAction)testMutableDictionary
{
    NSString *value=nil;
    NSString *strings[3];
    strings[0]=@"000";
    strings[1]=value;
    strings[2]=@"222";
    [[NSMutableDictionary alloc]initWithObjects:strings forKeys:strings count:3];
    [[NSMutableDictionary alloc]initWithObjects:@[@"key1",value,@"key3"] forKeys:@[@"value1",value,@"value3"]];
    NSMutableDictionary *dic1=[NSMutableDictionary dictionary];
    dic1[value]=@"";
    dic1[@"d"]=value;
}


-(IBAction)testString
{
    NSString *s1=@"hello world";
    NSString *s122=[NSString stringWithFormat:@"fs"];
    NSString *s1222=[[NSString alloc]initWithString:@"fs"];
    [s122 substringFromIndex:230];
    NSString *value=nil;
    NSString *ss=[[NSString alloc]initWithString:value];
    [s1 substringFromIndex:100];
    [s1 substringToIndex:100];
    [s1 substringWithRange:NSMakeRange(0, 100)];
    [s1 characterAtIndex:100];
    [s1 stringByReplacingOccurrencesOfString:@"" withString:value];
    [s1 stringByReplacingOccurrencesOfString:@"" withString:@"" options:0 range:NSMakeRange(0, 100)];
    [s1 stringByReplacingCharactersInRange:NSMakeRange(0, 100) withString:@"fs"];
    [s1 hasPrefix:value];
    [s1 hasSuffix:value];
}

-(IBAction)testMutableString
{
    NSMutableString *s1=[NSMutableString stringWithString: @"hello world"];
    NSString *value=nil;
    NSString *ss=[[NSMutableString alloc]initWithString:value];
    [s1 substringFromIndex:100];
    [s1 substringToIndex:100];
    [s1 substringWithRange:NSMakeRange(0, 100)];
    [s1 characterAtIndex:100];
    [s1 stringByReplacingOccurrencesOfString:@"" withString:value];
    [s1 stringByReplacingOccurrencesOfString:@"" withString:@"" options:0 range:NSMakeRange(0, 100)];
    [s1 stringByReplacingCharactersInRange:NSMakeRange(0, 100) withString:@"fs"];
    [s1 hasPrefix:value];
    [s1 hasSuffix:value];
    NSLog(@"NSMutableString特有crash");
    [s1 replaceCharactersInRange:NSMakeRange(0, 100) withString:@""];
    [s1 replaceOccurrencesOfString:@"" withString:@"" options:0 range:NSMakeRange(0, 100)];
    [s1 insertString:value atIndex:100];
    [s1 deleteCharactersInRange:NSMakeRange(0,100)];
    [s1 appendString:value];
    [s1 setString:value];
    
}
-(IBAction)testAttributedString
{
    UIFont *font=[UIFont systemFontOfSize:12];
    [[NSAttributedString alloc]initWithString:nil];
    [[NSAttributedString alloc]initWithAttributedString:nil];
    [[NSAttributedString alloc]initWithString:nil attributes:@{NSFontAttributeName:font}];
}

-(IBAction)testMutableAttributedString
{
    UIFont *font=nil;
    [[NSMutableAttributedString alloc]initWithString:nil];
    NSMutableAttributedString *s1 =  [[NSMutableAttributedString alloc]initWithAttributedString:nil];
    [[NSMutableAttributedString alloc]initWithString:nil attributes:@{NSFontAttributeName:font}];
    NSMutableAttributedString *s2=[[NSMutableAttributedString alloc]initWithString:@"hello world"];
    [s2 replaceCharactersInRange:NSMakeRange(0, 100) withString:@"jj"];
    [s2 setAttributes:nil range:NSMakeRange(0, 100)];
    [s2 addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, 1)];
    [s2 addAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12]} range:NSMakeRange(0, 100)];
    [s2 removeAttribute:NSFontAttributeName range:NSMakeRange(0, 100)];
    [s2 replaceCharactersInRange:NSMakeRange(0, 10) withAttributedString:nil];
    [s2 insertAttributedString:[[NSAttributedString  alloc]initWithString:@"fs"] atIndex:100];
    [s2 appendAttributedString:nil];
    [s2 deleteCharactersInRange:NSMakeRange(0, 100)];
    [s2 setAttributedString:nil];
}

-(IBAction)testNotification
{
    if (self.testObject==nil) {
        self.testObject=[[NSNotificationTestObject alloc]init];
    }
    [[NSNotificationCenter defaultCenter]addObserver:self.testObject selector:@selector(handle:) name:@"name" object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self.testObject name:@"name2" object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self.testObject name:@"fsdf" object:nil];
    //    self.testObject=nil;
    [[NSNotificationCenter defaultCenter]postNotificationName:@"name" object:nil];
}


@end

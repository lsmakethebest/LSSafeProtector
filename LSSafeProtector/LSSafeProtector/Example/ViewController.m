//
//  ViewController.m
//  LSSafeProtector
//
//  Created by liusong on 2018/6/27.
//  Copyright © 2018年 liusong. All rights reserved.
//

#import "ViewController.h"
#import "NSObject+Safe.h"
#import "NSNotificationTestObject.h"
#import "LSViewTestKVO.h"
#import "LSViewTestKVOSuper.h"
@interface ViewController ()

@property (nonatomic,strong) NSNotificationTestObject *testObject;
@property (nonatomic,strong) NSNotificationTestObject *testObject2;
@property (nonatomic,assign) BOOL kvoTest;
@property (nonatomic,weak) LSViewTestKVO *testView1;
@property (nonatomic,weak) LSViewTestKVO *testView2;
-(void)getName;
-(void)getAge:(NSInteger)age;
-(id)getSafeObject;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [NSObject openAllSafeProtectorWithBlock:^(NSException *exception, LSSafeProtectorCrashType crashType) {

    }];
}
-(void)haha
{
    NSLog(@"1111111");
}


-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    //    [self testUnrecognizedSelector];
        [self testKVO];
//        [self testNotification];
    //    [self testArray];
    //    [self testMutableArray];
    //    [self testDictionary];
    //    [self testMutableDictionary];
    //    [self testString];
    //    [self testMutableString];
    //    [self testAttributedString];
    //    [self testMutableAttributedString];
    
}
-(void)testUnrecognizedSelector
{
    [self getName];
}

-(void)testKVO
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
    //        LSViewTestKVO *view1 =[LSViewTestKVO new];
    //        [self.view addSubview:view1];
    //        self.testView1=view1;
    //        self.testView1.con=self;
    //        [self addObserver:self.testView1 forKeyPath:@"kvoTest" options:(NSKeyValueObservingOptionNew) context:nil];
    //        [self addObserver:self.testView1 forKeyPath:@"kvoTest" options:(NSKeyValueObservingOptionNew) context:nil];
    
    
    
    
    //    dealloc时没有移除obverser
//        LSViewTestKVO *view1 =[LSViewTestKVO new];
//        [self.view addSubview:view1];
//        self.testView1=view1;
//        self.testView1.con=self;
//        [self.testView1 addObserver:self.testView1 forKeyPath:@"kvoTest" options:(NSKeyValueObservingOptionNew) context:nil];

    
        self.testObject=[[NSNotificationTestObject alloc]init];
        self.testObject.kvo=self.testObject;
        [self.testObject addObserver:self.testObject forKeyPath:@"frame" options:(NSKeyValueObservingOptionNew) context:@"fsd"];
//        [self.testView1  removeFromSuperview];
    self.testObject=nil;
    
    
    
    
//    self.testObject2=[[NSNotificationTestObject alloc]init];
//     [self.testView1 addObserver:self.testObject2 forKeyPath:@"frame" options:(NSKeyValueObservingOptionNew) context:@"fsd"];
//
//        self.testObject=nil;
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

-(void)testNotification
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
-(void)testArray
{
    NSString *value=nil;
    NSString *strings[3];
    strings[0]=@"000";
    strings[1]=value;
    strings[2]=@"222";
    [NSArray arrayWithObjects:strings count:3];
    [[NSArray alloc]initWithObjects:strings count:3];
    
    NSArray *a1=[NSArray array];
    a1[10];
    
    
    NSArray *a2=@[@"fs"];
    a2[10];
    
    NSArray *a3=@[@"fs",@"fsd"];
    a3[10];
}

-(void)testMutableArray
{
    NSString *value=nil;
    NSString *strings[3];
    strings[0]=@"000";
    strings[1]=value;
    strings[2]=@"222";
    [NSMutableArray arrayWithObjects:strings count:3];
    [[NSMutableArray alloc]initWithObjects:strings count:3];
    
    NSMutableArray *a1=[NSMutableArray array];
    a1[10];
    
}


-(void)testDictionary
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

-(void)testMutableDictionary
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


-(void)testString
{
    NSString *s1=@"hello world";
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

-(void)testMutableString
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
-(void)testAttributedString
{
    UIFont *font=[UIFont systemFontOfSize:12];
    [[NSAttributedString alloc]initWithString:nil];
    [[NSAttributedString alloc]initWithAttributedString:nil];
    [[NSAttributedString alloc]initWithString:nil attributes:@{NSFontAttributeName:font}];
}

-(void)testMutableAttributedString
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




@end

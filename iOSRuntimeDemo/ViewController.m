//
//  ViewController.m
//  iOSRuntimeDemo
//
//  Created by 蔡晓阳 on 2018/7/18.
//  Copyright © 2018 cxy. All rights reserved.
//

#import "ViewController.h"
#import "Person.h"
#import <objc/runtime.h>
@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, copy) NSArray *dataArr;



@end

@implementation ViewController

//- (void)cxy_viewWillAppear:(BOOL)animated {
//    [self cxy_viewWillAppear:animated];
//    NSLog(@"%s",__func__);
//}
//
//- (void)viewWillAppear:(BOOL)animated {
//    [super viewWillAppear:animated];
//    NSLog(@"%s",__func__);
//}

- (void)originalMethod {
    NSLog(@"%s",__func__);
}

- (void)overrideMethod {
    NSLog(@"%s",__func__);
}

+ (void)load {
    SEL originalSelector = @selector(originalMethod);
    SEL overrideSelector = @selector(overrideMethod);
    Method originalMethod = class_getInstanceMethod(self, originalSelector);
    Method overrideMethod = class_getInstanceMethod(self, overrideSelector);
    if (class_addMethod(self, originalSelector, method_getImplementation(overrideMethod), method_getTypeEncoding(overrideMethod))) {
        class_replaceMethod(self, overrideSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, overrideMethod);
    }
}

- (NSArray *)dataArr {
    if (!_dataArr) {
        _dataArr = @[@"动态方法解析resolveInstanceMethod",@"重定向forwardingTargetForSelector",@"转发forwardInvocation"];
    }
    return _dataArr;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self originalMethod];
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *ID = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:ID];
    }
    cell.textLabel.text = self.dataArr[indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:true];
    
    if (indexPath.row == 0) {
        [self test1];
    } else if (indexPath.row == 1) {
        [self test2];
    } else if (indexPath.row == 2) {
        [self test3];
    }
}

- (void)test1 {
    [Person danymicClassMethod:@"cxy"];
    
    Person *person = [[Person alloc] init];
    [person danymicInstanceMethod:@"cxy"];
}
- (void)test2 {
    [Person otherDanymicClassMethod:@"cxy"];
    
    Person *person = [[Person alloc] init];
    [person otherDanymicInstanceMethod:@"cxy"];
}

- (void)test3 {
    [Person oDanymicClassMethod:@"cxy"];
    
    Person *person = [[Person alloc] init];
    [person oDanymicInstanceMethod:@"cxy"];
}


@end

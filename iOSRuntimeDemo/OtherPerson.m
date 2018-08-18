
//
//  OtherPerson.m
//  iOSRuntimeDemo
//
//  Created by 蔡晓阳 on 2018/8/15.
//  Copyright © 2018 cxy. All rights reserved.
//

#import "OtherPerson.h"

@implementation OtherPerson

+ (void)otherDanymicClassMethod:(NSString *)str {
    NSLog(@"OtherPersonDanymicClassMethod %@",str);
}

- (void)otherDanymicInstanceMethod:(NSString *)str {
    NSLog(@"OtherPersonDanymicInstanceMethod %@",str);
}

+ (void)oDanymicClassMethod:(NSString *)str {
    NSLog(@"oDanymicClassMethod %@",str);
}
- (void)oDanymicInstanceMethod:(NSString *)str {
    NSLog(@"oDanymicInstanceMethod %@",str);
}
@end

//
//  OtherPerson.h
//  iOSRuntimeDemo
//
//  Created by 蔡晓阳 on 2018/8/15.
//  Copyright © 2018 cxy. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface OtherPerson : NSObject

+ (void)otherDanymicClassMethod:(NSString *)str;
- (void)otherDanymicInstanceMethod:(NSString *)str;


+ (void)oDanymicClassMethod:(NSString *)str;
- (void)oDanymicInstanceMethod:(NSString *)str;
@end


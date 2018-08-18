//
//  Person.m
//  iOSRuntimeDemo
//
//  Created by 蔡晓阳 on 2018/8/15.
//  Copyright © 2018 cxy. All rights reserved.
//

#import "Person.h"
#import "OtherPerson.h"
#import <objc/runtime.h>

@interface Person()

@end

@implementation Person

//动态方法解析
+ (BOOL)resolveClassMethod:(SEL)sel {
    if (sel==@selector(danymicClassMethod:)) {
        class_addMethod(object_getClass(self), sel, class_getMethodImplementation(object_getClass(self), @selector(myDanymicClassMethod:)), "v@:");
        return YES;
    }
    return [class_getSuperclass(self) resolveClassMethod:sel];
}

+ (BOOL)resolveInstanceMethod:(SEL)sel {
    if (sel==@selector(danymicInstanceMethod:)) {
        class_addMethod([self class], sel, class_getMethodImplementation([self class], @selector(myDanymicInstanceMethod:)), "v@:");
        return YES;
    }
    return [super resolveInstanceMethod:sel];
}

+ (void)myDanymicClassMethod:(NSString *)str {
    NSLog(@"myDanymicClassMethod %@",str);
}

- (void)myDanymicInstanceMethod:(NSString *)str {
    NSLog(@"myDanymicInstanceMethod %@",str);
}

//forwardingTargetForSelector
+ (id)forwardingTargetForSelector:(SEL)aSelector {
    if (aSelector==@selector(otherDanymicClassMethod:)) {
        return [OtherPerson class];
    }
    return [super forwardingTargetForSelector:aSelector];
}

- (id)forwardingTargetForSelector:(SEL)aSelector {
    if (aSelector==@selector(otherDanymicInstanceMethod:)) {
        return [[OtherPerson alloc] init];
    }
    return [super forwardingTargetForSelector:aSelector];
}

//forwardInvocation

- (void)forwardInvocation:(NSInvocation *)anInvocation {
    OtherPerson *otherPerson = [[OtherPerson alloc] init];
    if (anInvocation.selector==@selector(oDanymicInstanceMethod:)) {
        [anInvocation invokeWithTarget:otherPerson];
    } else {
        [super forwardInvocation:anInvocation];
    }
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
    if (aSelector==@selector(oDanymicInstanceMethod:)) {
        return [NSMethodSignature signatureWithObjCTypes:"v@:"];
    }
    return nil;
}

+ (void)forwardInvocation:(NSInvocation *)anInvocation {
    if (anInvocation.selector==@selector(oDanymicClassMethod:)) {
        [anInvocation invokeWithTarget:[OtherPerson class]];
    } else {
        [super forwardInvocation:anInvocation];
    }
}

+ (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
    if (aSelector==@selector(oDanymicClassMethod:)) {
        return [NSMethodSignature signatureWithObjCTypes:"v@:"];
    }
    return nil;
}


@end

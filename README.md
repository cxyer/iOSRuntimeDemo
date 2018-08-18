# Runtime
Objective-C的动态性
1. 概念
    1. SEL：映射到方法的字符串
        ```
        typedef struct objc_selector *SEL;
        ```
        使用@selector()或sel_registerName获得
    2. id：指向类实例的指针
        ```
        typedef struct objc_object *id;

        struct objc_object {
            isa_t isa;
        }
        ```
        objc_objecth包含一个isa指针，可以找到对象所属的类
    3. Method：类方法
        ```
        typedef struct method_t *Method;

        struct method_t {
            //方法名
            SEL name;
            //方法类型
            const char *types;
            //方法实现
            IMP imp;
        }
        ```
    4. Ivar：类变量
        ```
        typedef struct ivar_t *Ivar;
        ```
    5. IMP：方法实现
        ```
        typedef void (*IMP)(void /* id, SEL, ... */ );
        ```
2. 消息发送
    1. objc_msgSend：objc_msgSend(receiver, selector, arg1, arg2, ...)

3. 动态方法解析
    ```
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
    ```
    [self class]和object_getClass(self)等价，[self class]会调用object_getClass(self)，这是self为实例对象的情况。如果self为类对象，那么[self class]会返回自身，即self，object_getClass(self)得到元类
4. forwardingTargetForSelector
    ```
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
    ```
    由OtherPerson对象实现方法
5. forwardInvocation
    ```
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
    ```
    必须重写methodSignatureForSelector，与forwardingTargetForSelector的区别在于forwardingTargetForSelector只能转发给一个对象，而forwardInvocation可以转发给多个
6. 消息转发过程：resolveInstanceMethod(return no)->forwardingTargetForSelector(return nil)->forwardInvocation->闪退
7. 动态添加对象：Associated Objects
    1. @property做了什么：生成实例变量、生成setter方法、生成getter方法
    2. @property在分类中并没有为我们生成变量和方法，所以我们需要使用关联对象来解决这个问题
    3. 关联对象的方法
        ```
        id objc_getAssociatedObject(id object, const void *key);

        void objc_setAssociatedObject(id object, const void *key, id value, objc_AssociationPolicy policy);

        objc_AssociationPolicy {
            OBJC_ASSOCIATION_ASSIGN
            OBJC_ASSOCIATION_RETAIN_NONATOMIC
            OBJC_ASSOCIATION_COPY_NONATOMIC
            OBJC_ASSOCIATION_RETAIN
            OBJC_ASSOCIATION_COPY
        }
        ```
8. Method Swizzling
    ```
    - (void)cxy_viewWillAppear:(BOOL)animated {
        [self cxy_viewWillAppear:animated];
        NSLog(@"%s",__func__);
    }

    - (void)viewWillAppear:(BOOL)animated {
        [super viewWillAppear:animated];
        NSLog(@"%s",__func__);
    }

    + (void)load {
        SEL originalSelector = @selector(viewWillAppear:);
        SEL overrideSelector = @selector(cxy_viewWillAppear:);
        Method originalMethod = class_getInstanceMethod(self, originalSelector);
        Method overrideMethod = class_getInstanceMethod(self, overrideSelector);
        if (class_addMethod(self, originalSelector, method_getImplementation(overrideMethod), method_getTypeEncoding(overrideMethod))) {
            class_replaceMethod(self, overrideSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
        } else {
            method_exchangeImplementations(originalMethod, overrideMethod);
        }
    }


    结果为
    -[ViewController viewWillAppear:]
    -[ViewController cxy_viewWillAppear:]
    ```
    注意到class_replaceMethod这个方法，如果类中没有被替换实现的方法会调用class_addMethod，否则调用method_setImplementation

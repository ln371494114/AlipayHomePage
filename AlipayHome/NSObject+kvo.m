//
//  NSObject+kvo.m
//  KVO
//
//  Created by 李楠 on 2018/3/5.
//  Copyright © 2018年 李楠. All rights reserved.
//

#import "NSObject+kvo.h"
#import <objc/runtime.h>
#import <objc/message.h>

NSString *const kLNKVOClassPrefix = @"LNKVOClassPrefix_";
NSString *const kLNKVOAssociatedObservers = @"LNKVOAssociatedObservers";


#pragma mark - LNObservationInfo
@interface LNObservationInfo : NSObject

@property (nonatomic, weak) NSObject *observer;
@property (nonatomic, copy) NSString *key;
@property (nonatomic, copy) LNObservingBlock block;

@end

@implementation LNObservationInfo

- (instancetype)initWithObserver:(NSObject *)observer Key:(NSString *)key block:(LNObservingBlock)block
{
    self = [super init];
    if (self) {
        _observer = observer;
        _key = key;
        _block = block;
    }
    return self;
}

@end

@implementation NSObject (kvo)

/***
 简单概述下 KVO 的实现：
 当你观察一个对象时，一个新的类会动态被创建。这个类继承自该对象的原本的类，并重写了被观察属性的 setter 方法。自然，重写的 setter 方法会负责在调用原 setter 方法之前和之后，通知所有观察对象值的更改。最后把这个对象的 isa 指针 ( isa 指针告诉 Runtime 系统这个对象的类是什么 ) 指向这个新创建的子类，对象就神奇的变成了新创建的子类的实例。
 ****/

- (void)LN_addObserver:(NSObject *)observer
                forKey:(NSString *)key
             withBlock:(LNObservingBlock)block
{
    /**  step 1: Throw exception if its class of superclasses does't implement the setter
     1.检查对象的类有没有实现setter方法,如果没有抛出异常 */
    SEL setterSelector = NSSelectorFromString(setterForGetter(key));
    Method setterMethod = class_getInstanceMethod([self class], setterSelector);
    if (!setterMethod)
    {
        // throw invalid argument exception
        NSString *reason = [NSString stringWithFormat:@"Object %@ dose not have a setter for key %@",self, key];
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:reason userInfo:nil];
        return;
    }
    
    /**  step 2: Make KVO class if this is first time adding observer and its class is not an KVO class yet
     2.检查对象 isa 指向的类是不是一个 KVO 类。如果不是，新建一个继承原来类的子类，并把 isa 指向这个新建的子类；  */
    Class clazz = object_getClass(self);
    NSString *clazzName = NSStringFromClass(clazz);
    
    /**    if not an KVO class yet  ***/
    if (![clazzName hasPrefix:kLNKVOClassPrefix]) {
        clazz = [self makeKvoClassWithOriginalClassName:clazzName];
        //将isa指针指向新建的子类
        object_setClass(self, clazz);
    }
    // add our kvo setter if this class (not superclasses) doesn't implement the setter?
    if (![self hasSelector:setterSelector])
    {
        const char *types = method_getTypeEncoding(setterMethod);
        class_addMethod(clazz, setterSelector, (IMP)kvo_setter, types);
    }
    LNObservationInfo *info = [[LNObservationInfo alloc] initWithObserver:observer Key:key block:block];
    NSMutableArray *observers = objc_getAssociatedObject(self, (__bridge const void *)(kLNKVOAssociatedObservers));
    if (!observers) {
        observers = [NSMutableArray array];
        objc_setAssociatedObject(self, (__bridge const void *)(kLNKVOAssociatedObservers), observers, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    [observers addObject:info];
}

- (void)LN_removeObserver:(NSObject *)observer
                   forKey:(NSString *)key
{
    NSMutableArray *observers = objc_getAssociatedObject(self, (__bridge const void *)(kLNKVOAssociatedObservers));
    LNObservationInfo *infoToRemove;
    for (LNObservationInfo *info in observers)
    {
        if (info.observer == observer && [info.key isEqualToString:key]) {
            infoToRemove = info;
            break;
        }
    }
    [observers removeObject:infoToRemove];
}

#pragma mark - Helpers

static NSString * setterForGetter(NSString *getter)
{
    if (getter.length <= 0) {
        return nil;
    }
    // upper case the first letter
    NSString *firstLetter = [[getter substringToIndex:1] uppercaseString];
    NSString *remaiingLetters = [getter substringFromIndex:1];;
    
    // add 'set' at the begining and ':' at the end
    NSString *setter = [NSString stringWithFormat:@"set%@%@:",firstLetter,remaiingLetters];
    return setter;
}

static NSString * getterForSetter(NSString *setter)
{
    if (setter.length <= 0 || ![setter hasPrefix:@"set"] || ![setter hasSuffix:@":"])
    {
        return nil;
    }
    // remove 'set' at the begining and ':' at the end
    NSRange range = NSMakeRange(3, setter.length - 4);
    NSString *key = [setter substringWithRange:range];
    
    // lower case the first letter (返回字符串的小写字母)
    NSString *firstLetter = [[key substringToIndex:1] lowercaseString];
    key = [key stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:firstLetter];
    
    return key;
}

/**  新建一个继承原来类的子类，并把 isa 指向这个新建的子类  */
- (Class)makeKvoClassWithOriginalClassName:(NSString *)originalClazzName
{
    /**  */
    NSString *kvoClazzName = [kLNKVOClassPrefix stringByAppendingString:originalClazzName];
    Class clazz = NSClassFromString(kvoClazzName);
    if (clazz)
    {
        return clazz;
    }
    // class doesn't exist yet, make it
    Class originalClazz = object_getClass(self);
    Class kvoClazz = objc_allocateClassPair(originalClazz, kvoClazzName.UTF8String, 0);
    
    // grab class method's signature(签名) so we can borrow it
    Method clazzMethod = class_getInstanceMethod(originalClazz, @selector(class));
    const char *types = method_getTypeEncoding(clazzMethod);
    class_addMethod(kvoClazz, @selector(class), (IMP)kvo_class, types);
    objc_registerClassPair(kvoClazz);
    return kvoClazz;
}

- (BOOL)hasSelector:(SEL)selector
{
    Class clazz = object_getClass(self);
    unsigned int methodCount = 0;
    Method *methodList = class_copyMethodList(clazz, &methodCount);
    for (unsigned int i = 0; i < methodCount; i++)
    {
        SEL thisSelector = method_getName(methodList[i]);
        if (thisSelector == selector)
        {
            free(methodList);
            return YES;
        }
    }
    free(methodList);
    return NO;
}

#pragma mark - Overridden Methods
/**
 _cmd在Objective-C的方法中表示当前方法的selector，正如同self表示当前方法调用的对象实例一样
 比如，我们要打印当前要调用的方法，可以这样来写：
 - (void)viewDidLoad
 
 {
     [super viewDidLoad];
     NSLog(@"Current method: %@ %@",[self class],NSStringFromSelector(_cmd));
 }
 输出结果如下：
 TestingProject[570:11303] Current method: FirstViewController viewDidLoad
 */
static void kvo_setter(id self, SEL _cmd, id newValue)
{
    NSString *setterName = NSStringFromSelector(_cmd);
    NSString *getterName = getterForSetter(setterName);
    if (!getterName)
    {
        NSString *reason = [NSString stringWithFormat:@"Object %@ does not have setter %@", self, setterName];
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:reason userInfo:nil];
        return;
    }
    id oldValue = [self valueForKey:getterName];
    struct objc_super superclazz = {
        .receiver = self,
        .super_class = class_getSuperclass(object_getClass(self))
    };
    //cast(表述) our pointer so the compiler won't complain
    void (*objc_msgSendSuperCasted)(void *, SEL, id) = (void *)objc_msgSendSuper;
    // call super's setter, which is original class's setter method
    objc_msgSendSuperCasted(&superclazz, _cmd, newValue);
    
    // look up observers and call the blocks
    NSMutableArray *obsevers = objc_getAssociatedObject(self, (__bridge const void *)(kLNKVOAssociatedObservers));
    for (LNObservationInfo *each in obsevers) {
        if ([each.key isEqualToString:getterName]) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                each.block(self, getterName, oldValue, newValue);
            });
        }
    }
}

static Class kvo_class(id self, SEL _cmd)
{
    return class_getSuperclass(object_getClass(self));
}

@end

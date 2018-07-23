//
//  NSObject+kvo.h
//  KVO
//
//  Created by 李楠 on 2018/3/5.
//  Copyright © 2018年 李楠. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^LNObservingBlock)(id observedObject, NSString *observerKey, id oldValue, id newValue);

@interface NSObject (kvo)

- (void)LN_addObserver:(NSObject *)observer
                forKey:(NSString *)key
             withBlock:(LNObservingBlock)block;

- (void)LN_removeObserver:(NSObject *)observer
                   forKey:(NSString *)key;

@end

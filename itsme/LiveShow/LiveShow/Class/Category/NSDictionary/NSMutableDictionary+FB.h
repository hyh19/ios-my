#import <Foundation/Foundation.h>

/**
 *  @author 黄玉辉
 *  @ingroup category
 *  @brief NSMutableDictionary的自定义拓展方法
 */
@interface NSMutableDictionary (FB)

/**
 *  安全设置字典元素的方法，用于避免设置字典元素的值为nil出现错误
 *  @param anObject 字典元素要设置的值
 *  @param aKey     字典元素要设置的键
 */
- (void)safe_setObject:(id)anObject forKey:(id<NSCopying>)aKey;

/**
 *  安全设置字典元素的方法，用于避免设置字典元素的值为nil出现错误，可以指定默认值
 *  @param anObject      字典元素要设置的值
 *  @param aKey          字典元素要设置的键
 *  @param defaultObject 字典元素要设置的值为nil时的默认值
 */
- (void)setObject:(id)anObject forKey:(id<NSCopying>)aKey defaultObject:(id)defaultObject;

@end
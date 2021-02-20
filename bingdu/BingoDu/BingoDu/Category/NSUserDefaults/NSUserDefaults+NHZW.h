#import <Foundation/Foundation.h>

// TODO: 该类仍需安排时间进行重构

/**
 *  @author 黄玉辉->陈梦杉
 *  @ingroup category
 *  @brief NSUserDefaults的自定义拓展类别，用于简化保存配置数据
 */
@interface NSUserDefaults (NHZW)

/** 保存配置数据到本地 */
+ (void)saveValue:(id)value ForKey:(NSString *)key;

/** 读取本地保存的配置数据 */
+ (id)loadValueForKey:(NSString *)key;

/**
 *  读取本地保存的配置数据
 *  @param key          配置数据的键
 *  @param defaultValue 配置数据的默认值
 *  @return 如果配置数据的值为空，则返回指定的默认值
 */
+ (id)loadValueForKey:(NSString *)key defaultValue:(id)defaultValue;

/**
 *  @brief 读取本地保存的配置数据
 *
 *  @param key           配置数据的键
 *  @param defaultObject 配置数据的默认值
 *
 *  @return 如果配置数据的值为空，则返回指定的默认值
 */
+ (id)objectForKey:(NSString *)key defaultObject:(id)defaultObject;

@end
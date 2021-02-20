#import <Foundation/Foundation.h>

/**
 *  @author 黄玉辉->陈梦杉
 *  @ingroup category
 *  @brief NSMutableArray的自定义拓展方法
 */
@interface NSMutableArray (NHZW)

/** 安全地插入元素，如果anObject为nil，则不插入 */
- (void)safe_addObject:(id)anObject;

/** 安全地插入元素，如果otherArray为nil或没有元素，则不插入 */
- (void)safe_addObjectsFromArray:(NSArray *)otherArray;

/** 安全地删除元素，如果anObject为nil，则不删除 */
- (void)safe_removeObject:(id)anObject;

/** 安全地删除元素，如果otherArray为nil或没有元素，则不删除 */
- (void)safe_removeObjectsInArray:(NSArray *)otherArray;

/** 安全地读取元素，如果index越界，则返回nil */
- (id)safe_objectAtIndex:(NSUInteger)index;

@end
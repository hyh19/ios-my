#import <Foundation/Foundation.h>

/**
 *  @author 黄玉辉->陈梦杉
 *  @ingroup category
 *  @brief NSDate的自定义拓展类别
 */
@interface NSDate (NHZW)

/** 获取当前日期的字符串 */
+ (NSString *)todayString;
/** 获取当前日期时间精确到秒的字符串 */
+ (NSString *)todayAccurateString;
@end

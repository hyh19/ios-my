#import <Foundation/Foundation.h>

/**
 *  @author 黄玉辉->陈梦杉
 *  @brief 字体管理器
 */
@interface ZWFontManager : NSObject

/** 读取字体大小 */
+ (UIFont *)sizeWithPrimaryKey:(NSString *)primaryKey andSecondaryKey:(NSString *)secondaryKey;

/** 读取字体颜色 */
+ (UIColor *)colorWithPrimaryKey:(NSString *)primaryKey andSecondaryKey:(NSString *)secondaryKey;

@end

#import <Foundation/Foundation.h>

/**
 *  @author 黄玉辉
 *  @brief 自定义的NSString拓展类
 */
@interface NSString (FB)

/** URL编码 */
+ (NSString *)stringByEncodingURLString:(NSString *)URLString;

@end

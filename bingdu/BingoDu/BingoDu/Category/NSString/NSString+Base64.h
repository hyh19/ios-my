#import <Foundation/Foundation.h>

/**
 *  @author 黄玉辉->陈梦杉
 *  @ingroup category
 *  @brief 字符串Base64加密解密
 */
@interface NSString (Base64)

/**
 *  对字符串进行Base64加密
 *
 *  @return 加密后的字符串
 */
- (NSString *)base64String;

/**
 *  对Base64加密过的字符串进行解密
 *
 *  @param base64String 加密过的字符串
 *
 *  @return 解密后的字符串
 */
+ (NSString *)stringFromBase64String:(NSString *)base64String;

@end

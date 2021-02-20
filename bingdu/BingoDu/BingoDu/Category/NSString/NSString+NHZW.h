#import <Foundation/Foundation.h>

/**
 *  @author 黄玉辉->陈梦杉
 *  @ingroup category
 *  @brief 自定义拓展类别
 */
@interface NSString (NHZW)

/**
*  字符串用星号替代
*  @param source 输入的需要被部分隐藏的字符串
*  @param head   头部需要保留显示的长度
*  @param tail   尾部需要保留显示的长度
*  @return 部分隐藏的用于显示的字符串
*/
+ (NSString *)secureString:(NSString *)source
                headLength:(NSInteger)head
                tailLength:(NSInteger)tail;

/**
 *  求字符串的sie
 *  @param value    string
 *  @param fontSize size
 *  @param width    最大宽度
 *  @return size
 */
+ (CGRect)heightForString:(NSString *)value fontSize:(float)fontSize andSize:(CGSize)size;

/**
 *  计算UILabel的高度
 *
 *  @param lines    行数
 *  @param fontSize 字体大小
 *  @param width    UILabel的宽度
 *
 *  @return UILabel的高度
 */
- (CGFloat)labelHeightWithNumberOfLines:(NSInteger)lines fontSize:(CGFloat)fontSize labelWidth:(CGFloat)width;

/**
 *  对特殊字符进行转换
 *
 *  @param string    需要转换的字符串
 *
 *  @return 转换后的字符串
 */
+ (NSString *)URLEncodedString:(NSString *)string;

@end

/**
 *  @brief NSString的DES加密拓展类别
 *  @ingroup category
 */
@interface NSString (DESCrypto)

/**
 *  DES加密
 *  @param key 密钥字符串
 *  @return 加密后的的密文
 */
- (NSString *)stringByDESEncryptingWithKey:(NSString *)key;
@end

/**
 *  @brief 并读新闻常用的字符串
 *  @ingroup category
 */
@interface NSString (Constants)

/**
 *  短信邀请信息
 *  @param code 邀请码
 *  @return 邀请信息
 */
+ (NSString *)shareMessageForSMSWithInvitationCode:(NSString *)code;

/**
 *  社交工具邀请信息，如微信、微博等。
 *  @param code 邀请码
 *  @return 邀请信息
 */
+ (NSString *)shareMessageForSNSWithInvitationCode:(NSString *)code;

@end

// TODO: 后面要进行重构，光东原来在第三方NSString+PJR上加了，暂时先挪到这里。
/**
 *  @brief 提现金额输入校验
 *  @ingroup category
 */
@interface NSString (Withdrawing)
- (BOOL)isValidWithdrawals:(NSString *)textFieldStr;
@end
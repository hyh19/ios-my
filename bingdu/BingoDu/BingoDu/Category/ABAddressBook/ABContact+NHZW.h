#import "ABContact.h"

/**
 *  @author 黄玉辉->陈梦杉
 *  @ingroup category
 *  @brief 自定义联系人拓展类别，主要用于过滤联系人非手机号码，如固话、小灵通等
 */
@interface ABContact (NHZW)

/** 联系人手机号码数组，不包括固话、小灵通等 */
@property (nonatomic, readonly) NSArray *mobileArray;

/** 联系人手机号码数组拼成的字符串，以空格分隔 */
@property (nonatomic, readonly) NSString *mobileNumbers;

/** 联系人姓名，如果联系人姓名为空，则用手机号码替代 */
@property (nonatomic, readonly) NSString *name;

@end

#import "ABContactsHelper.h"

/**
 *  @author 黄玉辉->陈梦杉
 *  @ingroup category
 *  @brief 自定义通讯录拓展类别，主要用于过滤固话、小灵通等非手机号码联系人
 */
@interface ABContactsHelper (NHZW)

/** 获取手机号码联系人，非手机号码联系人，如固话、小灵通等联系人不获取 */
+ (NSArray *)mobileContacts;

/** 通过手机号码搜索联系人 */
+ (NSArray *)contactsMatchingMobile:(NSString *)number;

/** 读取通讯录全部手机号码，不包括固话、小灵通等非手机号码 */
+ (NSArray *)mobileArray;

@end

#import "ZWBaseTableViewController.h"

/**
 *  @ingroup controller
 *  @author 刘云鹏
 *  @brief 用户填写联系信息
 */
@interface ZWPrizeUserContactInfoViewController : ZWBaseTableViewController
/**
 *  用户购买的数量
 */
@property(nonatomic,strong)NSString* buyNum;
/**
 *  奖品id
 */
@property(nonatomic,strong)NSString* prizeId;
@end

#import <UIKit/UIKit.h>
#import "ZWWithdrawWayModel.h"
#import "ZWBaseTableViewController.h"

/**
 *  @author 林思敏
 *  @author 黄玉辉->陈梦杉
 *  @ingroup controller
 *  @brief 提现申请成功界面
 */
@interface ZWWithdrawSuccedViewController : ZWBaseTableViewController

/** 提现金额 */
@property (nonatomic, copy) NSString *amount;

/** 分享提现的id */
@property (nonatomic, strong) NSNumber *shareId;

/** 提现方式信息 */
@property (nonatomic, strong) ZWWithdrawWayModel *model;

@end

#import <UIKit/UIKit.h>
#import "ZWWithdrawWayModel.h"
#import "ZWBaseTableViewController.h"

/**
 *  @author 林思敏
 *  @author 黄玉辉->陈梦杉
 *  @ingroup controller
 *  @brief 提现账号确认界面
 */
@interface ZWWithdrawConfirmViewController : ZWBaseTableViewController

/** 需要确认的提现账号信息 */
@property (nonatomic, strong) NSDictionary *withdrawInfo;

/** 提现方式信息 */
@property (nonatomic, strong) ZWWithdrawWayModel *model;

@end

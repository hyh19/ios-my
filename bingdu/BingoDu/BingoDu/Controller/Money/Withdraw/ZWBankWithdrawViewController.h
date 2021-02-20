#import "ZWWithdrawWayModel.h"
#import "ZWBaseTableViewController.h"

/**
 *  @author 林思敏
 *  @author 黄玉辉->陈梦杉
 *  @ingroup controller
 *  @brief 提现到银行卡界面
 */
@interface ZWBankWithdrawViewController : ZWBaseTableViewController

/** 提现方式数据模型，在该界面是银行卡 */
@property (nonatomic, strong) ZWWithdrawWayModel *model;

/** 工厂方法 */
+ (instancetype)viewController;

@end

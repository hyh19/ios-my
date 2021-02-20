#import "ZWBaseTableViewController.h"
#import "ZWWithdrawWayModel.h"

/**
 *  @author 林思敏
 *  @brief 身份证验证界面
 */

@interface ZWIdVerificationViewController : ZWBaseTableViewController

/** 提现方式信息 */
@property (nonatomic, strong) ZWWithdrawWayModel *model;

/** 工厂方法 */
+ (instancetype)viewController;

@end

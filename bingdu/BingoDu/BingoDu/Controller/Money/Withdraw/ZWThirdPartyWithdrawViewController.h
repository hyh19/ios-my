#import <UIKit/UIKit.h>
#import "ZWWithdrawWayModel.h"
#import "ZWBaseTableViewController.h"

/**
 *  @author 林思敏
 *  @author 黄玉辉->陈梦杉
 *  @ingroup controller
 *  @brief 提现到第三方支付平台模块，如支付宝、财付通等
 */
@interface ZWThirdPartyWithdrawViewController : ZWBaseTableViewController

@property (nonatomic, strong) NSString *withdrawWayName;

/** 提现方式数据模型，在该界面是支付宝和财付通 */
@property (nonatomic, strong) ZWWithdrawWayModel *model;

/** 工厂方法 */
+ (instancetype)viewController;

@end

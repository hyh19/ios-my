#import <UIKit/UIKit.h>
#import "ZWBaseTableViewController.h"
#import "ZWBankCardRegionViewController.h"
#import "ZWWithdrawWayModel.h"

@class ZWAddBankCardViewController;

/**
 *  @author 林思敏
 *  @author 黄玉辉->陈梦杉
 *  @ingroup protocol
 *  @brief 添加银行卡的委托，添加成功后要做回调处理，如更新用户添加过的所有银行卡列表
 */
@protocol ZWAddBankCardViewControllerDelegate <NSObject>

/**
 *  添加银行卡成功后的回调函数
 *
 *  @param viewController ZWAddBankCardViewController的实例
 *  @param card           添加的银行卡信息
 */
- (void)addBankCardViewController:(ZWAddBankCardViewController *)viewController didAddBankCard:(id)card;

@end

/**
 *  @author 林思敏
 *  @author 黄玉辉->陈梦杉
 *  @ingroup controller
 *  @brief 添加银行卡界面
 */
@interface ZWAddBankCardViewController : ZWBaseTableViewController <ZWBankCardRegionViewControllerDelegate>

/** 添加银行卡的委托，添加成功后要做回调处理，如更新用户添加过的所有银行卡列表 */
@property (nonatomic, weak) id<ZWAddBankCardViewControllerDelegate> delegate;

/** 提现方式数据模型，如果model不为nil，则是补充信息，如果model为nil，则是添加新卡 */
@property (nonatomic, strong) ZWWithdrawWayModel *model;

/** 工厂方法 */
+ (instancetype)viewController;

@end



#import "ZWBaseTableViewController.h"
#import "ZWBankCardRegionModel.h"

@class ZWBankCardRegionViewController;

/**
 *  @author 林思敏
 *  @ingroup protocol
 *  @brief 银行卡归属地区界面的委托
 */
@protocol ZWBankCardRegionViewControllerDelegate <NSObject>

/**
 * 选中某一个归属地后的回调函数
 * @param viewController 当前的归属地列表
 * @param model          选中的归属地
 */
- (void)bankCardRegionViewController:(ZWBankCardRegionViewController *)viewController didSelectRegion:(ZWBankCardRegionModel *)model;

@end

/**
 *  @author 林思敏
 *  @ingroup controller
 *  @brief 银行卡归属地区界面
 */
@interface ZWBankCardRegionViewController : ZWBaseTableViewController

/** 选择银行卡归属地界面的委托对象，用于执行选择某一行的回调操作 */
@property (nonatomic, weak) id<ZWBankCardRegionViewControllerDelegate> delegate;

/** 工厂方法 */
+ (instancetype)viewController;

@end

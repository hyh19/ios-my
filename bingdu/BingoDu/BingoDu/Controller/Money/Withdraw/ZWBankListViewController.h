#import "ZWBaseTableViewController.h"
#import "ZWBankModel.h"

@class ZWBankListViewController;

/**
 *  @author 黄玉辉->陈梦杉
 *  @ingroup protocol
 *  @brief 选择开户银行界面的委托
 */
@protocol ZWBankListViewControllerDelegate <NSObject>

/**
 *  选中某一个银行后的回调函数
 *
 *  @param viewController 当前的银行列表界面
 *  @param bank           选中的银行
 */
- (void)bankListViewController:(ZWBankListViewController *)viewController didSelectBank:(ZWBankModel *)model;

@end

/**
 *  @author 黄玉辉->陈梦杉
 *  @ingroup controller
 *  @brief 选择开户银行界面
 */
@interface ZWBankListViewController : ZWBaseTableViewController

/** 选择开户银行界面的委托对象，用于执行选择某一个银行后的回调操作 */
@property (nonatomic, weak) id<ZWBankListViewControllerDelegate> delegate;

/** 工厂方法 */
+ (instancetype)viewController;

@end
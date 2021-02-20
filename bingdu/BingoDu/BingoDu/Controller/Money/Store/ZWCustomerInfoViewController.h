#import <UIKit/UIKit.h>
#import "ZWBaseTableViewController.h"
#import "ZWGoodsModel.h"

/**
 *  @author 陈新存
 *  @ingroup controller
 *  @brief 实物商品兑换界面
 */
@interface ZWCustomerInfoViewController : ZWBaseTableViewController

/** 商品model */
@property (nonatomic,strong)ZWGoodsModel *goodsModel;

@end

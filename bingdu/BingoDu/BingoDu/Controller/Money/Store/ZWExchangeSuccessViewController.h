#import "ZWBaseViewController.h"
#import "ZWGoodsModel.h"

/**
 *  @author 陈新存
 *  @ingroup controller
 *  @brief 兑换成功
 */
@interface ZWExchangeSuccessViewController : ZWBaseViewController

/** 商品model */
@property (nonatomic,strong)ZWGoodsModel *goodsModel;

/** 商品订单ID */
@property (nonatomic, strong)NSString *orderID;

@end

#import <UIKit/UIKit.h>
#import "ZWGoodsExchangeRecordModel.h"

/**
 *  @author 陈新存
 *  @ingroup view
 *  @brief 商品兑换记录tableviewCell
 */
@interface ZWGoodsExchangeRecordTableViewCell : UITableViewCell

/**
 *  传数据源以及自己在tableview所处的indexpath方法
 */
- (void)recordModel:(ZWGoodsExchangeRecordModel *)recordModel indexPath:(NSIndexPath *)indexPath;

@end

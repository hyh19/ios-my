#import <UIKit/UIKit.h>
#import "ZWLotteryDetailModel.h"
/**
 *  @author 陈新存
 *  @ingroup view
 *  @brief 奖券兑换详情tableviewCell
 */
@interface ZWLotteryRecordDetailTableViewCell : UITableViewCell
/**
 *  设置奖券model，以及所处的tableiview的indexpath
 */
- (void)lotteryDetailModel:(ZWLotteryDetailModel *)lotteryDetailModel indexPath:(NSIndexPath *)indexPath;

@end

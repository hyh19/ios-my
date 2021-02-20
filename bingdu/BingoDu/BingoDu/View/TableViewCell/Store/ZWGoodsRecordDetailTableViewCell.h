#import <UIKit/UIKit.h>
#import "ZWGoodsExchangeDetailModel.h"

@class ZWGoodsRecordDetailTableViewCell;

@protocol ZWGoodsRecordDetailTableViewCellDelegate <NSObject>

@optional
- (void)didClickGoodsAdWithCell:(ZWGoodsRecordDetailTableViewCell *)cell;

@end

/**
 *  @author 陈新存
 *  @ingroup view
 *  @brief 商品兑换记录详情tableviewCell
 */
@interface ZWGoodsRecordDetailTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIButton *advertisementButton;

@property (nonatomic, weak) id<ZWGoodsRecordDetailTableViewCellDelegate> cellDelegate;

/**
 *  传数据源以及自己在tableview所处的indexpath方法
 */
- (void)detailModel:(ZWGoodsExchangeDetailModel *)detailModel indexPath:(NSIndexPath *)indexPath;

@end

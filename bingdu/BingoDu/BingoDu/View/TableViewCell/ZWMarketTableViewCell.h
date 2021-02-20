#import <UIKit/UIKit.h>
#import "ZWMenuModel.h"

/**
 *  @author 林思敏
 *  @brief 集市列表的cell
 */

@class ZWMarketTableViewCell;

@protocol  ZWMarketTableViewCellDelegate<NSObject>

/** 关闭广告 */
- (void)closeAdvertisementWithMarketTableViewCell:(ZWMarketTableViewCell *)cell;

/** 显示广告 */
- (void)clickAdvertisementWithMarketTableViewCell:(ZWMarketTableViewCell *)cell;

@end

@interface ZWMarketTableViewCell : UITableViewCell

@property (nonatomic, strong) ZWMenuModel *data;

@property (nonatomic, weak) id<ZWMarketTableViewCellDelegate> delegate;

@end

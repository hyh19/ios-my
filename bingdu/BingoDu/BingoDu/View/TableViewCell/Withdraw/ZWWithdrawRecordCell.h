#import <UIKit/UIKit.h>
#import "ZWWithdrawRecordModel.h"

/**
 *  @author 林思敏
 *  @author 黄玉辉->陈梦杉
 *  @ingroup view
 *  @brief 用于提现记录界面的Table view cell
 */
@interface ZWWithdrawRecordCell : UITableViewCell

/** 提现记录数据 */
@property (nonatomic, strong) ZWWithdrawRecordModel *data;

@end

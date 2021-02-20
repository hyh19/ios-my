#import <UIKit/UIKit.h>
#import "ZWWithdrawProcessModel.h"

/**
 *  @author 林思敏
 *  @author 黄玉辉->陈梦杉
 *  @ingroup view
 *  @brief 用于提现详情界面提现进度的Table view cell
 */
@interface ZWWithdrawProcessCell : UITableViewCell

/** 提现状态 */
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;

/** 时间信息 */
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

/** 实心大圆点 */
@property (weak, nonatomic) IBOutlet UIView *pointView;

/** 空心大圆点，用于显示未完成状态 */
@property (weak, nonatomic) IBOutlet UIImageView *pointImage;

/** 提现详情进度数据 */
@property (nonatomic, strong) ZWWithdrawProcessModel *data;

@end

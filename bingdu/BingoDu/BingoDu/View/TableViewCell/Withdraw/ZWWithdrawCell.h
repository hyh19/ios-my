#import <UIKit/UIKit.h>
#import "ZWWithdrawWayModel.h"
#import "RTLabel.h"

/**
 *  @author 林思敏
 *  @author 黄玉辉->陈梦杉
 *  @ingroup view
 *  @brief 提现方式
 */
@interface ZWWithdrawCell : UITableViewCell

/** 图标 */
@property (weak, nonatomic) IBOutlet UIImageView *logo;

/** 提现方式名称 */
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

/** 提现手续费 */
@property (weak, nonatomic) IBOutlet UILabel *feeLabel;

/** 到账时间 */
@property (weak, nonatomic) IBOutlet RTLabel *transferredLabel;

/** 提现方式数据 */
@property (nonatomic, strong) ZWWithdrawWayModel *data;

@end

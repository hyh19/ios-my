#import <UIKit/UIKit.h>
#import "ZWWithdrawCell.h"

/**
 *  @author 林思敏
 *  @author 黄玉辉->陈梦杉
 *  @ingroup view
 *  @brief 支付宝、财付通等第三方支付工具免费提现
 */
@interface ZWWithdrawQuotaCell : ZWWithdrawCell

/** 免费提现额度 */
@property (weak, nonatomic) IBOutlet UILabel *freeNumLabel;

/** 剩余份额为零时的灰色背景 */
@property (weak, nonatomic) IBOutlet UIView *cover;

@end

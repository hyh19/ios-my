#import "ZWWithdrawRecordCell.h"
#import "UIImageView+WebCache.h"

@interface ZWWithdrawRecordCell ()

/** 提现方式图标 */
@property (weak, nonatomic) IBOutlet UIImageView *logo;

/** 提现账号 */
@property (weak, nonatomic) IBOutlet UILabel *accountLabel;

/** 提现金额 */
@property (weak, nonatomic) IBOutlet UILabel *amountLabel;

/** 提现手续费 */
@property (weak, nonatomic) IBOutlet UILabel *feeLabel;

/** 提现时间 */
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

/** 提现状态 */
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;

@end

@implementation ZWWithdrawRecordCell

- (void)setData:(ZWWithdrawRecordModel *)data {
    
    self.amountLabel.textColor = COLOR_FB8313;
    
    _data = data;
    
    // 提现账号
    self.accountLabel.text = _data.account;
    
    // 提现时间
    self.timeLabel.text = _data.time;
    
    // 提现金额
    self.amountLabel.text = [NSString stringWithFormat:@"%ld元", (long)(_data.amount+_data.fee)];
    
    self.feeLabel.text = [NSString stringWithFormat:@"（含%ld元手续费）", (long)_data.fee];
    
    // 提现状态
    self.statusLabel.text = _data.statusString;
    
    // 提现状态文字的颜色
    self.statusLabel.textColor = [UIColor colorWithHexString:_data.colorString];
    
    // 提现平台的图标
    [self.logo sd_setImageWithURL:[NSURL URLWithString:_data.logo] placeholderImage:[UIImage imageNamed:@"icon_card"]];
}

@end

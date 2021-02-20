#import "ZWWithdrawCell.h"
#import "UIImageView+WebCache.h"

@implementation ZWWithdrawCell

- (void)setData:(ZWWithdrawWayModel *)data {
    
    _data = data;
    
    // 银行图标
    [self.logo sd_setImageWithURL:[NSURL URLWithString:_data.icon]];
    
    if (_data.type == kWithdrawWayBank) {
        self.nameLabel.text = [NSString stringWithFormat:@"%@ 尾号%@", _data.name, [_data.account substringFromIndex:_data.account.length-4]];
    } else {
        self.nameLabel.text = _data.name;
    }
    
    // 手续费
    {
        NSString *fullText = [NSString stringWithFormat:@"手续费：%.01f元/次", _data.fees];
        
        NSString *feesText = [NSString stringWithFormat:@"%.01f", _data.fees];
        
        NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:fullText];
        
        // 高亮范围
        NSRange hilightedRange = [fullText rangeOfString:feesText];
        
        // 颜色
        [attributedText addAttribute:NSForegroundColorAttributeName value:COLOR_E66514 range:hilightedRange];
        
        self.feeLabel.attributedText = attributedText;
    }
    
    // 到账时间
    {
        self.transferredLabel.text = _data.arrive;
        
        self.transferredLabel.textColor = COLOR_333333;
        
        self.transferredLabel.font = [UIFont systemFontOfSize:12.0f];
        
        self.transferredLabel.textAlignment = RTTextAlignmentRight;
        
        self.transferredLabel.lineBreakMode = RTTextLineBreakModeWordWrapping;
    }
}

@end

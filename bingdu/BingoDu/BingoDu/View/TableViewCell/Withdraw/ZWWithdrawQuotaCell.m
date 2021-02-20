#import "ZWWithdrawQuotaCell.h"

@implementation ZWWithdrawQuotaCell

- (void)setData:(ZWWithdrawWayModel *)data {
    
    [super setData:data];
    
    // 如果官方免费额度用完，则让背景显示灰色，字体颜色也跟着改变
    if (self.data.quato <= 0) {
        self.cover.hidden = NO;
        self.nameLabel.textColor = COLOR_848484;
        self.feeLabel.textColor = COLOR_848484;
        self.transferredLabel.textColor = COLOR_848484;
    } else {
        self.cover.hidden = YES;
        self.nameLabel.textColor = COLOR_333333;
        self.feeLabel.textColor = COLOR_333333;
        self.transferredLabel.textColor = COLOR_333333;
    }
    
    // 提现限额
    {
        NSString *fullText = [NSString stringWithFormat:@"今日剩余：%ld份", (long)self.data.quato];
        NSString *numText = [NSString stringWithFormat:@"%.1ld", (long)self.data.quato];
        self.freeNumLabel.attributedText = [self configureAttributedText:fullText andHilightedRange:numText];
    }
    
    // 手续费
    {
        NSString *fullText = [NSString stringWithFormat:@"手续费：%.1f元/次", self.data.fees];
        NSString *numText = [NSString stringWithFormat:@"%.1f", self.data.fees];
        self.feeLabel.attributedText = [self configureAttributedText:fullText andHilightedRange:numText];
    }
}

/** 设置高亮范围 */
- (NSMutableAttributedString *)configureAttributedText:(NSString *)attributedString
                                     andHilightedRange:(NSString *)hilightedString {
    UIColor *color = COLOR_FB8313;
    
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:attributedString];
    
    NSRange hilightedRange = [attributedString rangeOfString:hilightedString];
    
    [attributedText addAttribute:NSForegroundColorAttributeName value:color range:hilightedRange];
    
    return attributedText;
}

@end

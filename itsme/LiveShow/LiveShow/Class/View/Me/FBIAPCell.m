#import "FBIAPCell.h"

@interface FBIAPCell ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (weak, nonatomic) IBOutlet UILabel *priceLabel;

@property (weak, nonatomic) IBOutlet UILabel *bonusLabel;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleCenterYConstraint;

@end

@implementation FBIAPCell

- (void)setProduct:(SKProduct *)product {
    
    _product = product;

    // 赠送钻石
    NSString *bonus = [NSString stringWithFormat:@"%ld", (long)[FBUtility diamondBonusWithIdentifier:self.product.productIdentifier]];
    
    if ([bonus isEqualToString:@"0"]) {
        _titleCenterYConstraint.constant = 0;
    } else {
        _bonusLabel.text = [NSString stringWithFormat:kLocalizationExtraDiamonds,bonus];
    }
    
    // 商品标题
    self.titleLabel.text = self.product.localizedTitle;
    
    // 商品价格
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [numberFormatter setLocale:product.priceLocale];
    NSString *formattedString = [numberFormatter stringFromNumber:product.price];
    self.priceLabel.text = formattedString;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    self.priceLabel.backgroundColor = COLOR_MAIN;
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];
    self.priceLabel.backgroundColor = COLOR_MAIN;
}

@end
